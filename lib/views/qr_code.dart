import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:devkit/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCode extends StatefulWidget {
  const QRCode({super.key});

  @override
  _QRCodeState createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCode> {
  final TextEditingController _controller = TextEditingController();
  String _qrData = '';
  final GlobalKey _qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _qrData = _controller.text;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter text to generate QR Code',
              ),
            ),
            const SizedBox(height: 20),
            if (_qrData.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: InkWell(
                    onTap: () async {
                      try {
                        // Capture the QR code as an image
                        RenderRepaintBoundary boundary = _qrKey.currentContext!
                            .findRenderObject() as RenderRepaintBoundary;
                        ui.Image image = await boundary.toImage(pixelRatio: 3);
                        ByteData? byteData = await image.toByteData(
                            format: ui.ImageByteFormat.rawRgba);
                        Uint8List rgbaBytes = byteData!.buffer.asUint8List();

                        // Convert RGBA to JPEG using image package
                        img.Image rgbaImage = img.Image.fromBytes(
                          width: image.width,
                          height: image.height,
                          bytes: rgbaBytes.buffer,
                          format: img.Format.uint8,
                          numChannels: 4,
                        );

                        // First resize the QR code to fit within the final image with padding
                        // 5% padding means the QR code takes up 90% of the final size
                        int qrSize =
                            (150 * 0.9).round(); // 135 pixels for QR code
                        img.Image resizedQR = img.copyResize(
                          rgbaImage,
                          width: qrSize,
                          height: qrSize,
                          interpolation: img.Interpolation.nearest,
                        );

                        // Create a new 150x150 white background image
                        img.Image finalImage =
                            img.Image(width: 150, height: 150);
                        img.fill(finalImage,
                            color: img.ColorRgb8(255, 255, 255));

                        // Calculate padding to center the QR code
                        int padding = ((150 - qrSize) / 2).round();

                        // Composite the resized QR code onto the white background
                        img.compositeImage(
                          finalImage,
                          resizedQR,
                          dstX: padding,
                          dstY: padding,
                        );

                        Uint8List jpegBytes = Uint8List.fromList(
                            img.encodeJpg(finalImage, quality: 90));

                        // Save to temporary file
                        final directory =
                            (await getApplicationDocumentsDirectory()).path;
                        final imagePath = '$directory/qr_code.jpeg';
                        await File(imagePath).writeAsBytes(jpegBytes);

                        // Copy to clipboard
                        await Pasteboard.writeFiles([imagePath]);
                        Toast.toast('QR code copied to clipboard as JPEG');
                      } catch (e) {
                        Toast.toast('Failed to copy QR code: $e');
                      }
                    },
                    child: RepaintBoundary(
                      key: _qrKey,
                      child: QrImageView(
                        data: _qrData,
                        size: 400.0,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
