import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:devkit/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:image/image.dart' as image;
import 'package:path_provider/path_provider.dart';

class ImageResizer extends StatefulWidget {
  ImageResizer({super.key}) {}

  @override
  State<ImageResizer> createState() => _ImageResizerState();
}

class _ImageResizerState extends State<ImageResizer>
    with WidgetsBindingObserver {
  ui.Image? _pastedImage;
  Uint8List? _pastedBytes;

  int? _resizedHeight;
  int? _resizedWidth;
  final _resizedHeightCtrl = TextEditingController();
  final _resizedWidthCtrl = TextEditingController();
  Uint8List? _resizedBytes;

  final focusNode = FocusNode();
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      focusNode.requestFocus();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  void _onImagePaste(Uint8List bytes) {
    setState(() {
      _pastedBytes = bytes;
      _resizedBytes = bytes;
    });

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

  double? get aspectRatio {
    final img = _pastedImage;
    if (img == null) return null;

    final ui.Image(:width, :height) = img;
    if (width == 0 || height == 0) return null;

    return width.toDouble() / height.toDouble();
  }

  int _aspectWidth(int height, double aspectRatio) =>
      (aspectRatio * height).round();
  int _aspectHeight(int width, double aspectRatio) =>
      (width.toDouble() / aspectRatio).round();

  int get _pastedSize => _pastedBytes?.length ?? 0;
  int get _resizedSize => _resizedBytes?.length ?? 0;

  Future _resize() async {
    debugPrint('_resize');
    if (_pastedBytes == null) return;
    final decoded = image.decodeImage(_pastedBytes!);
    if (decoded == null) return;

    final scaled = image.copyResize(
      decoded,
      width: _resizedWidth,
      height: _resizedHeight,
      interpolation: image.Interpolation.cubic,
    );

    final scaledBytes = image.encodePng(scaled);

    setState(() => _resizedBytes = scaledBytes);
  }

  void _clampDimensions(int maxDim) {
    final pastedImg = _pastedImage;
    final aspectRatio = this.aspectRatio;
    if (pastedImg == null || aspectRatio == null) return;

    final ui.Image(:width, :height) = pastedImg;
    if (width > height && width > maxDim) {
      final newHeight = _aspectHeight(maxDim, aspectRatio);
      setState(() {
        _resizedWidth = maxDim;
        _resizedHeight = newHeight;
        _resizedWidthCtrl.text = '$_resizedWidth';
        _resizedHeightCtrl.text = '$_resizedHeight';
      });

      _resize();
    } else {
      final newWidth = _aspectWidth(maxDim, aspectRatio);
      setState(() {
        _resizedWidth = newWidth;
        _resizedHeight = maxDim;
        _resizedWidthCtrl.text = '$_resizedWidth';
        _resizedHeightCtrl.text = '$_resizedHeight';
      });

      _resize();
    }
  }

  Widget _buildImageModifiers(ui.Image img) {
    final pastedImg = _pastedImage;
    final aspectRatio = this.aspectRatio;
    const textFieldWidth = 64.0;
    if (pastedImg == null || aspectRatio == null) return Container();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () => _clampDimensions(400),
          child: const Text('400px'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _clampDimensions(600),
          child: const Text('600px'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _clampDimensions(800),
          child: const Text('800px'),
        ),
        const SizedBox(width: 32),
        SizedBox(
          width: textFieldWidth,
          child: TextField(
            controller: _resizedWidthCtrl,
            decoration: const InputDecoration(
              suffix: Text('px'),
            ),
            onChanged: (value) {
              final width = int.tryParse(value);
              if (width == null || width <= 0) return;
              final aspect = aspectRatio;
              final newHeight = _aspectHeight(width, aspect);

              setState(() {
                _resizedWidth = width;
                _resizedHeight = newHeight;
              });
              _resizedHeightCtrl.text = '$newHeight';
            },
            onSubmitted: (_) => _resize(),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: textFieldWidth,
          child: TextField(
            controller: _resizedHeightCtrl,
            decoration: const InputDecoration(
              suffix: Text('px'),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              final height = int.tryParse(value);
              if (height == null || height <= 0) return;
              final aspect = aspectRatio;
              final newWidth = _aspectWidth(height, aspect);

              setState(() {
                _resizedWidth = newWidth;
                _resizedHeight = height;
              });
              _resizedWidthCtrl.text = '$newWidth';
            },
            onSubmitted: (_) => _resize(),
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
          focusNode: focusNode,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                      const SizedBox(height: 8),
                      Expanded(
                          child: Stack(
                        children: [
                          Center(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.memory(_pastedBytes!),
                          )),
                          Center(
                            child: Container(
                              color: Colors.black54,
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ImageOverlayText(
                                    '${_pastedImage?.width}x${_pastedImage?.height}',
                                  ),
                                  ImageOverlayText(
                                    _pastedBytes!.length.readableFileSize(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Stack(
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints.expand(),
                              child: InkWell(
                                onTap: () async {
                                  final directory =
                                      (await getApplicationDocumentsDirectory())
                                          .path;
                                  final imagePath = '$directory/image.png';
                                  await File(imagePath)
                                      .writeAsBytes(_resizedBytes!.toList());
                                  await Pasteboard.writeFiles([imagePath]);
                                  Toast.toast('Copied to clipboard');
                                },
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.memory(_resizedBytes!,
                                            fit: BoxFit.contain),
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        color: Colors.black54,
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ImageOverlayText(
                                              '${_resizedWidth}x$_resizedHeight',
                                            ),
                                            ImageOverlayText(
                                              _resizedBytes!.length
                                                  .readableFileSize(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Builder(builder: (context) {
                        if (_resizedWidth == null || _pastedImage == null) {
                          return const Text('No Image');
                        }

                        final originalWidth = _pastedImage?.width ?? 0;
                        final originalHeight = _pastedImage?.height ?? 0;

                        final original =
                            Dimensions(originalWidth, originalHeight);
                        final newDim =
                            Dimensions(_resizedWidth!, _resizedHeight!);

                        final savings = _pastedSize > 0
                            ? (1 - _resizedSize / _pastedSize) * 100
                            : 0;

                        return Text(
                          '$original -> $newDim: '
                          '${savings.toStringAsFixed(0)}% reduction',
                        );
                      }),
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
      ),
    );
  }
}

class Dimensions {
  final int width;
  final int height;

  Dimensions(this.width, this.height) {
    RangeError.checkNotNegative(width, 'width');
    RangeError.checkNotNegative(height, 'height');
  }

  @override
  String toString() => '${width}x$height';
}

class ImageOverlayText extends StatelessWidget {
  final String message;
  const ImageOverlayText(this.message, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        message,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 32,
        ),
      );
}

class PasteIntent extends Intent {
  const PasteIntent();
}

extension FileFormatter on num {
  String readableFileSize({bool base1024 = true}) {
    final base = base1024 ? 1024 : 1000;
    if (this <= 0) return "0 B";

    final gb = base * base * base;
    final mb = base * base;
    final kb = base;

    double output;
    String unit;
    if (this > gb) {
      output = this / gb;
      unit = "GB";
    } else if (this > mb) {
      output = this / mb;
      unit = "MB";
    } else if (this > kb) {
      output = this / kb;
      unit = "KB";
    } else {
      output = toDouble();
      unit = "B";
    }

    final formatted = NumberFormat("#,##0.#").format(output);
    return '$formatted $unit';
  }
}
