import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pasteboard/pasteboard.dart';

class ImageResizer extends StatefulWidget {
  ImageResizer({super.key}) {}

  @override
  State<ImageResizer> createState() => _ImageResizerState();
}

class _ImageResizerState extends State<ImageResizer> {
  ui.Image? _pastedImage;
  Uint8List? _pastedBytes;

  int? _resizedHeight;
  int? _resizedWidth;
  final _resizedHeightCtrl = TextEditingController();
  final _resizedWidthCtrl = TextEditingController();
  Uint8List? get _resizedBytes => _pastedBytes;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onImagePaste(Uint8List bytes) {
    setState(() => _pastedBytes = bytes);
    ui.decodeImageFromList(bytes, (img) {
      setState(() {
        _pastedImage = img;
        _resizedHeight = img.height;
        _resizedWidth = img.width;
        _resizedHeightCtrl.text = '$_resizedHeight';
        _resizedWidthCtrl.text = '$_resizedWidth';
      });
    });
  }

  static const pasteMeta = SingleActivator(LogicalKeyboardKey.keyV, meta: true);

  Widget _buildImageModifiers(ui.Image img) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: TextField(
            controller: _resizedHeightCtrl,
            onChanged: (value) => {},
          ),
        ),
        Flexible(
          child: TextField(
            controller: _resizedWidthCtrl,
          ),
        ),
      ],
    );
  }

  Future _onPasteEvent() async {
    final clipData = await Pasteboard.image;
    if (clipData != null) {
      _onImagePaste(clipData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        pasteMeta: PasteIntent(),
      },
      child: Actions(
        actions: {
          PasteIntent: CallbackAction<PasteIntent>(
            onInvoke: (e) => _onPasteEvent(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: Builder(
            builder: (context) {
              if (_pastedBytes != null) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_pastedImage != null) ...[
                      _buildImageModifiers(_pastedImage!),
                    ],
                    Expanded(child: Image.memory(_pastedBytes!)),
                    Expanded(
                      child: InkWell(
                        onTap: () async {},
                        child: Image.memory(_resizedBytes!),
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: Text('Paste an image from the clipboard'),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class PasteIntent extends Intent {
  const PasteIntent();
}
