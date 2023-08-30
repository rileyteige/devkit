import 'package:devkit/image_resizer.dart';
import 'package:flutter/material.dart';

import 'string_transformations.dart';

class Routes {
  static const String initial = home;

  static const String home = '/';
  static const String imageResizer = '/ImageResizer';
  static const String stringTransformations = '/StringTransformations';

  static final Map<String, WidgetBuilder> all = {
    home: (context) => const Center(child: Text('Choose a tool')),
    imageResizer: (context) => const ImageResizer(),
    stringTransformations: (context) => const StringTransformations(),
  };
}
