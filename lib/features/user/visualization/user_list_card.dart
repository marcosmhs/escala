import 'package:escala/features/user/models/user.dart';
import 'package:escala/features/main/routes.dart';
import 'package:flutter/material.dart';

class UserListCard extends StatefulWidget {
  final User user;
  final User userManager;
  final bool cropped;
  final double? fixedWidth;
  const UserListCard({
    Key? key,
    required this.user,
    required this.userManager,
    this.cropped = false,
    this.fixedWidth,
  }) : super(key: key);

  Widget structure({Widget? leading, Widget? title, Widget? subtitle, Widget? trailing}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
      elevation: 1,
      child: ListTile(
        visualDensity: cropped ? const VisualDensity(horizontal: 0, vertical: -4) : null,
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
      ),
    );
  }

  @override
  State<UserListCard> createState() => _UserListCardState();
}

class _UserListCardState extends State<UserListCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: widget.structure(
        leading: Icon(
          Icons.people_alt,
          color: widget.user.active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
          size: 30,
        ),
        title: Text(widget.user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Matrícula ${widget.user.registration}'),
            if (!widget.user.active) const Text('Inativo'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => Navigator.of(context).pushNamed(Routes.userForm, arguments: {
            'user': widget.user,
            'userManager': widget.userManager,
          }),
        ),
      ),
    );
  }
}
