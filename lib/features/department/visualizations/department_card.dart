// ignore: depend_on_referenced_packages
import 'package:escala/components/messaging/custom_dialog.dart';
import 'package:escala/components/messaging/custom_message.dart';
import 'package:escala/components/util/custom_return.dart';
import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/department_controller.dart';
import 'package:escala/features/main/routes.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

enum ScreenMode { form, list, showItem }

class DepartmentCard extends StatefulWidget {
  final Department department;
  final ScreenMode screenMode;
  final bool cropped;
  final double elevation;

  const DepartmentCard({
    Key? key,
    required this.department,
    this.screenMode = ScreenMode.form,
    this.cropped = false,
    this.elevation = 1,
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
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 28),
      child: _structure(
        leading: Icon(Department.icon, size: 30),
        title: const Text('Selecione um departamento'),
      ),
    );
  }

  @override
  State<DepartmentCard> createState() => _DepartmentCardState();
}

class _DepartmentCardState extends State<DepartmentCard> {
  void _removeEntryType() async {
    var retorno = await Provider.of<DepartmentController>(context, listen: false).delete(
      department: widget.department,
    );

    if (retorno.returnType == ReturnType.sucess) {
      // ignore: use_build_context_synchronously
      CustomMessage(
        context: context,
        messageText: 'Dados salvos com sucesso',
        messageType: MessageType.sucess,
      );
    }
    // se houve um erro no login ou no cadastro exibe o erro
    if (retorno.returnType == ReturnType.error) {
      // ignore: use_build_context_synchronously
      CustomMessage(
        context: context,
        messageText: retorno.message,
        messageType: MessageType.error,
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
                            final deletedConfirmed = await CustomDialog(context: context).confirmationDialog(
                              message: 'Confirma a exclusão deste departamento?',
                            );

                            if (deletedConfirmed ?? false) {
                              _removeEntryType();
                            } else {
                              // ignore: use_build_context_synchronously
                              CustomMessage(
                                context: context,
                                messageType: MessageType.info,
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
