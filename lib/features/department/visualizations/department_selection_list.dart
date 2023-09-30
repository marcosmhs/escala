import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/department_controller.dart';
import 'package:escala/features/department/visualizations/department_card.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DepartmentSelectionList extends StatefulWidget {
  final User user;
  const DepartmentSelectionList({Key? key, required this.user}) : super(key: key);

  @override
  State<DepartmentSelectionList> createState() => _DepartmentSelectionListState();
}

class _DepartmentSelectionListState extends State<DepartmentSelectionList> {
  late List<Department> _departmentList = [];

  @override
  Widget build(BuildContext context) {
    DepartmentController(widget.user).getDepartmentList().then((value) => setState(() => _departmentList = value));

    return SizedBox(
      width: kIsWeb ? MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.99,
      child: Card(
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
              height: kIsWeb ? MediaQuery.of(context).size.height * 0.4 : MediaQuery.of(context).size.height * 0.4,
              child: ListView.builder(
                itemCount: _departmentList.length,
                itemBuilder: (ctx, index) => DepartmentCard(
                  department: _departmentList[index],
                  screenMode: ScreenMode.list,
                  user: widget.user,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
