import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../theme/app_theme.dart';

/// A square image preview with a pill "Change photo"/"Add photo" control,
/// used for the Add Item / Manage Category / Manage Banners image-upload
/// flows (previously copy-pasted near-verbatim in each screen). Picks a
/// jpg/png via file_picker (works uniformly on web, unlike image_picker's
/// split gallery/camera/web code paths), uploads to Firebase Storage under
/// [storagePathPrefix], and reports the resulting download URL.
class ImageUploadField extends StatefulWidget {
  final String label;
  final String storagePathPrefix;
  final String? initialImageUrl;
  final ValueChanged<String> onUploaded;
  final double size;

  const ImageUploadField({
    Key? key,
    required this.label,
    required this.storagePathPrefix,
    required this.onUploaded,
    this.initialImageUrl,
    this.size = 140,
  }) : super(key: key);

  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  String? _imageUrl;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  Future<void> _pickAndUpload() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not open file picker: $e');
      return;
    }
    if (result == null) return;

    final Uint8List? bytes = result.files.single.bytes;
    if (bytes == null) {
      Fluttertoast.showToast(msg: 'Could not read the selected file.');
      return;
    }

    setState(() => _uploading = true);
    try {
      final ref = FirebaseStorage.instance.ref().child(
          '${widget.storagePathPrefix}/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}');
      await ref.putData(bytes);
      final downloadUrl = await ref.getDownloadURL();
      setState(() => _imageUrl = downloadUrl);
      widget.onUploaded(downloadUrl);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Upload failed: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppText.caption(context)),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: _uploading ? null : _pickAndUpload,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: appHairline(context)),
              color: appSurface(context),
              image: _imageUrl != null && _imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: _uploading
                ? const Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (_imageUrl == null || _imageUrl!.isEmpty)
                    ? Center(
                        child: Icon(Icons.add_a_photo_outlined,
                            color: AppColors.primaryDark, size: 28),
                      )
                    : Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 14),
                        ),
                      ),
          ),
        ),
      ],
    );
  }
}
