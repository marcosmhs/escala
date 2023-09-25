import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escala/components/screen_elements/custom_scaffold.dart';
import 'package:escala/components/visual_elements/custom_silverappbar.dart';
import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/department_controller.dart';
import 'package:escala/features/department/visualizations/department_card.dart';
import 'package:escala/features/main/routes.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({Key? key}) : super(key: key);

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showAppBar: false,
      body: StreamBuilder<QuerySnapshot>(
        stream: Provider.of<DepartmentController>(context, listen: true).getDepartments(),
        builder: (context, snapshot) {
          if ((!snapshot.hasData) || (snapshot.data!.docs.isEmpty)) {
            return CustomSilverBarApp(
              context: context,
              title: 'Áreas / Setores',
              emptyListMessage: 'Nenhuma área/setor cadastrada',
            );
          } else if (snapshot.hasError) {
            return const Text('Ocorreu um erro!');
          }
          // transforma o retorno do snapshot em uma lista de categorias
          List<Department> departmentList = snapshot.data!.docs.map((e) => Department.fromDocument(e)).toList();

          return CustomSilverBarApp(
            context: context,
            title: 'Áreas / Setores',
            listItens: departmentList,
            listHeaderitemExtent: 120,
            sliverChildBuilderDelegate: SliverChildBuilderDelegate(
              childCount: departmentList.length,
              (BuildContext context, int index) => DepartmentCard(department: departmentList[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.departmentForm),
        child: const Icon(Icons.add),
      ),
    );
  }
}
