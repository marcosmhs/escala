import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escala/components/screen_elements/custom_scaffold.dart';
import 'package:escala/components/visual_elements/custom_silverappbar.dart';
import 'package:escala/features/schedule/schedule_controller.dart';
import 'package:escala/features/schedule/models/schedule.dart';
import 'package:escala/features/main/routes.dart';
import 'package:escala/features/schedule/visualizations/schedule_list_card.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      showAppBar: false,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        color: Theme.of(context).canvasColor,
        child: Center(
          child: Card(
            child: StreamBuilder<QuerySnapshot>(
              stream: Provider.of<ScheduleController>(context, listen: true).getSchedules(),
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
                  title: 'Escalas',
                  listItens: scheduleList,
                  sliverChildBuilderDelegate: SliverChildBuilderDelegate(
                    childCount: scheduleList.length,
                    (BuildContext context, int index) => ScheduleListCard(schedule: scheduleList[index]),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.scheduleForm),
        child: const Icon(Icons.add),
      ),
    );
  }
}
