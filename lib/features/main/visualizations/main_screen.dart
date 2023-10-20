import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/department_controller.dart';
import 'package:escala/features/institution/institution.dart';
import 'package:escala/features/institution/institution_controller.dart';
import 'package:escala/features/main/visualizations/schedule_date_user_list.dart';
import 'package:escala/features/schedule/schedule_controller.dart';
import 'package:escala/features/schedule/models/schedule.dart';
import 'package:escala/features/schedule/models/schedule_date.dart';
import 'package:escala/features/schedule/visualizations/schedule_user_calendar_component.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:escala/features/main/custom_drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';

// ignore: must_be_immutable
class MainScreen extends StatefulWidget {
  var _user = User();

  @override
  MainScreen({
    Key? key,
    User? user,
  }) : super(key: key) {
    if (user != null) _user = user;
  }

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> with TickerProviderStateMixin {
  var _institution = Institution();
  var _department = Department();
  var _showingUserList = false;

  var _initializing = true;

  var _selectedScheduleStatusType = ScheduleStatus.released;

  var _user = User();

  @override
  void initState() {
    super.initState();
  }

  void _scheduleTypeSelection({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Qual tipo de escala deseja visualizar?'),
          content: Container(
            padding: const EdgeInsets.all(8),
            height: MediaQuery.of(context).size.height * 0.25,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(height: 45, width: MediaQuery.of(context).size.width * 0.70),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() => _selectedScheduleStatusType = ScheduleStatus.released);
                      },
                      child: const Text('Escalas liberadas'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(height: 45, width: MediaQuery.of(context).size.width * 0.70),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() => _selectedScheduleStatusType = ScheduleStatus.teamValidation);
                      },
                      child: const Text('Escalas em validação'),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(height: 45, width: MediaQuery.of(context).size.width * 0.70),
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUserList({required BuildContext context, required String scheduleId, required DateTime date}) {
    ScheduleController(_user).getUsersOnScheduleDate(departmentId: _user.departmentId, scheduleId: scheduleId, date: date).then(
      (list) {
        List<ScheduleDateUser> userList = list.where((u) => u.user.id != _user.id).toList();
        showModalBottomSheet(
          constraints: kIsWeb
              ? BoxConstraints.tightFor(width: MediaQuery.of(context).size.width * 0.55)
              : BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 32),
          context: context,
          isDismissible: true,
          builder: (context) => ScheduleDateUserList(
            scheduleDateUser: userList,
            institution: _institution,
          ),
        ).then((value) => _showingUserList = false);
      },
    );
  }

  Widget _baseStructure({required BuildContext context, required Widget streamBuilder}) {
    var main = Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.all(5.0),
          leading: Icon(Department.icon, size: 30),
          title: Text(
            _department.name,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        streamBuilder,
      ],
    );

    if (kIsWeb) {
      return main;
    } else {
      return SingleChildScrollView(
        child: main,
      );
    }
  }

  Widget _calendar({required BuildContext context}) {
    return _baseStructure(
      context: context,
      streamBuilder: StreamBuilder<QuerySnapshot>(
        stream: ScheduleController(_user).getUserSchadule(userId: _user.id),
        builder: (context, snapshot) {
          if ((!snapshot.hasData) || (snapshot.data!.docs.isEmpty)) {
            return const Text('Você ainda não possui escala');
          } else if (snapshot.hasError) {
            return const Text('Ocorreu um erro na consulta da escala');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // transforma o retorno do snapshot em uma lista de categorias
          List<ScheduleDate> scheduleDates = snapshot.data!.docs
              .map((e) => ScheduleDate.fromDocument(e))
              .toList()
              .where((scheduleDate) => scheduleDate.status == _selectedScheduleStatusType)
              .toList();

          return ConstrainedBox(
            constraints: BoxConstraints.tightFor(height: MediaQuery.of(context).size.height * 0.75),
            child: ScheduleUsersCalendarComponent(
              context: context,
              institution: _institution,
              scheduleDateList: scheduleDates,
              scheduleId: '',
              scheduleStatus: ScheduleStatus.released,
              user: _user,
              initialDate: DateTime.now(),
              onTap: (calendarDatais) {
                if (_selectedScheduleStatusType == ScheduleStatus.teamValidation && _showingUserList == false) {
                  _showingUserList = true;
                  _showUserList(
                    context: context,
                    scheduleId: scheduleDates.first.scheduleId,
                    date: calendarDatais.date!,
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _user = arguments['user'] ?? User();

      if (widget._user.id.isNotEmpty) _user = widget._user;

      InstitutionController(_user)
          .getInstitutionFromId(institutionId: _user.institutionId)
          .then((institution) => setState(() => _institution = institution));

      DepartmentController(_user)
          .getDepartmentById(departmentId: _user.departmentId)
          .then((department) => setState(() => _department = department));
      _initializing = false;
    }

    return TebCustomScaffold(
      responsive: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sua Escala'),
            Text(
              'Apenas ${_selectedScheduleStatusType == ScheduleStatus.released ? 'escalas liberadas' : 'escalas em validação'}',
              style: TextStyle(fontSize: Theme.of(context).textTheme.labelLarge!.fontSize, color: Theme.of(context).cardColor),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _scheduleTypeSelection(context: context),
            icon: const Icon(Icons.remove_red_eye),
          ),
        ],
      ),
      drawer: CustomDrawer(currentUser: _user),
      showAppDrawer: true,
      body: _calendar(context: context),
    );
  }
}
