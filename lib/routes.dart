import 'package:flutter/material.dart';

import 'views/checksums.dart';
import 'views/generators.dart';
import 'views/image_resizer.dart';
import 'views/regex_tester.dart';
import 'views/string_transformations.dart';
import 'views/qr_code.dart';
import 'views/image_generator.dart';

class Routes {
  static const String initial = home;

  static const String home = '/';
  static const String imageResizer = '/ImageResizer';
  static const String stringTransformations = '/StringTransformations';
  static const String checksums = '/Checksums';
  static const String regexTester = '/RegexTester';
  static const String generators = '/Generators';
  static const String qrCode = '/QRCode';
  static const String imageGenerator = '/ImageGenerator';

  static Route onGenerateRoute(RouteSettings settings) {
    final name = settings.name;

    return PageRouteBuilder(
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => switch (name) {
        home => const Center(child: Text('Choose a tool')),
        imageResizer => const ImageResizer(),
        stringTransformations => const StringTransformations(),
        checksums => const Checksums(),
        regexTester => const RegexTester(),
        generators => const Generators(),
        qrCode => const QRCode(),
        imageGenerator => const ImageGenerator(),
        _ => Center(child: Text('Route not found: $name')),
      },
    );
  }
}
