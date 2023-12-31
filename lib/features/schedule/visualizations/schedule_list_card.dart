import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/department_controller.dart';
import 'package:escala/features/schedule/schedule_controller.dart';
import 'package:escala/features/schedule/models/schedule.dart';
import 'package:escala/features/main/routes.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teb_package/messaging/teb_custom_dialog.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/util/teb_return.dart';

class ScheduleListCard extends StatefulWidget {
  final Schedule schedule;
  final User user;
  const ScheduleListCard({
    required this.schedule,
    required this.user,
    Key? key, 
  }) : super(key: key);

  @override
  State<ScheduleListCard> createState() => _ScheduleListCardState();
}

class _ScheduleListCardState extends State<ScheduleListCard> {
  var _initializing = true;

  var _department = Department();

  void _remove(BuildContext context) async {
    final deletedConfirmed = await TebCustomDialog(context: context).confirmationDialog(
      message: 'Confirma a exclusão da escala?',
    );

    if (!(deletedConfirmed ?? false)) {
      return;
    }

    // ignore: use_build_context_synchronously
    var retorno = await ScheduleController(widget.user).deleteSchedule(schedule: widget.schedule);
    if (retorno.returnType == TebReturnType.sucess) {
      // ignore: use_build_context_synchronously
      TebCustomMessage(
        context: context,
        messageText: 'Escala removida',
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

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      DepartmentController(widget.user)
          .getDepartmentById(departmentId: widget.schedule.departmentId)
          .then((value) => setState(() => _department = value));
      _initializing = false;
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, Routes.scheduleForm, arguments: {
        'user': widget.user,
        'schedule': widget.schedule,
        'department': _department,
      }),
      child: Container(
        margin: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minHeight: 70),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 10))]),
        child: ListTile(
          leading: const Icon(
            Icons.schedule,
            size: 45,
          ),
          title: Text(_department.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(widget.schedule.statusLabel()),
              Text(
                  '${DateFormat('dd/MM/yyyy').format(widget.schedule.initialDate!)} à ${DateFormat('dd/MM/yyyy').format(widget.schedule.finalDate!)}'),
            ],
          ),
          trailing: widget.schedule.id.isEmpty
              ? null
              : IconButton(
                  onPressed: widget.schedule.status == ScheduleStatus.released ? null : () => _remove(context),
                  icon: Icon(
                    Icons.delete,
                    size: 40,
                    color: widget.schedule.status == ScheduleStatus.released
                        ? Theme.of(context).colorScheme.outline
                        : Theme.of(context).colorScheme.error,
                  )),
        ),
      ),
    );
  }
}
