// ignore: depend_on_referenced_packages
import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/department_controller.dart';
import 'package:escala/features/main/routes.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/messaging/teb_custom_dialog.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/util/teb_return.dart';

enum ScreenMode { form, list, showItem }

class DepartmentCard extends StatefulWidget {
  final Department department;
  final User user;
  final ScreenMode screenMode;
  final bool cropped;
  final double elevation;

  const DepartmentCard({
    Key? key,
    required this.department,
    this.screenMode = ScreenMode.form,
    this.cropped = false,
    this.elevation = 1,
    required this.user,
  }) : super(key: key);

  Widget _structure({Widget? leading, Widget? title, Widget? subtitle, Widget? trailing}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
      elevation: elevation,
      child: ListTile(
        visualDensity: cropped ? const VisualDensity(horizontal: 0, vertical: -4) : null,
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
      ),
    );
  }

  Widget emptyCard(BuildContext context) {
    return Container(
      constraints: kIsWeb
          ? BoxConstraints.tightFor(width: MediaQuery.of(context).size.width * 0.2)
          : BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 32),
      child: _structure(
        leading: Icon(Department.icon, size: 30),
        title: const Text('Selecione uma área/setor'),
      ),
    );
  }

  @override
  State<DepartmentCard> createState() => _DepartmentCardState();
}

class _DepartmentCardState extends State<DepartmentCard> {
  void _delete({required User user}) async {
    var retorno = await DepartmentController(user).delete(
      department: widget.department,
    );

    if (retorno.returnType == TebReturnType.sucess) {
      // ignore: use_build_context_synchronously
      TebCustomMessage(
        context: context,
        messageText: 'Dados salvos com sucesso',
        messageType: TebMessageType.sucess,
      );
    }
    // se houve um erro no login ou no cadastro exibe o erro
    if (retorno.returnType == TebReturnType.error) {
      // ignore: use_build_context_synchronously
      TebCustomMessage(
        context: context,
        messageText: retorno.message,
        messageType: TebMessageType.error,
      );
    }
  }

  _returnSelectedItem() {
    Navigator.of(context).pop(widget.department);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.screenMode == ScreenMode.list ? _returnSelectedItem : null,
      child: widget._structure(
        leading: Icon(
          Icons.door_sliding_outlined,
          color: widget.department.active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
          size: 30,
        ),
        title: Text(widget.department.name),
        subtitle: widget.department.active ? null : const Text('Inativo'),
        trailing: widget.screenMode == ScreenMode.list
            ? ElevatedButton(onPressed: _returnSelectedItem, child: const Text('Selecionar'))
            : widget.screenMode == ScreenMode.showItem
                ? null
                : SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        // Edit Button
                        IconButton(
                          icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                          onPressed: () =>
                              Navigator.pushNamed(context, Routes.departmentForm, arguments: {'department': widget.department}),
                        ),
                        // delete buttom
                        IconButton(
                          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.primary),
                          onPressed: () async {
                            final deletedConfirmed = await TebCustomDialog(context: context).confirmationDialog(
                              message: 'Confirma a exclusão deste departamento?',
                            );

                            if (deletedConfirmed ?? false) {
                              _delete(user: widget.user);
                            } else {
                              // ignore: use_build_context_synchronously
                              TebCustomMessage(
                                context: context,
                                messageType: TebMessageType.info,
                                messageText: 'Exclusão cancelada',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
