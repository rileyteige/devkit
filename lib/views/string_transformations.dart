import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:devkit/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../toast.dart';

class StringTransformations extends StatefulWidget {
  const StringTransformations({super.key});

  @override
  State<StringTransformations> createState() => _StringTransformationsState();
}

typedef StringTransformer = String Function(String);

enum StringTransformation {
  upper,
  lower,
  crazy,
  md5,
  singleLine,
  html,
  uri,
  query,
}

Set<StringTransformation> exclusiveTransforms = {
  StringTransformation.upper,
  StringTransformation.lower,
  StringTransformation.crazy,
  StringTransformation.md5,
  StringTransformation.html,
  StringTransformation.uri,
  StringTransformation.query,
};

extension Sets on Set<StringTransformation> {
  void toggle(StringTransformation x) {
    if (contains(x)) {
      remove(x);
    } else {
      add(x);
    }
  }
}

extension StringX on String {
  isAz({caseSensitive = true}) {
    final target = caseSensitive ? this : toLowerCase();
    return target.codeUnitAt(0) > 96 && target.codeUnitAt(0) < 123;
  }
}

class _StringTransformationsState extends State<StringTransformations> {
  final _srcCtrl = TextEditingController();
  var _source = '';
  final _selectedTransforms = <StringTransformation>{};

  static StringTransformer _mapTransform(StringTransformation x) => switch (x) {
        StringTransformation.upper => _toUpper,
        StringTransformation.lower => _toLower,
        StringTransformation.crazy => _toCrazy,
        StringTransformation.md5 => _toMD5,
        StringTransformation.singleLine => _toSingleLine,
        StringTransformation.html => _encodeHtml,
        StringTransformation.uri => _encodeUriComponent,
        StringTransformation.query => _encodeUriQuery,
      };

  static String _toLower(String x) => x.toLowerCase();
  static String _toUpper(String x) => x.toUpperCase();
  static String _toSingleLine(String x) {
    final buf = StringBuffer();
    for (final line in x.split(RegExp('(\r)?\n+'))) {
      buf.write(line.trim());
    }
    return buf.toString();
  }

  static String _encodeHtml(String x) => const HtmlEscape().convert(x);
  static String _encodeUriComponent(String x) => Uri.encodeComponent(x);
  static String _encodeUriQuery(String x) => Uri.encodeQueryComponent(x);

  static String _toCrazy(String x) {
    StringBuffer buf = StringBuffer();

    var upper = true;
    for (var c in x.characters) {
      if (c.isAz(caseSensitive: false)) {
        if (upper) {
          buf.write(c.toUpperCase());
          upper = false;
        } else {
          buf.write(c.toLowerCase());
          upper = true;
        }
      } else {
        buf.write(c);
      }
    }

    return buf.toString();
  }

  static String _toMD5(String x) {
    if (x.isEmpty) {
      return '';
    }

    return md5.convert(utf8.encode(x)).toString();
  }

  String get _output {
    final transforms = _selectedTransforms;
    if (transforms.isEmpty) return _source;

    var result = _source;
    for (final transform in transforms.map(_mapTransform)) {
      result = transform(result);
    }

    return result;
  }

  Widget _modifiers() {
    Widget chip(
      String label,
      StringTransformation t, {
      ValueChanged<StringTransformation>? onSelected,
    }) =>
        ChoiceChip(
          label: Text(label),
          selected: _selectedTransforms.contains(t),
          onSelected: (newValue) {
            if (onSelected != null) {
              onSelected(t);
            } else if (newValue) {
              setState(() {
                _selectedTransforms.removeAll(exclusiveTransforms);
                _selectedTransforms.add(t);
              });
            } else {
              setState(() => _selectedTransforms.remove(t));
            }
          },
        );

    return Row(
      children: <Widget>[
        chip('Lower', StringTransformation.lower),
        chip('Upper', StringTransformation.upper),
        chip('Crazy', StringTransformation.crazy),
        chip('HTML', StringTransformation.html),
        chip('URI', StringTransformation.uri),
        chip('Query', StringTransformation.query),
        chip('MD5', StringTransformation.md5),
        chip(
          'Single-Line',
          StringTransformation.singleLine,
          onSelected: (_) => setState(() =>
              _selectedTransforms.toggle(StringTransformation.singleLine)),
        ),
      ].intersperse(const SizedBox(width: 8)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.75,
                  child: TextField(
                    controller: _srcCtrl,
                    minLines: 1,
                    maxLines: 15,
                    decoration: const InputDecoration(
                      labelText: 'Source',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() => _source = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _modifiers(),
              const Divider(height: 32),
              Flexible(
                child: TransformedOutput(_output),
              )
            ],
          ),
        ),
      );
}

class TransformedOutput extends StatelessWidget {
  final String text;
  const TransformedOutput(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        constraints: const BoxConstraints(minHeight: 300),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Stack(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: SingleChildScrollView(
                  child: SelectableText(text),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FloatingActionButton(
                    child: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: text));
                      Toast.toast('Copied to clipboard');
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      );
}
