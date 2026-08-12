import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'staff_api.dart';

/// Super-admin-only screen to grant or revoke admin-panel access by email.
/// Backed by the `setStaffRole` Cloud Function (which sets the custom claim
/// this app's login gate and Firestore rules check) and the `Staff`
/// collection it maintains as a readable roster.
class ManageStaffScreen extends StatefulWidget {
  const ManageStaffScreen({Key? key}) : super(key: key);

  @override
  State<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends State<ManageStaffScreen> {
  final _emailController = TextEditingController();
  String _role = 'employee';
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _grantAccess() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter an email address.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await StaffApi.setStaffRole(email: email, role: _role);
      _emailController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Access granted to $email.')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _revoke(String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke access?'),
        content: Text('$email will no longer be able to sign in to the admin panel.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await StaffApi.setStaffRole(email: email, role: 'none');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Access revoked for $email.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to revoke access: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appCanvas(context),
      appBar: AppBar(
        title: const Text('Manage Staff'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Grant access', style: AppText.heading(context)),
                const SizedBox(height: 4),
                Text(
                  'The person must have signed in at least once (e.g. via Google sign-in) before you can grant them a role.',
                  style: AppText.caption(context),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'employee', child: Text('Employee')),
                    DropdownMenuItem(
                        value: 'superadmin', child: Text('Super Admin')),
                  ],
                  onChanged: (v) => setState(() => _role = v ?? 'employee'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: PillButton(
                    label: _isSubmitting ? 'Granting…' : 'Grant access',
                    onPressed: _isSubmitting ? null : _grantAccess,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Current staff', style: AppText.heading(context)),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Staff')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  'Failed to load staff list: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return Text('No staff granted access yet.',
                    style: AppText.caption(context));
              }
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final email = (data['email'] ?? '').toString();
                  final role = (data['role'] ?? '').toString();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(email, style: AppText.bodyStrong(context)),
                                const SizedBox(height: 2),
                                Text(
                                  role == 'superadmin'
                                      ? 'Super Admin'
                                      : 'Employee',
                                  style: AppText.caption(context),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _revoke(email),
                            child: const Text('Revoke',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
