import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escala/components/screen_elements/custom_scaffold.dart';
import 'package:escala/components/visual_elements/custom_silverappbar.dart';
import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/department_controller.dart';
import 'package:escala/features/department/visualizations/department_card.dart';
import 'package:escala/features/main/routes.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({Key? key}) : super(key: key);

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  var _initializing = true;
  var _user = User();

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;

      _user = arguments['user'] ?? User();
      _user = User.fromMap(_user.toMap());

      _initializing = false;
    }

    return CustomScaffold(
      title: 'Áreas / Setores',
      responsive: true,
      body: StreamBuilder<QuerySnapshot>(
        stream: DepartmentController(_user).getDepartments(),
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
            listItens: departmentList,
            listHeaderitemExtent: 120,
            sliverChildBuilderDelegate: SliverChildBuilderDelegate(
              childCount: departmentList.length,
              (BuildContext context, int index) => DepartmentCard(
                department: departmentList[index],
                user: _user,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(Routes.departmentForm, arguments: {'user': _user}),
        child: const Icon(Icons.add),
      ),
    );
  }
}
