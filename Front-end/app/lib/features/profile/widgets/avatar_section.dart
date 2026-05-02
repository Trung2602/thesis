import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarSection extends StatelessWidget {
  final File? selectedImage;
  final String avatarUrl;
  final void Function(ImageSource) onPick;

  const AvatarSection({
    super.key,
    required this.selectedImage,
    required this.avatarUrl,
    required this.onPick,
  });

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                onPick(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                onPick(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? get _imageProvider {
    if (selectedImage != null) return FileImage(selectedImage!);
    if (avatarUrl.isNotEmpty) return NetworkImage(avatarUrl);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: _imageProvider,
          child: _imageProvider == null
              ? const Icon(Icons.person, size: 80, color: Colors.white70)
              : null,
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => _showPicker(context),
          icon: const Icon(Icons.image),
          label: const Text('Chọn ảnh'),
        ),
      ],
    );
  }
}