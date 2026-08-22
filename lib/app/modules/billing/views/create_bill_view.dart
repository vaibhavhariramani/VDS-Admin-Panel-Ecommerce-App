import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import '../../../../models/BillLineItem.dart';
import '../../../../models/Product.dart';
import '../../../widgets/components/common_card.dart';
import '../controllers/billing_controller.dart';

/// Full-screen cart/checkout page opened from the Billing tab. Items can be
/// added via the barcode scanner (anywhere on screen), "Add from Database"
/// (the shop's own catalog), or "Add Custom Item" (a one-off line).
class CreateBillView extends StatelessWidget {
  const CreateBillView({Key? key}) : super(key: key);

  BillingController get controller => Get.find<BillingController>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: Get.width * 0.92,
        height: Get.height * 0.92,
        child: BarcodeKeyboardListener(
          onBarcodeScanned: (String barcode) => controller.addByBarcode(barcode),
          child: Column(
            children: [
              _header(context),
              const Divider(height: 1),
              Expanded(child: _body(context)),
              const Divider(height: 1),
              _footer(context),
            ],
          ),
        ),
      ),
    );
  }

  /// The close button is pinned via [Stack]/[Align] rather than living as
  /// the last item in the header [Row]. With "Add from Database" and "Add
  /// Custom Item" both rendered as labeled buttons, a narrower browser
  /// window overflows the row and pushes a trailing close button past the
  /// visible/clickable edge — the scrollable content below is free to
  /// overflow into a horizontal scroll instead, but the close button
  /// always stays reachable in the top-right corner.
  ///
  /// The title/subtitle column is capped to one line each with an
  /// ellipsis: the subtitle text is long enough to wrap to two lines at
  /// its 260px width, which overflowed the fixed 48px header height this
  /// sits inside.
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 44),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 260,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Create Bill',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Scan a barcode anywhere on this screen to add an item',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showAddFromDbDialog(context),
                      icon: const Icon(Icons.grid_view_rounded),
                      label: const Text('Add from Database'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showAddCustomItemDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Custom Item'),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close',
              onPressed: () {
                controller.clearBill();
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Obx(() {
      if (controller.billItems.isEmpty) {
        return const Center(
          child: Text(
            'No items yet — scan a barcode or add an item to get started',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: controller.billItems.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) => _billItemRow(controller.billItems[index]),
      );
    });
  }

  Widget _billItemRow(BillLineItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              (item.imageUrl?.isNotEmpty ?? false) ? item.imageUrl! : noImg,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 48,
                height: 48,
                color: Colors.grey.shade200,
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Obx(() => Text(
                      '${controller.shopCurrency.value} ${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.grey),
                    )),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => controller.decrement(item),
          ),
          Obx(() => SizedBox(
                width: 28,
                child: Text(
                  '${item.quantity.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => controller.increment(item),
          ),
          SizedBox(
            width: 100,
            child: Obx(() => Text(
                  '${controller.shopCurrency.value} ${item.lineTotal.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => controller.removeItem(item),
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Obx(() {
      if (controller.billCreated.value) {
        return _postCreatePanel();
      }
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.customerNameController,
                    decoration:
                        const InputDecoration(labelText: 'Customer name (optional)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller.contactController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Customer contact (for SMS)',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      'Total: ${controller.shopCurrency.value} ${controller.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
                Obx(() => ElevatedButton.icon(
                      onPressed: controller.isCreatingBill.value
                          ? null
                          : () => controller.createBill(),
                      icon: controller.isCreatingBill.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.receipt_long),
                      label: const Text('Create Bill'),
                    )),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// The just-created bill is already committed (stock decremented, invoice
  /// written) — it can't be silently reopened and edited without risking a
  /// second, inconsistent write against the same idempotency key. "Add
  /// More Items" instead starts a fresh follow-on bill (its own invoice,
  /// its own stock decrement) for the same customer, so ringing up one
  /// more thing they forgot doesn't mean re-entering their name/contact or
  /// leaving the dialog.
  Widget _postCreatePanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bill ${controller.lastInvoiceNumber ?? ''} created successfully',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: controller.shareOrPrintInvoice,
                icon: const Icon(Icons.print_outlined),
                label: const Text('Share / Print PDF'),
              ),
              OutlinedButton.icon(
                onPressed: controller.sendInvoiceViaSms,
                icon: const Icon(Icons.sms_outlined),
                label: const Text('Send via SMS'),
              ),
              OutlinedButton.icon(
                onPressed: controller.startFollowOnBill,
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Add More Items'),
              ),
              TextButton(
                onPressed: controller.clearBill,
                child: const Text('New Bill'),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.clearBill();
                  Get.back();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddCustomItemDialog(BuildContext context) {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController priceCtrl = TextEditingController();
    final TextEditingController qtyCtrl = TextEditingController(text: '1');
    Get.dialog(
      AlertDialog(
        title: const Text('Add Custom Item'),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Item name'),
              ),
              TextField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final String name = nameCtrl.text.trim();
              final double? price = double.tryParse(priceCtrl.text.trim());
              final int qty = int.tryParse(qtyCtrl.text.trim()) ?? 1;
              if (name.isEmpty || price == null || price <= 0 || qty <= 0) {
                Fluttertoast.showToast(msg: 'Enter a valid name, price and quantity');
                return;
              }
              controller.addCustomItem(name: name, price: price, quantity: qty);
              Get.back();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddFromDbDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        child: SizedBox(
          width: Get.width * 0.7,
          height: Get.height * 0.7,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<List<Product>>(
              future: controller.fetchShopProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final List<Product> products = snapshot.data ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add from Database',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                    Expanded(
                      child: products.isEmpty
                          ? const Center(child: Text('No products found for this shop'))
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, index) =>
                                  _dbProductTile(products[index]),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _dbProductTile(Product product) {
    return InkWell(
      onTap: () {
        controller.addProduct(product);
        Fluttertoast.showToast(msg: 'Added ${product.name}');
      },
      child: CommonCard(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    (product.img_token?.isNotEmpty ?? false) ? product.img_token! : noImg,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              Text(
                '${product.currency_type ?? ''} ${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
