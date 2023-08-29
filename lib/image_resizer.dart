import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// import 'image_paster_web.dart';

class ImageResizer extends StatefulWidget {
  ImageResizer({super.key}) {}

  @override
  State<ImageResizer> createState() => _ImageResizerState();
}

class _ImageResizerState extends State<ImageResizer> {
  // late ImagePaster _paster;
  late StreamSubscription _pasteSub;

  ui.Image? _pastedImage;
  Uint8List? _pastedBytes;

  int? _resizedHeight;
  int? _resizedWidth;
  final _resizedHeightCtrl = TextEditingController();
  final _resizedWidthCtrl = TextEditingController();
  Uint8List? get _resizedBytes => _pastedBytes;

  @override
  void initState() {
    // _paster = ImagePaster();
    // _pasteSub = _paster.onPaste.listen(_onImagePaste);
    super.initState();
  }

  @override
  void dispose() {
    // _pasteSub.cancel();
    // _paster.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Focus(
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
    );
  }
}
