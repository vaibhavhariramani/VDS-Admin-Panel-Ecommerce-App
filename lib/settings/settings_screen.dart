import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme_controller.dart';
import 'store_settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _storeAddressController = TextEditingController();

  bool _savingProfile = false;
  bool _savingStore = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nameController.text = _user?.displayName ?? '';
    _storeNameController.text = StoreSettingsController.storeName.value;
    _storeAddressController.text = StoreSettingsController.storeAddress.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _storeNameController.dispose();
    _storeAddressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _savingProfile = true);
    try {
      final user = _user;
      if (user != null) {
        await user.updateDisplayName(name);
        await FirebaseFirestore.instance
            .collection('Admins')
            .doc(user.uid)
            .set({'fullName': name}, SetOptions(merge: true));
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fullname', name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _saveStoreSettings() async {
    final name = _storeNameController.text.trim();
    final address = _storeAddressController.text.trim();
    if (name.isEmpty || address.isEmpty) return;
    setState(() => _savingStore = true);
    try {
      await StoreSettingsController.save(name: name, address: address);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Store details updated.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update store details: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingStore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xff23262b) : Colors.white;
    final mutedText = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: const Color(0xffF3AB0D),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SectionCard(
                color: cardColor,
                title: 'Profile',
                icon: Icons.person_outline,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor:
                        isDark ? Colors.white12 : const Color(0xffF3AB0D),
                    child: Text(
                      (_nameController.text.isNotEmpty
                              ? _nameController.text[0]
                              : '?')
                          .toUpperCase(),
                      style: const TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_user?.email ?? '', style: TextStyle(color: mutedText)),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _savingProfile ? null : _saveProfile,
                      child: _savingProfile
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save profile'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionCard(
                color: cardColor,
                title: 'Appearance',
                icon: Icons.palette_outlined,
                children: [
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: ThemeController.themeMode,
                    builder: (context, mode, _) {
                      return SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Dark mode'),
                        value: mode == ThemeMode.dark,
                        onChanged: (_) => ThemeController.toggle(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionCard(
                color: cardColor,
                title: 'Store details',
                icon: Icons.storefront_outlined,
                children: [
                  Text(
                    'Used on generated invoices.',
                    style: TextStyle(color: mutedText, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _storeNameController,
                    decoration: const InputDecoration(
                      labelText: 'Store name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _storeAddressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Store address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _savingStore ? null : _saveStoreSettings,
                      child: _savingStore
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save store details'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Color color;
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.color,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
