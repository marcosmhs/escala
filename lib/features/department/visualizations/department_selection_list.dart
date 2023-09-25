import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/department_controller.dart';
import 'package:escala/features/department/visualizations/department_card.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class DepartmentSelectionList extends StatefulWidget {
  const DepartmentSelectionList({Key? key}) : super(key: key);

  @override
  State<DepartmentSelectionList> createState() => _DepartmentSelectionListState();
}

class _DepartmentSelectionListState extends State<DepartmentSelectionList> {
  late List<Department> _departmentList = [];

  @override
  Widget build(BuildContext context) {
    DepartmentController departmentController = Provider.of(context, listen: false);
    departmentController.getDepartmentList().then((value) => setState(() => _departmentList = value));
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Toque no departamento desejado',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: _departmentList.length,
              itemBuilder: (ctx, index) => DepartmentCard(
                department: _departmentList[index],
                screenMode: ScreenMode.list,
              ),
            ),
          )
        ],
      ),
    );
  }
}
