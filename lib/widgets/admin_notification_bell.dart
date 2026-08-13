import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../attendance/attendance_screen.dart';
import '../billing/invoice_requests/invoice_requests_screen.dart';
import '../orders/onlineorders2.dart';
import '../theme/app_theme.dart';
import '../utils/role_controller.dart';

/// Bell icon with a badge count and a top-right popup, shared by the
/// Dashboard and Start Billing app bars. Only ever shown to super admins -
/// callers should gate visibility with `RoleController.isSuperAdmin`, but
/// this widget also no-ops for anyone else as a second line of defense.
class _BellButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _BellButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Badge(
        label: Text('$count'),
        isLabelVisible: count > 0,
        backgroundColor: AppColors.accentRed,
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}

class _BellRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _BellRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label, style: AppText.body(context))),
            Icon(Icons.chevron_right, color: AppColors.shade40, size: 18),
          ],
        ),
      ),
    );
  }
}

void _showTopRightPopup(BuildContext context, Widget content) {
  showDialog(
    context: context,
    barrierColor: Colors.black26,
    builder: (dialogContext) => Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 64, right: 16),
        child: Material(
          color: appSurface(dialogContext),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          elevation: 8,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 300, maxWidth: 340),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: content,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Dashboard app bar bell: pending invoice requests, pending attendance,
/// and new (not-yet-processed) online orders.
class DashboardNotificationBell extends StatefulWidget {
  const DashboardNotificationBell({Key? key}) : super(key: key);

  @override
  State<DashboardNotificationBell> createState() =>
      _DashboardNotificationBellState();
}

class _DashboardNotificationBellState extends State<DashboardNotificationBell> {
  StreamSubscription? _invoiceSub;
  StreamSubscription? _attendanceSub;
  StreamSubscription? _orderSub;
  int _pendingInvoices = 0;
  int _pendingAttendance = 0;
  int _newOrders = 0;

  @override
  void initState() {
    super.initState();
    if (!RoleController.isSuperAdmin) return;
    _invoiceSub = FirebaseFirestore.instance
        .collection('InvoiceRequests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snap) {
      if (mounted) setState(() => _pendingInvoices = snap.docs.length);
    });
    _attendanceSub = FirebaseFirestore.instance
        .collection('Attendance')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snap) {
      if (mounted) setState(() => _pendingAttendance = snap.docs.length);
    });
    _orderSub = FirebaseFirestore.instance
        .collection('Orders')
        .where('status', isEqualTo: 'Order Placed')
        .snapshots()
        .listen((snap) {
      if (mounted) setState(() => _newOrders = snap.docs.length);
    });
  }

  @override
  void dispose() {
    _invoiceSub?.cancel();
    _attendanceSub?.cancel();
    _orderSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!RoleController.isSuperAdmin) return const SizedBox.shrink();
    final total = _pendingInvoices + _pendingAttendance + _newOrders;
    return _BellButton(
      count: total,
      onTap: () => _showTopRightPopup(
        context,
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text('Notifications', style: AppText.heading(context)),
            ),
            if (total == 0)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Nothing needs your attention right now.',
                    style: AppText.caption(context)),
              ),
            if (_pendingInvoices > 0)
              _BellRow(
                icon: Icons.receipt_long_outlined,
                color: AppColors.accentTeal,
                label:
                    '$_pendingInvoices invoice request${_pendingInvoices == 1 ? '' : 's'} waiting on approval',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const InvoiceRequestsScreen()));
                },
              ),
            if (_pendingAttendance > 0)
              _BellRow(
                icon: Icons.access_time_outlined,
                color: AppColors.accentCyan,
                label:
                    '$_pendingAttendance attendance shift${_pendingAttendance == 1 ? '' : 's'} waiting on approval',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AttendanceScreen()));
                },
              ),
            if (_newOrders > 0)
              _BellRow(
                icon: Icons.shopping_bag_outlined,
                color: AppColors.accentIndigo,
                label:
                    '$_newOrders new online order${_newOrders == 1 ? '' : 's'}',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const Orders2()));
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Start Billing app bar bell: pending invoice requests only.
class BillingNotificationBell extends StatefulWidget {
  const BillingNotificationBell({Key? key}) : super(key: key);

  @override
  State<BillingNotificationBell> createState() =>
      _BillingNotificationBellState();
}

class _BillingNotificationBellState extends State<BillingNotificationBell> {
  StreamSubscription? _sub;
  int _pendingInvoices = 0;

  @override
  void initState() {
    super.initState();
    if (!RoleController.isSuperAdmin) return;
    _sub = FirebaseFirestore.instance
        .collection('InvoiceRequests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snap) {
      if (mounted) setState(() => _pendingInvoices = snap.docs.length);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!RoleController.isSuperAdmin) return const SizedBox.shrink();
    return _BellButton(
      count: _pendingInvoices,
      onTap: () => _showTopRightPopup(
        context,
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text('Notifications', style: AppText.heading(context)),
            ),
            if (_pendingInvoices == 0)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No pending invoice requests.',
                    style: AppText.caption(context)),
              )
            else
              _BellRow(
                icon: Icons.receipt_long_outlined,
                color: AppColors.accentTeal,
                label:
                    '$_pendingInvoices invoice request${_pendingInvoices == 1 ? '' : 's'} waiting on approval',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const InvoiceRequestsScreen()));
                },
              ),
          ],
        ),
      ),
    );
  }
}
