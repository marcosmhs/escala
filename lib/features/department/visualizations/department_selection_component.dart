import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DepartmentSelectionComponent extends StatefulWidget {
  final bool error;
  final Widget selectionItem;
  final BuildContext ctx;
  final double? fixedWidth;
  final void Function()? onTap;

  const DepartmentSelectionComponent(
      {Key? key, required this.error, required this.selectionItem, this.onTap, required this.ctx, this.fixedWidth})
      : super(key: key);

  @override
  State<DepartmentSelectionComponent> createState() => _DepartmentSelectionComponentState();
}

class _DepartmentSelectionComponentState extends State<DepartmentSelectionComponent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        constraints: widget.fixedWidth != null
            ? BoxConstraints(maxWidth: widget.fixedWidth!)
            : kIsWeb
                ? BoxConstraints.tightFor(width: MediaQuery.of(widget.ctx).size.width * 0.5)
                : BoxConstraints(maxWidth: MediaQuery.of(widget.ctx).size.width - 32),
        decoration: widget.error ? BoxDecoration(border: Border.all(color: Theme.of(widget.ctx).colorScheme.error)) : null,
        alignment: Alignment.center,
        child: widget.selectionItem,
      ),
    );
  }
}
