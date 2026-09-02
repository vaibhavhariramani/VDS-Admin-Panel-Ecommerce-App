import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../utils/role_controller.dart';
import '../bill.dart';
import 'invoice_request.dart';
import 'invoice_request_api.dart';

/// Super admins land on the review queue for every employee-submitted
/// request; employees land on a read-only view of their own submissions.
class InvoiceRequestsScreen extends StatelessWidget {
  const InvoiceRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appCanvas(context),
      appBar: AppBar(
        title: Text(
            RoleController.isSuperAdmin ? 'Invoice Requests' : 'My Requests'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: RoleController.isSuperAdmin
          ? const _ReviewQueue()
          : _MyRequests(uid: FirebaseAuth.instance.currentUser?.uid ?? ''),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'approved'
        ? AppColors.accentGreen
        : status == 'rejected'
            ? AppColors.accentRed
            : AppColors.accentAmber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class _ReviewQueue extends StatelessWidget {
  const _ReviewQueue();

  Future<void> _reject(BuildContext context, InvoiceRequest request) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject this request?'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final reviewer = FirebaseAuth.instance.currentUser;
    if (reviewer == null) return;
    await InvoiceRequestApi.reject(
      requestId: request.id,
      reviewer: reviewer,
      reason: reasonController.text.trim(),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request rejected.')),
      );
    }
  }

  void _review(BuildContext context, InvoiceRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Bill(
          products: request.products,
          addedfromDB: true,
          reviewingRequestId: request.id,
          initialCustomerPhone: request.customerPhone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat.yMMMd().add_jm();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: InvoiceRequestApi.allRequests(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Failed to load requests: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests =
            snapshot.data!.docs.map((doc) => InvoiceRequest.fromDoc(doc)).toList();
        final pending = requests.where((r) => r.status == 'pending').toList();
        final history = requests.where((r) => r.status != 'pending').toList();

        if (requests.isEmpty) {
          return Center(
            child: Text('No invoice requests yet.',
                style: AppText.caption(context)),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Pending (${pending.length})',
                style: AppText.heading(context)),
            const SizedBox(height: 12),
            if (pending.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('Nothing waiting on review.',
                    style: AppText.caption(context)),
              ),
            ...pending.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(r.requestedByName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.bodyStrong(context)),
                            ),
                            _StatusBadge(status: r.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${r.itemCount} item(s) · ₹${r.total.toStringAsFixed(0)}'
                          '${r.createdAt != null ? ' · ${format.format(r.createdAt!)}' : ''}',
                          style: AppText.caption(context),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _reject(context, r),
                              child: const Text('Reject',
                                  style: TextStyle(color: Colors.red)),
                            ),
                            const SizedBox(width: 8),
                            PillButton(
                              label: 'Review',
                              onPressed: () => _review(context, r),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
            if (history.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('History', style: AppText.heading(context)),
              const SizedBox(height: 12),
              ...history.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(r.requestedByName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.bodyStrong(context)),
                              ),
                              _StatusBadge(status: r.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${r.itemCount} item(s) · ₹${r.total.toStringAsFixed(0)}',
                            style: AppText.caption(context),
                          ),
                          if (r.status == 'rejected' &&
                              (r.rejectionReason ?? '').isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('Reason: ${r.rejectionReason}',
                                style: AppText.caption(context)),
                          ],
                        ],
                      ),
                    ),
                  )),
            ],
          ],
        );
      },
    );
  }
}

class _MyRequests extends StatelessWidget {
  final String uid;
  const _MyRequests({required this.uid});

  @override
  Widget build(BuildContext context) {
    final format = DateFormat.yMMMd().add_jm();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: InvoiceRequestApi.myRequests(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Failed to load requests: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests =
            snapshot.data!.docs.map((doc) => InvoiceRequest.fromDoc(doc)).toList()
              ..sort((a, b) => (b.createdAt ?? DateTime(0))
                  .compareTo(a.createdAt ?? DateTime(0)));
        if (requests.isEmpty) {
          return Center(
            child: Text(
                'Bills you submit from Start Billing will show up here.',
                style: AppText.caption(context)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final r = requests[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${r.itemCount} item(s) · ₹${r.total.toStringAsFixed(0)}',
                            style: AppText.bodyStrong(context),
                          ),
                        ),
                        _StatusBadge(status: r.status),
                      ],
                    ),
                    if (r.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(format.format(r.createdAt!),
                          style: AppText.caption(context)),
                    ],
                    if (r.status == 'rejected' &&
                        (r.rejectionReason ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Reason: ${r.rejectionReason}',
                          style: AppText.caption(context)),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
