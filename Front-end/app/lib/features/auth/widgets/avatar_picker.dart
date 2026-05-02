import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarPicker extends StatelessWidget {
  final File? selectedImage;
  final void Function(ImageSource source) onPick;

  const AvatarPicker({
    super.key,
    required this.selectedImage,
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage:
          selectedImage != null ? FileImage(selectedImage!) : null,
          child: selectedImage == null
              ? const Icon(Icons.person, size: 40)
              : null,
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => _showPicker(context),
          icon: const Icon(Icons.image),
          label: const Text('Chọn ảnh'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFAB40),
            foregroundColor: const Color(0xFF1A237E),
          ),
        ),
      ],
    );
  }
}