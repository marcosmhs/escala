// ignore_for_file: file_names
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CustomTextEdit extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController? controller;
  final bool enabled;
  final bool isPassword;
  final BuildContext? context;
  final String? inicialValue;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final FocusNode? nextFocusNode;
  final FocusNode? focusNode;
  final IconData? prefixIcon;
  final Color? fillColor;
  final String? Function(String?)? validator;
  final void Function(String?)? onSave;
  final void Function(String?)? onChanged;
  final void Function()? onEditingCompleted;
  final InputBorder? border;
  final void Function()? onTap;
  final int maxLines;
  final int? maxLength;
  final String mask;

  const CustomTextEdit({
    Key? key,
    this.context,
    this.controller,
    required this.labelText,
    this.hintText = '',
    this.enabled = true,
    this.isPassword = false,
    this.inicialValue,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.maxLength,
    this.fillColor,
    this.keyboardType,
    this.nextFocusNode,
    this.focusNode,
    this.prefixIcon,
    this.validator,
    this.onSave,
    this.onChanged,
    this.onEditingCompleted,
    this.border,
    this.onTap,
    this.mask = '',
  }) : super(key: key);

  @override
  State<CustomTextEdit> createState() => _CustomTextEditState();
}

class _CustomTextEditState extends State<CustomTextEdit> {
  late bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    MaskTextInputFormatter maskFormatter = MaskTextInputFormatter();
    if (widget.mask.isNotEmpty) {
      maskFormatter = MaskTextInputFormatter(mask: widget.mask);
    }

    var widgetResult = GestureDetector(
      onTap: widget.onTap,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TextFormField(
            inputFormatters: widget.mask.isEmpty ? null : [maskFormatter],
            enabled: widget.enabled,
            obscureText: !widget.isPassword ? false : _hidePassword,
            // use text editor only if keyboardType wasn´t set.
            keyboardType:
                widget.isPassword && widget.keyboardType == null ? TextInputType.text : widget.keyboardType ?? TextInputType.text,
            onSaved: (value) {
              if (widget.onSave != null) {
                var finalValue = value;
                if (widget.mask.isNotEmpty) {
                  finalValue = maskFormatter.unmaskText(finalValue ?? '');
                }
                widget.onSave!(finalValue);
              }
            },
            onChanged: (value) {
              if (widget.onChanged != null) {
                var finalValue = value;
                if (widget.mask.isNotEmpty) {
                  finalValue = maskFormatter.getUnmaskedText();
                }
                widget.onChanged!(finalValue);
              }
            },
            onEditingComplete: widget.onEditingCompleted,
            initialValue: widget.inicialValue,
            textInputAction: widget.textInputAction,
            onFieldSubmitted:
                widget.nextFocusNode == null ? null : (_) => FocusScope.of(context).requestFocus(widget.nextFocusNode),
            focusNode: widget.focusNode,
            validator: widget.validator,
            controller: widget.controller,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.fillColor,
              prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
              // set if password should be visible
              suffixIcon: !widget.isPassword
                  ? null
                  : GestureDetector(
                      onTap: () {
                        _hidePassword = !_hidePassword;
                        setState(() {});
                      },
                      child: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
                    ),
              hintText: widget.hintText,
              labelText: widget.labelText,
              border: widget.border ?? OutlineInputBorder(borderRadius: BorderRadius.circular(1)),
            ),
          ),
        ],
      ),
    );

    //if (widget.controller != null && widget.mask.isNotEmpty) {
    //widget.controller!.value = maskFormatter.updateMask(mask: widget.mask);
    //}

    return widgetResult;
  }
}
