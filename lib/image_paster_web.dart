// import 'dart:async';
// import 'dart:html' as html;

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// class ImagePaster {
//   StreamSubscription? _pasteListener;

//   StreamController<Uint8List> _onPaste = StreamController.broadcast();
//   Stream<Uint8List> get onPaste => _onPaste.stream;

//   ImagePaster() {
//     init();
//   }

//   void init() {
//     if (_pasteListener != null) {
//       throw Exception('Must not be invoked more than once.');
//     }

//     _pasteListener = html.document.onPaste.listen((e) async {
//       debugPrint('onPaste');
//       final blob = e.clipboardData?.items?[0].getAsFile();
//       if (blob != null) {
//         final path = blob.relativePath;
//         if (path != null) {
//           final bytes = await _getFileBytes(blob);
//           if (bytes != null) {
//             _onPaste.add(bytes);
//           }
//         }
//       }
//     });
//   }

//   void dispose() {
//     _pasteListener?.cancel();
//   }

//   Future<Uint8List?> _getFileBytes(html.File file) async {
//     final reader = html.FileReader();
//     reader.readAsArrayBuffer(file);
//     await reader.onLoad.first;
//     return reader.result as Uint8List;
//   }
// }
