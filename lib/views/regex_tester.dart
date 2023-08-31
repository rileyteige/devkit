import 'package:devkit/sidebar.dart';
import 'package:flutter/material.dart';

class RegexTester extends StatefulWidget {
  const RegexTester({super.key});

  @override
  State<RegexTester> createState() => _RegexTesterState();
}

class _RegexTesterState extends State<RegexTester> {
  final _srcCtrl = TextEditingController();
  final _patternCtrl = TextEditingController();

  var _pattern = RegExp(r'(?!)');
  var _invalidPattern = false;
  Iterable<RegExpMatch>? _matches;

  void _onSourceChanged(String value) {
    if (value.isNotEmpty) {
      _test();
    } else {
      setState(() => _matches = null);
    }
  }

  void _onPatternChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _pattern = RegExp(r'(?!)');
        _invalidPattern = false;
        _matches = null;
      });

      return;
    }

    try {
      final pattern = RegExp(value, multiLine: true);
      setState(() {
        _pattern = pattern;
        _invalidPattern = false;
      });
    } catch (_) {
      setState(() {
        _pattern = RegExp(r'(?!)');
        _invalidPattern = true;
      });
    }

    _test();
  }

  void _test() {
    try {
      final matches = _pattern.allMatches(_srcCtrl.text);
      setState(() => _matches = matches);
    } catch (_) {
      setState(() => _matches = null);
    }
  }

  Widget _renderMatchGroups(RegExpMatch match) {
    final children = <InlineSpan>[];
    final fullCapture = match.group(0) ?? '';
    children.add(TextSpan(
      text: fullCapture,
      style: TextStyle(
        color: Theme.of(context).primaryColorLight,
      ),
    ));
    children.add(const TextSpan(text: '\n'));

    if (match.groupNames.isNotEmpty) {
      for (var name in match.groupNames) {
        final group = match.namedGroup(name);
        children.add(TextSpan(text: '$name: $group'));
      }
    } else {
      for (var i = 1; i < match.groupCount + 1; i++) {
        final group = match.group(i);
        children.add(TextSpan(text: '$i: $group'));
      }
    }

    return SelectableText.rich(TextSpan(children: children));
  }

  Widget _renderMatches(Iterable<RegExpMatch> matches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: matches
          .map((match) => _renderMatchGroups(match))
          .intersperse(const Divider())
          .toList(),
    );
    // return Text('${matches.length} match${matches.length > 1 ? "es" : ""}');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _srcCtrl,
            minLines: 1,
            maxLines: 10,
            onChanged: _onSourceChanged,
            decoration: const InputDecoration(
              labelText: 'Source',
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: _patternCtrl,
            minLines: 1,
            maxLines: 5,
            onChanged: _onPatternChanged,
            decoration: const InputDecoration(
              labelText: 'Regex',
              border: OutlineInputBorder(),
            ),
          ),
          if (_patternCtrl.text.isNotEmpty) ...[
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(8),
                child: _matches != null && _matches!.isEmpty
                    ? const Text('No Matches')
                    : _invalidPattern
                        ? const Text('Invalid Pattern')
                        : _matches == null
                            ? Container()
                            : SingleChildScrollView(
                                child: _renderMatches(_matches!),
                              ),
              ),
            ),
          ],
        ].intersperse(const SizedBox(height: 8)).toList(),
      ),
    );
  }
}
