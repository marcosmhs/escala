import 'package:flutter/material.dart';

enum DisplayMode { dialog, modal }

class CustomCheckBox extends StatefulWidget {
  final BuildContext context;
  final String title;
  final String subTitle;
  final bool? value;
  final bool enabled;
  final void Function(bool?)? onChanged;

  const CustomCheckBox({
    Key? key,
    required this.context,
    required this.value,
    required this.title,
    this.subTitle = '',
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.title),
      value: widget.value,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      subtitle: widget.subTitle.isEmpty ? null : Text(widget.subTitle),
    );
  }
}
