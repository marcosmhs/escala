import 'package:flutter/material.dart';

class DepartmentSelectionComponent extends StatefulWidget {
  final bool error;
  final Widget selectionItem;
  final void Function()? onTap;

  const DepartmentSelectionComponent({Key? key, required this.error, required this.selectionItem, this.onTap}) : super(key: key);

  @override
  State<DepartmentSelectionComponent> createState() => _DepartmentSelectionComponentState();
}

class _DepartmentSelectionComponentState extends State<DepartmentSelectionComponent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 32),
          decoration: widget.error ? BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.error)) : null,
          alignment: Alignment.center,
          child: widget.selectionItem,
        ));
  }
}
