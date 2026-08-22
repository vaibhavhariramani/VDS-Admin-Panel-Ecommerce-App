import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

import '../../../services/auth_service.dart';
import '../../../services/data_service.dart';
import '../components/animated_submit_button.dart';
import '../components/labled_textfield.dart';

class UpdateProfileDialog extends StatefulWidget {
  const UpdateProfileDialog({Key? key}) : super(key: key);

  @override
  State<UpdateProfileDialog> createState() => _UpdateProfileDialogState();
}

class _UpdateProfileDialogState extends State<UpdateProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  String? _imgToken;

  @override
  void initState() {
    super.initState();
    final user = AuthService.to.user.value;
    _nameController = TextEditingController(text: user?.fullname ?? '');
    _phoneController = TextEditingController(text: user?.phn_number ?? '');
    _imgToken = user?.img_token;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final String? userId = AuthService.to.user.value?.id;
    if (userId == null) return;
    final String url = await DataService.to.uploadImage(userId);
    if (url.isNotEmpty) {
      setState(() => _imgToken = url);
    }
  }

  Future<void> _save() async {
    final String? userId = AuthService.to.user.value?.id;
    if (userId == null) return;
    if (_nameController.text.trim().isEmpty) {
      BotToast.showText(text: 'Name cannot be empty'.tr);
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'fullname': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        if (_imgToken != null) 'imgToken': _imgToken,
      });
      AuthService.to.user(await AuthService.to.fetchUserDetails(userId));
      BotToast.showText(text: 'Profile updated successfully'.tr);
      Get.back();
    } catch (e) {
      BotToast.showText(text: 'Failed to update profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Update Profile',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    foregroundImage: (_imgToken != null && _imgToken!.isNotEmpty)
                        ? CachedNetworkImageProvider(_imgToken!)
                        : null,
                    child: Icon(
                      IconlyLight.profile,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          LabeledTextField(
            label: 'Full Name',
            isRequired: true,
            textfield: TextField(
              controller: _nameController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(height: 16),
          LabeledTextField(
            label: 'Phone Number',
            textfield: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AnimatedSubmitButton(
                  width: 90,
                  buttonText: 'Cancel',
                  onPressed: () async => Get.back(),
                ),
                AnimatedSubmitButton(
                  width: 90,
                  buttonText: 'Save',
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
