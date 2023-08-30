import 'package:intl/intl.dart';

extension FileFormatter on num {
  String readableFileSize({bool base1024 = true}) {
    final base = base1024 ? 1024 : 1000;
    if (this <= 0) return "0 B";

    final gb = base * base * base;
    final mb = base * base;
    final kb = base;

    double output;
    String unit;
    if (this > gb) {
      output = this / gb;
      unit = "GB";
    } else if (this > mb) {
      output = this / mb;
      unit = "MB";
    } else if (this > kb) {
      output = this / kb;
      unit = "KB";
    } else {
      output = toDouble();
      unit = "B";
    }

    final formatted = NumberFormat("#,##0.#").format(output);
    return '$formatted $unit';
  }
}
