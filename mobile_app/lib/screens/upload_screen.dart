import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/detection_provider.dart';
import 'result_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedFile;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source, imageQuality: 90);
    if (file != null) {
      setState(() {
        _selectedFile = file;
      });
    }
  }

  Future<void> _upload(BuildContext context) async {
    final navigator = Navigator.of(context);
    final provider = context.read<DetectionProvider>();
    final file = _selectedFile;
    if (file == null) return;

    await provider.uploadAndDetect(file);
    navigator.push(
      MaterialPageRoute(builder: (_) => const ResultScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DetectionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Vehicle Image')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _selectedFile == null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_car, size: 64, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text('Select an image to begin', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700])),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(_selectedFile!.path), fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            if (provider.lastError != null)
              Text(provider.lastError!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: provider.isUploading || _selectedFile == null ? null : () => _upload(context),
                icon: provider.isUploading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_upload),
                label: Text(provider.isUploading ? 'Uploading...' : 'Upload & Detect'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
