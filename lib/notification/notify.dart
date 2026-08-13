import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../customers/customer_list_screen.dart';
import '../theme/app_theme.dart';
import 'notification_api.dart';

/// Looks up the OneSignal subscription id the shopping app registered for
/// this customer's phone number, if any (see Users/{phone}.onesignalTokenID
/// - written by the customer-facing app, not this admin panel).
Future<String?> _lookupOneSignalToken(String phoneKey) async {
  if (phoneKey.isEmpty) return null;
  final doc = await FirebaseFirestore.instance
      .collection('Users')
      .doc('+91$phoneKey')
      .get();
  if (!doc.exists) return null;
  final token = doc.data()?['onesignalTokenID']?.toString();
  return (token != null && token.isNotEmpty) ? token : null;
}

/// Pick one or more customers from the customer database and send them a
/// push notification (see notifyhome.dart's "Send Individual" tile).
class UserViewer extends StatefulWidget {
  const UserViewer({Key? key}) : super(key: key);

  @override
  State<UserViewer> createState() => _UserViewerState();
}

class _UserViewerState extends State<UserViewer> {
  String _query = '';
  final Set<String> _selected = {};
  Map<String, CustomerSummary> _byPhoneKey = {};

  void _toggle(CustomerSummary customer) {
    setState(() {
      if (_selected.contains(customer.phoneKey)) {
        _selected.remove(customer.phoneKey);
      } else {
        _selected.add(customer.phoneKey);
      }
    });
  }

  Future<void> _openComposeDialog() async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    final selectedCustomers =
        _selected.map((k) => _byPhoneKey[k]).whereType<CustomerSummary>().toList();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool sending = false;
        String? error;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Notify ${selectedCustomers.length} customer'
                  '${selectedCustomers.length == 1 ? '' : 's'}'),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: messageController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 8),
                      Text(error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      sending ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                PillButton(
                  label: sending ? 'Sending…' : 'Send',
                  onPressed: sending
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          final message = messageController.text.trim();
                          if (title.isEmpty || message.isEmpty) {
                            setDialogState(
                                () => error = 'Enter a title and a message.');
                            return;
                          }
                          setDialogState(() {
                            sending = true;
                            error = null;
                          });
                          try {
                            final tokens = <String>[];
                            for (final c in selectedCustomers) {
                              final t = await _lookupOneSignalToken(c.phoneKey);
                              if (t != null) tokens.add(t);
                            }
                            if (tokens.isEmpty) {
                              setDialogState(() {
                                sending = false;
                                error =
                                    'None of the selected customers have notifications enabled on their device.';
                              });
                              return;
                            }
                            await NotificationApi.send(
                              title: title,
                              message: message,
                              playerIds: tokens,
                              audienceUids: selectedCustomers
                                  .map((c) => c.uid)
                                  .where((u) => u.isNotEmpty)
                                  .toList(),
                            );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (mounted) {
                              final skipped =
                                  selectedCustomers.length - tokens.length;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(skipped == 0
                                      ? 'Sent to ${tokens.length} customer${tokens.length == 1 ? '' : 's'}.'
                                      : 'Sent to ${tokens.length} customer${tokens.length == 1 ? '' : 's'} ($skipped had no device on file).'),
                                ),
                              );
                              setState(() => _selected.clear());
                            }
                          } catch (e) {
                            setDialogState(() {
                              sending = false;
                              error = e.toString();
                            });
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode(context);
    return Scaffold(
      backgroundColor: appCanvas(context),
      appBar: AppBar(
        title: const Text('Send Individual'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Orders').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var customers = buildCustomerSummaries(snapshot.data!.docs);
          _byPhoneKey = {for (final c in customers) c.phoneKey: c};
          if (_query.trim().isNotEmpty) {
            final q = _query.trim().toLowerCase();
            customers = customers
                .where((c) =>
                    c.name.toLowerCase().contains(q) || c.phone.contains(q))
                .toList();
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: AppText.body(context),
                      decoration: InputDecoration(
                        hintText: 'Search by name or phone',
                        hintStyle:
                            AppText.body(context, color: AppColors.shade50),
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: appSurface(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: appHairline(context)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: customers.isEmpty
                          ? Center(
                              child: Text('No customers found',
                                  style: AppText.body(context,
                                      color: AppColors.shade50)))
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisExtent: 140,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: customers.length,
                              itemBuilder: (context, index) {
                                final c = customers[index];
                                final selected =
                                    _selected.contains(c.phoneKey);
                                return AppCard(
                                  padding: const EdgeInsets.all(16),
                                  onTap: () => _toggle(c),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: selected,
                                        activeColor: AppColors.primary,
                                        onChanged: (_) => _toggle(c),
                                      ),
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: dark
                                            ? Colors.white12
                                            : AppColors.orangeTint10,
                                        child: Text(
                                          c.name.isNotEmpty
                                              ? c.name[0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                              color: AppColors.primaryDark,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(c.name,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: AppText.bodyStrong(
                                                    context)),
                                            const SizedBox(height: 2),
                                            Text(c.phone,
                                                style: AppText.caption(
                                                    context)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _selected.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PillButton(
                  label:
                      'Compose message (${_selected.length} selected)',
                  icon: Icons.send_outlined,
                  onPressed: _openComposeDialog,
                ),
              ),
            ),
    );
  }
}
