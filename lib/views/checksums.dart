import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:devkit/string_extensions.dart';
import 'package:devkit/toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Checksums extends StatefulWidget {
  const Checksums({super.key});

  @override
  State<Checksums> createState() => _ChecksumsState();
}

class _ChecksumsState extends State<Checksums> {
  PlatformFile? _pickedFile;

  Uint8List? get _bytes => _pickedFile?.bytes;
  String get _fileName => _pickedFile?.name ?? '';
  String get _fileSize => _pickedFile?.size.readableFileSize() ?? '';

  String get _md5 {
    if (_bytes == null) return '';

    final result = md5.convert(_bytes!).toString();
    return result;
  }

  String get _sha256 {
    if (_bytes == null) return '';

    return sha256.convert(_bytes!).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final pickResult = await FilePicker.platform.pickFiles(
                    withData: true,
                    allowCompression: false,
                  );
                  if (pickResult != null && pickResult.files.isNotEmpty) {
                    setState(() => _pickedFile = pickResult.files.first);
                  }
                },
                child: const Text('Choose a File'),
              ),
              const SizedBox(width: 16),
              if (_fileName.isNotEmpty) ...[
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: _fileName),
                      const TextSpan(text: ' '),
                      TextSpan(text: '($_fileSize)'),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (_pickedFile != null) ...[
            const Divider(),
            CopyableRow(label: 'MD5', data: _md5),
            CopyableRow(label: 'SHA-256', data: _sha256),
          ],
        ],
      ),
    );
  }
}

class CopyableRow extends StatelessWidget {
  final String label;
  final String data;

  const CopyableRow({
    super.key,
    required this.label,
    required this.data,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label),
          ),
          Text(data),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: data));
              Toast.toast('Copied to clipboard');
            },
          ),
        ],
      );
}
