import 'package:devkit/toast.dart';
import 'package:flutter/services.dart';

class Clippy {
  static Future copy(String x) async {
    if (x.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: x));
    Toast.toast('Copied to clipboard.');
  }
}
