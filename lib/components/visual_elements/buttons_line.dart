import 'package:flutter/material.dart';

enum ButtonType { outlinedButton, elevatedButton }

class Button extends StatefulWidget {
  final String label;
  final void Function()? onPressed;
  final bool enabled;
  final ButtonType buttonType;
  final TextStyle? textStyle;

  const Button({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.buttonType = ButtonType.elevatedButton,
    this.textStyle,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    if (widget.buttonType == ButtonType.outlinedButton) {
      return OutlinedButton(
        onPressed: widget.enabled ? widget.onPressed : () => {},
        style: widget.enabled ? null : ButtonStyle(foregroundColor: MaterialStateProperty.all(Theme.of(context).disabledColor)),
        child: Text(widget.label, style: widget.textStyle),
      );
    } else {
      return ElevatedButton(
        onPressed: widget.enabled ? widget.onPressed : () => {},
        style: widget.enabled ? null : ButtonStyle(foregroundColor: MaterialStateProperty.all(Theme.of(context).disabledColor)),
        child: Text(widget.label, style: widget.textStyle),
      );
    }
  }
}

class ButtonsLine extends StatefulWidget {
  final List<Button> buttons;
  final MainAxisAlignment mainAxisAlignment;
  final double widthSpaceBetweenButtons;

  const ButtonsLine({
    Key? key,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.widthSpaceBetweenButtons = 20,
    required this.buttons,
  }) : super(key: key);

  @override
  State<ButtonsLine> createState() => _ButtonsLineState();
}

class _ButtonsLineState extends State<ButtonsLine> {
  List<Widget> getList() {
    List<Widget> btns = [];
    for (Button btn in widget.buttons) {
      btns.add(btn);
      if (btn != widget.buttons.last) btns.add(SizedBox(width: widget.widthSpaceBetweenButtons));
    }
    return btns;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.mainAxisAlignment,
      children: (getList()),
    );
  }
}
