import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:archive/archive.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:pasteboard/pasteboard.dart';
import 'dart:math' as math;

class ImageGenerator extends StatefulWidget {
  const ImageGenerator({super.key});

  @override
  State<ImageGenerator> createState() => _ImageGeneratorState();
}

class _ImageGeneratorState extends State<ImageGenerator> {
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _widthController =
      TextEditingController(text: '1600');
  List<Widget> _generatedImages = [];
  List<ui.Image> _rawImages = []; // Add this line to store raw images

  void _drawMetallicBackground(Canvas canvas, Size size) {
    // Metallic gradient background
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.grey[800]!,
        Colors.grey[600]!,
        Colors.grey[400]!,
        Colors.grey[600]!,
        Colors.grey[800]!,
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Add techno pattern
    final patternPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0;

    // Draw grid lines
    const gridSize = 50.0;
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        patternPaint,
      );
    }
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        patternPaint,
      );
    }

    // Add some random tech circles
    final random = math.Random(42); // Fixed seed for consistent pattern
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 30 + 10;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = Colors.blue.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  Future<ui.Image> _generateSingleImage(
    int number,
    double width,
    double height,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width, height);

    // Draw techno-metallic background
    _drawMetallicBackground(canvas, size);

    // Draw number with slightly modified style
    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: height / 1.5,
          fontWeight: FontWeight.bold,
          shadows: [
            const Shadow(
              color: Colors.black54,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    return picture.toImage(width.toInt(), height.toInt());
  }

  Future<void> _copyImageToClipboard(ui.Image image) async {
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes != null) {
        final directory = (await getApplicationDocumentsDirectory()).path;
        final imagePath = '$directory/image.png';
        await File(imagePath).writeAsBytes(bytes.buffer.asUint8List());
        await Pasteboard.writeFiles([imagePath]);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image copied to clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to copy image: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _generateImages() async {
    final int count = int.tryParse(_numberController.text) ?? 0;
    if (count <= 0) return;

    final double width = double.tryParse(_widthController.text) ?? 1600;

    final List<Widget> newImages = [];
    final List<ui.Image> newRawImages = [];

    for (int i = 0; i < count; i++) {
      final image = await _generateSingleImage(i + 1, width, width / (4 / 3));
      newRawImages.add(image);
      final imageWidget = GestureDetector(
        onTap: () => _copyImageToClipboard(image),
        child: RawImage(
          image: image,
          width: 400,
          height: 300,
        ),
      );
      newImages.add(imageWidget);
    }

    setState(() {
      _generatedImages = newImages;
      _rawImages = newRawImages;
    });
  }

  Future<String> _getDownloadsPath() async {
    if (Platform.isMacOS || Platform.isLinux) {
      final home = Platform.environment['HOME'];
      return path.join(home!, 'Downloads');
    } else if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      return path.join(userProfile!, 'Downloads');
    }
    throw UnsupportedError('Unsupported platform for downloads');
  }

  Future<void> _archiveImages() async {
    if (_rawImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images to archive')),
      );
      return;
    }

    try {
      final archive = Archive();

      for (var i = 0; i < _rawImages.length; i++) {
        final image = _rawImages[i];
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();

        final archiveFile = ArchiveFile(
          'image_${i + 1}.png',
          bytes.length,
          bytes,
        );
        archive.addFile(archiveFile);
      }

      // Get downloads directory
      final downloadsPath = await _getDownloadsPath();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final zipFile =
          File(path.join(downloadsPath, 'generated_images_$timestamp.zip'));

      final zipBytes = ZipEncoder().encode(archive);
      await zipFile.writeAsBytes(zipBytes!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Images archived to ${zipFile.path}'),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to archive images: $e')),
      );
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _widthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _numberController,
                    decoration: const InputDecoration(
                      labelText: 'Enter a number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _widthController,
                    decoration: const InputDecoration(
                      labelText: 'Width (px)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _generateImages(),
                  child: const Text('Generate'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _archiveImages,
                  icon: const Icon(Icons.archive),
                  label: const Text('Archive'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 4 / 3, // 4:3 aspect ratio
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _generatedImages.length,
                itemBuilder: (context, index) => _generatedImages[index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
