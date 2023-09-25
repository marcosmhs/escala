import 'package:flutter/material.dart';

enum DisplayMode { dialog, modal }

class CustomSwitch extends StatefulWidget {
  final BuildContext context;
  final String title;
  final bool? value;
  final bool enabled;
  final void Function(bool?)? onChanged;

  const CustomSwitch({
    Key? key,
    required this.context,
    required this.value,
    required this.title,
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.title),
        const Spacer(),
        Switch(
          value: widget.value ?? false,
          onChanged: widget.enabled ? widget.onChanged : null,
        ),
      ],
    );
  }
}
