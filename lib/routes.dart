import 'package:devkit/views/image_resizer.dart';
import 'package:devkit/views/regex_tester.dart';
import 'package:flutter/material.dart';

import 'views/checksums.dart';
import 'views/string_transformations.dart';

class Routes {
  static const String initial = home;

  static const String home = '/';
  static const String imageResizer = '/ImageResizer';
  static const String stringTransformations = '/StringTransformations';
  static const String checksums = '/Checksums';
  static const String regexTester = '/RegexTester';

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
        _ => Center(child: Text('Route not found: $name')),
      },
    );
  }
}
