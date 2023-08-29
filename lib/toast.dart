import 'package:another_flushbar/flushbar.dart';
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
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
    ).show(_context);
  }
}
