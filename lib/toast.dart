import 'package:another_flushbar/flushbar.dart';
import 'package:devkit/main.dart';
import 'package:flutter/material.dart';

class Toast {
  static var _isInitialized = false;
  static late BuildContext _context;

  static void init(BuildContext context) {
    if (_isInitialized) return;
    _context = context;
    _isInitialized = true;
  }

  static void toast(String message) {
    debugPrint('Toast - $message');
    final context = MyApp.navigatorKey.currentContext;
    if (context == null) return;

    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
    ).show(context);
  }
}
