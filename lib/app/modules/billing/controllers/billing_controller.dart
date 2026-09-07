import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/BillLineItem.dart';
import '../../../../models/Product.dart';
import '../../../../models/UserStatus.dart';
import '../../../../models/UserType.dart';
import '../../../../models/Users.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/data_service.dart';
import '../../../../services/fetch_data.dart';

/// What the checkout transaction actually decided, returned as data rather
/// than thrown. Firestore's web transaction implementation round-trips the
/// transaction closure's result through a JS promise - an exception thrown
/// from inside it comes back on the other side wrapped in a generic
/// "Dart exception thrown from converted Future" error, not as the
/// original type, so `on _InsufficientStockException catch` etc. never
/// actually matched on web (confirmed live: a real insufficient-stock
/// rejection was showing as that opaque wrapper text, not the friendly
/// "Not enough stock for X" message). Returning the outcome as a plain
/// value survives that boundary intact.
enum _BillOutcome { created, alreadyCompleted, insufficientStock, invalidStockQuantity }

class _BillTransactionResult {
  final _BillOutcome outcome;
  final String? itemName;
  const _BillTransactionResult(this.outcome, [this.itemName]);
}

class BillingController extends GetxController {
  // Dashboard tile counters shown at the top of the Billing tab (unrelated
  // to the cart/invoice flow below).
  final RxBool isloading = false.obs;
  final RxInt activeUserCount = 0.obs;
  final RxInt inActiveUserCount = 0.obs;
  final RxInt requestedUser = 0.obs;
  final RxInt totalUserCount = 0.obs;
  final RxBool isLoadingAllUsers = false.obs;
  final RxList<Users> allUsers = <Users>[].obs;

  final FetchService _fetchService = FetchService.to;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<BillLineItem> billItems = <BillLineItem>[].obs;
  final RxBool isCreatingBill = false.obs;
  final RxBool billCreated = false.obs;
  final RxString shopName = ''.obs;
  final RxString shopCurrency = ''.obs;

  final TextEditingController contactController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();

  String? shopId;
  String? _shopRegionId;
  String? _shopCountry;
  String? lastInvoiceNumber;
  String? lastPdfUrl;
  Uint8List? lastPdfBytes;

  // Idempotency key for the in-progress bill. Generated once when the bill
  // starts (onInit / clearBill), not at pay-time, so that a double tap of
  // "Pay" — or a retried request after a flaky network response — reuses
  // the same key and createBill() can recognize the duplicate instead of
  // decrementing stock or writing an invoice twice.
  String? _idempotencyKey;
  static const String _idKeyChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final Random _idKeyRandom = Random.secure();

  void _ensureIdempotencyKey() {
    if (_idempotencyKey != null) return;
    final String suffix =
        List.generate(8, (_) => _idKeyChars[_idKeyRandom.nextInt(_idKeyChars.length)])
            .join();
    _idempotencyKey = 'INV-${DateTime.now().millisecondsSinceEpoch}-$suffix';
  }

  double get total =>
      billItems.fold(0.0, (double sum, BillLineItem item) => sum + item.lineTotal);

  @override
  void onInit() {
    super.onInit();
    _loadShopInfo();
    _ensureIdempotencyKey();
    _loadUserCounts();
  }

  /// Active/Inactive split isn't backed by any real signal on `Users` docs
  /// yet (no doc has ever had an active/inactive field written to it), so
  /// both counts currently reflect the same total customer count until that
  /// distinction is actually tracked somewhere.
  Future<void> _loadUserCounts() async {
    isloading(true);
    final int total = await DataService.to.GetUserCount(
      userType: UserType.CUSTOMER,
      status: UserStatus.ACTIVE,
    );
    totalUserCount(total);
    activeUserCount(total);
    inActiveUserCount(0);
    isloading(false);
  }

  Future<void> loadAllUsers() async {
    isLoadingAllUsers(true);
    final List<Users> users =
        await DataService.to.fetchAllUsers(userType: UserType.CUSTOMER);
    allUsers.assignAll(users);
    isLoadingAllUsers(false);
  }

  @override
  void onClose() {
    contactController.dispose();
    customerNameController.dispose();
    super.onClose();
  }

  Future<void> _loadShopInfo() async {
    shopId = await _fetchService.fetchShopId();
    if (shopId != null) {
      try {
        final DocumentSnapshot<Object?> doc =
            await _firestore.collection('Shops').doc(shopId).get();
        final data = doc.data() as Map<String, dynamic>?;
        shopName.value = data?['name']?.toString() ?? '';
        _shopRegionId = data?['regionId']?.toString();
        _shopCountry = data?['Country']?.toString();
      } catch (e) {
        print('Error loading shop details: $e');
      }
    }
    shopCurrency.value = await _fetchService.fetchShopCurrency() ?? '';
  }

  Future<List<Product>> fetchShopProducts() async {
    if (shopId == null) return [];
    return _fetchService.fetchAllProductsByShop(shopId);
  }

  void increment(BillLineItem item) {
    item.quantity.value++;
  }

  void decrement(BillLineItem item) {
    if (item.quantity.value > 0) {
      item.quantity.value--;
    }
  }

  void removeItem(BillLineItem item) {
    billItems.remove(item);
  }

  void addProduct(Product product, {int quantity = 1}) {
    // product.id is actually backed by the product's barcode (see
    // Product.fromJson) - never the real Firestore doc id - so it's empty
    // whenever barcode is. `?? product.name` didn't defend against that:
    // '' is not null, so an empty string passed straight through as the
    // key. That empty string later reached
    // FirebaseFirestore.doc(''), which throws synchronously - the actual
    // cause of "Error creating bill" for any product with no barcode.
    final String key = (product.barcode?.isNotEmpty ?? false)
        ? product.barcode!
        : ((product.id?.isNotEmpty ?? false) ? product.id! : product.name);
    BillLineItem? existing;
    for (final BillLineItem item in billItems) {
      if (item.productId == key) {
        existing = item;
        break;
      }
    }
    if (existing != null) {
      existing.quantity.value += quantity;
    } else {
      billItems.add(BillLineItem(
        productId: key,
        name: product.name,
        price: product.price,
        imageUrl: product.img_token,
        quantity: quantity,
      ));
    }
  }

  void addCustomItem({
    required String name,
    required double price,
    int quantity = 1,
  }) {
    billItems.add(BillLineItem(name: name, price: price, quantity: quantity));
  }

  Future<void> addByBarcode(String barcode) async {
    final String trimmed = barcode.trim();
    if (trimmed.isEmpty) return;
    try {
      Map<String, dynamic>? data;
      final DocumentSnapshot<Object?> byId =
          await _firestore.collection('Products').doc(trimmed).get();
      if (byId.exists) {
        data = byId.data() as Map<String, dynamic>?;
      } else {
        final QuerySnapshot<Object?> query = await _firestore
            .collection('Products')
            .where('barcode', isEqualTo: trimmed)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          data = query.docs.first.data() as Map<String, dynamic>?;
        }
      }
      if (data == null) {
        Fluttertoast.showToast(msg: 'No product found for barcode $trimmed');
        return;
      }
      final Product product = Product.fromJson(data);
      addProduct(product);
      Fluttertoast.showToast(msg: 'Added ${product.name}');
    } catch (e) {
      print('Error looking up barcode $trimmed: $e');
      Fluttertoast.showToast(msg: 'Error scanning barcode');
    }
  }

  /// Resolves a bill line item's `productId` (which is a barcode for
  /// scanned items, a doc id for others, or unresolvable for a manually
  /// typed custom item) to its actual `Products` document, mirroring
  /// `DataService._productDocRef`. Custom items that don't resolve are
  /// simply not stock-checked.
  Future<DocumentReference<Object?>?> _resolveProductRef(String productId) async {
    // FirebaseFirestore.doc('') throws synchronously rather than just
    // finding nothing - never let an empty id reach it.
    if (productId.isEmpty) return null;
    final DocumentReference<Object?> byId =
        _firestore.collection('Products').doc(productId);
    final DocumentSnapshot<Object?> byIdSnap = await byId.get();
    if (byIdSnap.exists) return byId;
    final QuerySnapshot<Object?> byBarcode = await _firestore
        .collection('Products')
        .where('barcode', isEqualTo: productId)
        .limit(1)
        .get();
    if (byBarcode.docs.isNotEmpty) return byBarcode.docs.first.reference;
    return null;
  }

  Future<Uint8List> _buildInvoicePdf(String invoiceNumber, double grandTotal) async {
    final pw.Document doc = pw.Document();
    final DateTime now = DateTime.now();
    final String currency = shopCurrency.value;
    final List<BillLineItem> lineItems =
        billItems.where((BillLineItem i) => i.quantity.value > 0).toList();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              shopName.value.isNotEmpty ? shopName.value : 'Invoice',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text('Invoice: $invoiceNumber'),
            pw.Text('Date: ${now.toString().substring(0, 16)}'),
            if (customerNameController.text.trim().isNotEmpty)
              pw.Text('Customer: ${customerNameController.text.trim()}'),
            if (contactController.text.trim().isNotEmpty)
              pw.Text('Contact: ${contactController.text.trim()}'),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: const ['Item', 'Qty', 'Price', 'Total'],
              data: lineItems
                  .map((BillLineItem i) => [
                        i.name,
                        i.quantity.value.toString(),
                        '$currency ${i.price.toStringAsFixed(2)}',
                        '$currency ${i.lineTotal.toStringAsFixed(2)}',
                      ])
                  .toList(),
            ),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Grand Total: $currency ${grandTotal.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Text('Thank you for shopping with us!'),
          ],
        ),
      ),
    );
    return doc.save();
  }

  /// The critical path to a committed sale is: resolve product refs, build
  /// the PDF in memory, and run one Firestore transaction. The Storage
  /// upload (needed only for `pdfUrl`, used by the SMS-share action) is
  /// network-bound and was previously sitting *in* that critical path,
  /// which is why creating a bill used to feel slow — it's now kicked off
  /// in the background after the transaction already succeeded, via
  /// [_uploadInvoicePdfInBackground]. `shareOrPrintInvoice` doesn't need
  /// it at all: it shares the PDF bytes already held in memory.
  Future<bool> createBill() async {
    if (billItems.isEmpty || total <= 0) {
      Fluttertoast.showToast(msg: 'Add at least one item to the bill');
      return false;
    }
    if (isCreatingBill.value) return false;
    isCreatingBill(true);
    try {
      _ensureIdempotencyKey();
      final String invoiceNumber = _idempotencyKey!;
      final List<BillLineItem> lineItems =
          billItems.where((BillLineItem i) => i.quantity.value > 0).toList();

      // Resolve catalog line items to their Products doc *before* the
      // transaction (a barcode lookup is a query, and Firestore
      // transactions can only read via transaction.get() on a known
      // reference, not run arbitrary queries) — in parallel, since these
      // lookups are independent of each other.
      final List<MapEntry<BillLineItem, DocumentReference<Object?>>?> resolved =
          await Future.wait(lineItems.map((BillLineItem item) async {
        final String? productId = item.productId;
        // An empty productId (see addProduct's comment) reaching
        // Products.doc('') throws synchronously - guard against it here
        // too, in case a line item was ever built with one some other way.
        if (productId == null || productId.isEmpty) return null;
        final DocumentReference<Object?>? ref = await _resolveProductRef(productId);
        return ref == null ? null : MapEntry(item, ref);
      }));
      final Map<BillLineItem, DocumentReference<Object?>> productRefs =
          Map.fromEntries(resolved.whereType<MapEntry<BillLineItem, DocumentReference<Object?>>>());

      final double grandTotal = total;
      final Uint8List pdfBytes = await _buildInvoicePdf(invoiceNumber, grandTotal);

      final DocumentReference<Object?> billRef =
          _firestore.collection('Bills').doc(invoiceNumber);

      // Stock check, stock decrement, and the bill write happen atomically:
      // either all of them succeed or none do, and re-reading each
      // product's quantity *inside* the transaction (rather than trusting
      // the cart's stale view) is what makes two concurrent sales of the
      // last unit resolve safely instead of overselling.
      final _BillTransactionResult result =
          await _firestore.runTransaction<_BillTransactionResult>((Transaction tx) async {
        final DocumentSnapshot<Object?> existingBill = await tx.get(billRef);
        if (existingBill.exists) {
          // Same idempotency key already completed this exact bill (a
          // double tap of "Pay", or a retried request) — don't touch
          // stock or write a second invoice.
          return const _BillTransactionResult(_BillOutcome.alreadyCompleted);
        }

        final Map<BillLineItem, DocumentSnapshot<Object?>> productSnaps = {};
        for (final MapEntry<BillLineItem, DocumentReference<Object?>> entry
            in productRefs.entries) {
          productSnaps[entry.key] = await tx.get(entry.value);
        }

        for (final MapEntry<BillLineItem, DocumentSnapshot<Object?>> entry
            in productSnaps.entries) {
          final data = entry.value.data() as Map<String, dynamic>?;
          final String? rawQuantity = data?['quantity']?.toString();
          final int? available = rawQuantity == null ? 0 : int.tryParse(rawQuantity);
          if (available == null) {
            return _BillTransactionResult(_BillOutcome.invalidStockQuantity, entry.key.name);
          }
          if (available < entry.key.quantity.value) {
            return _BillTransactionResult(_BillOutcome.insufficientStock, entry.key.name);
          }
        }

        for (final MapEntry<BillLineItem, DocumentSnapshot<Object?>> entry
            in productSnaps.entries) {
          final data = entry.value.data() as Map<String, dynamic>?;
          final int available =
              int.tryParse(data?['quantity']?.toString() ?? '0') ?? 0;
          tx.update(productRefs[entry.key]!, {
            'quantity': available - entry.key.quantity.value,
          });
        }

        tx.set(billRef, {
          'invoiceNumber': invoiceNumber,
          'shopId': shopId,
          'regionId': _shopRegionId,
          'Country': _shopCountry,
          'items': lineItems.map((BillLineItem i) => i.toJson()).toList(),
          'total': grandTotal,
          'customerName': customerNameController.text.trim().isEmpty
              ? null
              : customerNameController.text.trim(),
          'customerContact': contactController.text.trim().isEmpty
              ? null
              : contactController.text.trim(),
          'createdBy': AuthService.to.user.value?.id,
          'pdfUrl': null,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return const _BillTransactionResult(_BillOutcome.created);
      });

      if (result.outcome == _BillOutcome.insufficientStock) {
        Fluttertoast.showToast(msg: 'Not enough stock for ${result.itemName}');
        return false;
      }
      if (result.outcome == _BillOutcome.invalidStockQuantity) {
        Fluttertoast.showToast(
          msg:
              "${result.itemName}'s stock quantity isn't a number - fix it from Product Listing before billing it",
          toastLength: Toast.LENGTH_LONG,
        );
        return false;
      }

      if (result.outcome == _BillOutcome.created) {
        // Fire-and-forget: neither the activity log nor the PDF upload
        // needs to hold up handing control back to the cashier.
        DataService.to.CreateLogs(action: 'Created bill $invoiceNumber');
        _uploadInvoicePdfInBackground(invoiceNumber, pdfBytes, billRef);
        Fluttertoast.showToast(msg: 'Bill created successfully');
      }

      lastInvoiceNumber = invoiceNumber;
      lastPdfBytes = pdfBytes;
      billCreated(true);
      return true;
    } catch (e) {
      print('Error creating bill: $e');
      // Surface the real cause instead of a bare "Error creating bill" -
      // this exact opaque message was the reported bug (turned out to be
      // FirebaseFirestore.doc('') throwing for a product with no
      // barcode - now guarded above), and it was invisible without
      // reading device logs. Keep the specific-exception messages above
      // for the cases that already have a good one.
      Fluttertoast.showToast(
        msg: 'Error creating bill: $e',
        toastLength: Toast.LENGTH_LONG,
      );
      return false;
    } finally {
      isCreatingBill(false);
    }
  }

  /// Uploads the invoice PDF and patches its URL onto the already-committed
  /// bill doc. Runs after `createBill()` has already returned, so a slow
  /// or failed upload never blocks the cashier from moving on — only the
  /// "Send via SMS" link (which includes `pdfUrl`) depends on this having
  /// finished; "Share / Print PDF" uses the in-memory bytes directly.
  Future<void> _uploadInvoicePdfInBackground(
    String invoiceNumber,
    Uint8List pdfBytes,
    DocumentReference<Object?> billRef,
  ) async {
    try {
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('invoices/${shopId ?? 'unknown'}/$invoiceNumber.pdf');
      await ref.putData(pdfBytes, SettableMetadata(contentType: 'application/pdf'));
      final String url = await ref.getDownloadURL();
      await billRef.update({'pdfUrl': url});
      if (lastInvoiceNumber == invoiceNumber) {
        lastPdfUrl = url;
      }
    } catch (e) {
      print('Could not upload invoice PDF for $invoiceNumber: $e');
    }
  }

  Future<void> shareOrPrintInvoice() async {
    if (lastPdfBytes == null) return;
    await Printing.sharePdf(
      bytes: lastPdfBytes!,
      filename: '${lastInvoiceNumber ?? 'invoice'}.pdf',
    );
  }

  /// Opens the device's SMS composer prefilled with the invoice link so the
  /// cashier can review and send it. Fully automatic (no user tap) delivery
  /// would require a paid SMS gateway (e.g. Twilio) wired up behind a Cloud
  /// Function, which this project doesn't have.
  Future<void> sendInvoiceViaSms() async {
    final String contact = contactController.text.trim();
    if (contact.isEmpty) {
      Fluttertoast.showToast(msg: 'Enter a customer contact number first');
      return;
    }
    final String message = lastPdfUrl != null
        ? 'Thank you for shopping with us! Your invoice ${lastInvoiceNumber ?? ''}: $lastPdfUrl'
        : 'Thank you for shopping with us!';
    final Uri smsUri =
        Uri(scheme: 'sms', path: contact, queryParameters: {'body': message});
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        Fluttertoast.showToast(msg: 'No SMS app available on this device');
      }
    } catch (e) {
      print('Error launching SMS composer: $e');
      Fluttertoast.showToast(msg: 'Could not open SMS composer');
    }
  }

  void clearBill() {
    billItems.clear();
    contactController.clear();
    customerNameController.clear();
    lastPdfBytes = null;
    lastPdfUrl = null;
    lastInvoiceNumber = null;
    billCreated(false);
    _idempotencyKey = null;
    _ensureIdempotencyKey();
  }

  /// Starts a new, separate bill — its own invoice, its own stock
  /// decrement — for the same customer. The just-created bill is already
  /// committed, so this doesn't reopen or amend it; it's the fast path for
  /// "the customer wants one more thing" without leaving the dialog or
  /// re-entering their name/contact, unlike [clearBill] which resets those
  /// too.
  void startFollowOnBill() {
    billItems.clear();
    lastPdfBytes = null;
    lastPdfUrl = null;
    lastInvoiceNumber = null;
    billCreated(false);
    _idempotencyKey = null;
    _ensureIdempotencyKey();
  }
}
