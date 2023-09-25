import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escala/components/screen_elements/custom_scaffold.dart';
import 'package:escala/components/visual_elements/buttons_line.dart';
import 'package:escala/components/visual_elements/custom_silverappbar.dart';
import 'package:escala/components/visual_elements/custom_switch.dart';
import 'package:escala/components/visual_elements/custom_textFormField.dart';
import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/visualizations/department_card.dart';
import 'package:escala/features/department/visualizations/department_selection_component.dart';
import 'package:escala/features/department/visualizations/department_selection_list.dart';
import 'package:escala/features/user/user_controller.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:escala/features/main/routes.dart';
import 'package:escala/features/user/visualization/user_list_card.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _onlyActiverUsers = true;
  String _userRegistrationSearch = '';
  var _department = Department();
  @override
  void initState() {
    super.initState();
  }

  void _showUserSearch({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Dialog(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informe a matrícula que deseja localizar', textAlign: TextAlign.start),
                    CustomTextEdit(
                      labelText: 'Localizar Matrícula',
                      inicialValue: _userRegistrationSearch,
                      onChanged: (value) => setState(() => _userRegistrationSearch = value ?? ''),
                    ),
                    const SizedBox(height: 5),
                    DepartmentSelectionComponent(
                      error: false,
                      selectionItem: _department.id.isEmpty
                          ? DepartmentCard(department: Department(), screenMode: ScreenMode.showItem).emptyCard(context)
                          : DepartmentCard(department: _department, screenMode: ScreenMode.showItem, cropped: false),
                      onTap: () {
                        Navigator.pop(ctx);
                        showModalBottomSheet<Department>(
                          context: context,
                          isDismissible: true,
                          builder: (context) => const DepartmentSelectionList(),
                        ).then((value) {
                          if (value != null) {
                            setState(() => _department = value);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 5),
                    ButtonsLine(buttons: [
                      Button(
                        label: 'Limpar pesquisa',
                        onPressed: () {
                          setState(() {
                            _userRegistrationSearch = '';
                            _department = Department();
                          });
                          Navigator.pop(ctx);
                        },
                      ),
                      Button(label: 'OK', onPressed: () => Navigator.pop(ctx)),
                    ]),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showAppBar: false,
      body: StreamBuilder<QuerySnapshot>(
        stream: Provider.of<UserController>(context, listen: true).getUsers(
          registration: _userRegistrationSearch,
          departmentId: _department.id,
          onlyActiveUsers: _onlyActiverUsers,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Ocorreu um erro!');
          }
          if ((!snapshot.hasData) || (snapshot.data!.docs.isEmpty)) {
            return CustomSilverBarApp(
              context: context,
              title: 'Usuários',
              actions: [IconButton(onPressed: () => _showUserSearch(context: context), icon: const Icon(Icons.search))],
              listHeaderitemExtent: MediaQuery.of(context).size.height * 0.08,
              listHeaderArea: onlyActiveUsersFilter(context),
              emptyListMessage: 'Nenhum usuário encontrado',
            );
          }
          // transforma o retorno do snapshot em uma lista de categorias
          List<User> usersList = snapshot.data!.docs.map((e) => User.fromDocument(e)).toList();

          return CustomSilverBarApp(
            context: context,
            title: usersList.isEmpty ? 'Usuários' : 'Usuários (${usersList.length} cadastrados)',
            actions: [IconButton(onPressed: () => _showUserSearch(context: context), icon: const Icon(Icons.search))],
            listItens: usersList,
            listHeaderitemExtent: MediaQuery.of(context).size.height * 0.08,
            listHeaderArea: onlyActiveUsersFilter(context),
            sliverChildBuilderDelegate: SliverChildBuilderDelegate(
              childCount: usersList.length,
              (BuildContext context, int index) => UserListCard(user: usersList[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.userForm),
        child: const Icon(Icons.add),
      ),
    );
  }

  Container onlyActiveUsersFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          CustomSwitch(
            context: context,
            value: _onlyActiverUsers,
            title: 'Somente usuários ativos',
            onChanged: (value) => setState(() => _onlyActiverUsers = value!),
          ),
        ],
      ),
    );
  }
}
