import 'package:devkit/image_resizer.dart';
import 'package:devkit/regex_tester.dart';
import 'package:flutter/material.dart';

import 'hashes.dart';
import 'string_transformations.dart';

class Routes {
  static const String initial = home;

  static const String home = '/';
  static const String imageResizer = '/ImageResizer';
  static const String stringTransformations = '/StringTransformations';
  static const String hashes = '/Hashes';
  static const String regexTester = '/RegexTester';

  static final Map<String, WidgetBuilder> all = {
    home: (_) => const Center(child: Text('Choose a tool')),
    imageResizer: (_) => const ImageResizer(),
    stringTransformations: (_) => const StringTransformations(),
    hashes: (_) => const Hashes(),
    regexTester: (_) => const RegexTester(),
  };

  static Route onGenerateRoute(RouteSettings settings) {
    final name = settings.name;

    return PageRouteBuilder(
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => switch (name) {
        home => const Center(child: Text('Choose a tool')),
        imageResizer => const ImageResizer(),
        _ => Center(child: Text('Route not found: $name')),
      },
    );
  }
}
