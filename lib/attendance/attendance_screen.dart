import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../utils/role_controller.dart';
import 'attendance_api.dart';
import 'attendance_record.dart';

/// Employees clock in/out here; super admins review and approve/reject
/// each shift and see hours totals per employee.
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appCanvas(context),
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: RoleController.isSuperAdmin
          ? const _AdminAttendanceView()
          : _EmployeeAttendanceView(
              uid: FirebaseAuth.instance.currentUser?.uid ?? ''),
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
            : status == 'open'
                ? AppColors.accentBlue
                : AppColors.accentAmber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style:
            TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class _EmployeeAttendanceView extends StatefulWidget {
  final String uid;
  const _EmployeeAttendanceView({required this.uid});

  @override
  State<_EmployeeAttendanceView> createState() =>
      _EmployeeAttendanceViewState();
}

class _EmployeeAttendanceViewState extends State<_EmployeeAttendanceView> {
  bool _busy = false;

  Future<void> _clockIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await AttendanceApi.clockIn(user);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to clock in: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clockOut(AttendanceRecord open) async {
    setState(() => _busy = true);
    try {
      await AttendanceApi.clockOut(open);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to clock out: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat.yMMMd().add_jm();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: AttendanceApi.myRecords(widget.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Failed to load attendance: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final records = snapshot.data!.docs
            .map((d) => AttendanceRecord.fromDoc(d))
            .toList()
          ..sort((a, b) =>
              (b.clockIn ?? DateTime(0)).compareTo(a.clockIn ?? DateTime(0)));
        AttendanceRecord? open;
        for (final r in records) {
          if (r.status == 'open') {
            open = r;
            break;
          }
        }
        final history = records.where((r) => r.status != 'open').toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(open != null ? 'Clocked in' : 'Not clocked in',
                      style: AppText.heading(context)),
                  if (open != null && open.clockIn != null) ...[
                    const SizedBox(height: 4),
                    Text('Since ${format.format(open.clockIn!)}',
                        style: AppText.caption(context)),
                  ],
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PillButton(
                      label: _busy
                          ? 'Please wait…'
                          : (open != null ? 'Clock Out' : 'Clock In'),
                      onPressed: _busy
                          ? null
                          : (open != null
                              ? () => _clockOut(open!)
                              : _clockIn),
                      color:
                          open != null ? AppColors.accentRed : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('History', style: AppText.heading(context)),
            const SizedBox(height: 12),
            if (history.isEmpty)
              Text('Your past shifts will show up here.',
                  style: AppText.caption(context)),
            ...history.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                r.clockIn != null
                                    ? format.format(r.clockIn!)
                                    : '',
                                style: AppText.bodyStrong(context),
                              ),
                            ),
                            _StatusBadge(status: r.status),
                          ],
                        ),
                        if (r.hoursWorked != null) ...[
                          const SizedBox(height: 4),
                          Text(
                              '${r.hoursWorked!.toStringAsFixed(2)} hours',
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
                )),
          ],
        );
      },
    );
  }
}

class _AdminAttendanceView extends StatelessWidget {
  const _AdminAttendanceView();

  Future<void> _reject(BuildContext context, AttendanceRecord record) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject this shift?'),
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
    await AttendanceApi.reject(
      recordId: record.id,
      reviewer: reviewer,
      reason: reasonController.text.trim(),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shift rejected.')),
      );
    }
  }

  Future<void> _approve(BuildContext context, AttendanceRecord record) async {
    final reviewer = FirebaseAuth.instance.currentUser;
    if (reviewer == null) return;
    await AttendanceApi.approve(recordId: record.id, reviewer: reviewer);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shift approved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat.yMMMd().add_jm();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: AttendanceApi.allRecords(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Failed to load attendance: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final records =
            snapshot.data!.docs.map((d) => AttendanceRecord.fromDoc(d)).toList();
        final open = records.where((r) => r.status == 'open').toList();
        final pending = records.where((r) => r.status == 'pending').toList();
        final approved = records.where((r) => r.status == 'approved').toList();
        final rejected = records.where((r) => r.status == 'rejected').toList();

        final hoursByEmployee = <String, double>{};
        for (final r in approved) {
          hoursByEmployee[r.employeeName] =
              (hoursByEmployee[r.employeeName] ?? 0) + (r.hoursWorked ?? 0);
        }

        if (records.isEmpty) {
          return Center(
            child: Text('No attendance records yet.',
                style: AppText.caption(context)),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (hoursByEmployee.isNotEmpty) ...[
              Text('Approved hours by employee',
                  style: AppText.heading(context)),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: hoursByEmployee.entries
                      .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(e.key,
                                        style: AppText.body(context))),
                                Text('${e.value.toStringAsFixed(2)} hrs',
                                    style: AppText.bodyStrong(context)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (open.isNotEmpty) ...[
              Text('Currently clocked in (${open.length})',
                  style: AppText.heading(context)),
              const SizedBox(height: 12),
              ...open.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.employeeName,
                                    style: AppText.bodyStrong(context)),
                                if (r.clockIn != null)
                                  Text('Since ${format.format(r.clockIn!)}',
                                      style: AppText.caption(context)),
                              ],
                            ),
                          ),
                          _StatusBadge(status: r.status),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
            ],
            Text('Pending approval (${pending.length})',
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
                                child: Text(r.employeeName,
                                    style: AppText.bodyStrong(context))),
                            _StatusBadge(status: r.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${r.clockIn != null ? format.format(r.clockIn!) : ''}'
                          ' → ${r.clockOut != null ? format.format(r.clockOut!) : ''}'
                          '${r.hoursWorked != null ? ' · ${r.hoursWorked!.toStringAsFixed(2)} hrs' : ''}',
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
                              label: 'Approve',
                              onPressed: () => _approve(context, r),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
            if (approved.isNotEmpty || rejected.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('History', style: AppText.heading(context)),
              const SizedBox(height: 12),
              ...[...approved, ...rejected].map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Text(r.employeeName,
                                      style: AppText.bodyStrong(context))),
                              _StatusBadge(status: r.status),
                            ],
                          ),
                          if (r.hoursWorked != null) ...[
                            const SizedBox(height: 4),
                            Text('${r.hoursWorked!.toStringAsFixed(2)} hours',
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
                  )),
            ],
          ],
        );
      },
    );
  }
}
