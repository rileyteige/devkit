import 'package:devkit/clippy.dart';
import 'package:devkit/lorem_ipsum.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Generators extends StatefulWidget {
  const Generators({super.key});

  @override
  State<Generators> createState() => _GeneratorsState();
}

class _GeneratorsState extends State<Generators> {
  late String _v1;
  late String _v4;
  late String _loremIpsum;

  @override
  void initState() {
    _generateV1UUID();
    _generateV4UUID();
    _loremIpsum = LoremIpsum.long;
    super.initState();
  }

  void _generateV1UUID() => setState(() => _v1 = const Uuid().v1());
  void _generateV4UUID() => setState(() => _v4 = const Uuid().v4());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CopyableRow(
            label: 'UUID V1',
            value: _v1,
            onRefresh: _generateV1UUID,
          ),
          CopyableRow(
            label: 'UUID V4',
            value: _v4,
            onRefresh: _generateV4UUID,
          ),
          CopyableRow(
            label: 'Lorem Ipsum',
            value: '${_loremIpsum.substring(0, 40)}...',
            onCopy: () {
              Clippy.copy(_loremIpsum);
            },
          ),
        ],
      ),
    );
  }
}

class CopyableRow extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback? onRefresh;
  final VoidCallback? onCopy;

  const CopyableRow({
    super.key,
    required this.label,
    this.value,
    this.onRefresh,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final value = this.value;

    return Row(
      children: [
        InkWell(
          onTap: value != null ? (onCopy ?? () => Clippy.copy(value)) : null,
          child: SizedBox(
            height: 40,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (value != null) ...[
                    Text(value),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (onRefresh != null) ...[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
          ),
        ],
      ],
    );
  }
}
