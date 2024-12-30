import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Ensure this import is correct

class QRCode extends StatefulWidget {
  const QRCode({super.key});

  @override
  _QRCodeState createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCode> {
  final TextEditingController _controller = TextEditingController();
  String _qrData = '';

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
                  child: QrImageView(
                    data: _qrData,
                    size: 400.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
