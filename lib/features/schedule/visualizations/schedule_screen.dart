import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escala/components/screen_elements/custom_scaffold.dart';
import 'package:escala/components/visual_elements/custom_silverappbar.dart';
import 'package:escala/features/schedule/schedule_controller.dart';
import 'package:escala/features/schedule/models/schedule.dart';
import 'package:escala/features/main/routes.dart';
import 'package:escala/features/schedule/visualizations/schedule_list_card.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  var _initializing = true;
  var _user = User();

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;

      _user = arguments['user'] ?? User();
      _user = User.fromMap(_user.toMap());
      _initializing = true;
    }
    return CustomScaffold(
      responsive: true,
      title: 'Escalas',
      body: StreamBuilder<QuerySnapshot>(
        stream: ScheduleController(_user).getSchedules(),
        builder: (context, snapshot) {
          if ((!snapshot.hasData) || (snapshot.data!.docs.isEmpty)) {
            return CustomSilverBarApp(context: context, title: 'Escalas', emptyListMessage: 'Nenhuma escala cadastrada');
          } else if (snapshot.hasError) {
            return CustomSilverBarApp(
                context: context, title: 'Escalas', emptyListMessage: 'Verifique sua conexão com a internet');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // transforma o retorno do snapshot em uma lista de categorias
          List<Schedule> scheduleList = snapshot.data!.docs.map((e) => Schedule.fromDocument(e)).toList();

          return CustomSilverBarApp(
            context: context,
            listItens: scheduleList,
            sliverChildBuilderDelegate: SliverChildBuilderDelegate(
              childCount: scheduleList.length,
              (BuildContext context, int index) => ScheduleListCard(schedule: scheduleList[index], user: _user),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(Routes.scheduleForm, arguments: {
          'user': _user,
        }),
        child: const Icon(Icons.add),
      ),
    );
  }
}
