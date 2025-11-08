import 'package:flutter/material.dart';

class DebugOption extends StatefulWidget {
  final String title;
  final String description;
  final bool enabled;

  const DebugOption({
    super.key,
    required this.title,
    required this.description,
    this.enabled = false
  });

  @override
  State<DebugOption> createState() => _DebugOptionState();
}

class _DebugOptionState extends State<DebugOption> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.enabled;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width-32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              // border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(30), 
                  spreadRadius: 2, 
                  blurRadius: 2,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.description.isNotEmpty)
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 12, 
                            color: Theme.of(context).colorScheme.onSurfaceVariant
                          ),
                        ),
                    ],
                  ),
                  Switch(
                    value: _isEnabled,
                    activeThumbColor: Colors.green,
                    onChanged: (bool value) {
                      setState(() {
                        _isEnabled = value;
                      });
                    },
                  )
                ],
              ),
            ),
          ),
          
        ],
      );
  }
}