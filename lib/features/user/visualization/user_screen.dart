import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/visualizations/department_card.dart';
import 'package:escala/features/department/visualizations/department_selection_component.dart';
import 'package:escala/features/department/visualizations/department_selection_list.dart';
import 'package:escala/features/user/user_controller.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:escala/features/main/routes.dart';
import 'package:escala/features/user/visualization/user_list_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';
import 'package:teb_package/visual_elements/teb_buttons_line.dart';
import 'package:teb_package/visual_elements/teb_silverappbar.dart';
import 'package:teb_package/visual_elements/teb_switch.dart';
import 'package:teb_package/visual_elements/teb_text_form_field.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _onlyActiverUsers = true;
  String _userRegistrationSearch = '';
  var _department = Department();

  bool _initializing = true;
  var _user = User();

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
              width: kIsWeb ? MediaQuery.of(context).size.width * 0.35 : MediaQuery.of(context).size.width * 0.99,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informe a matrícula que deseja localizar', textAlign: TextAlign.start),
                    TebTextEdit(
                      labelText: 'Localizar Matrícula',
                      inicialValue: _userRegistrationSearch,
                      onChanged: (value) => setState(() => _userRegistrationSearch = value ?? ''),
                    ),
                    const SizedBox(height: 5),
                    DepartmentSelectionComponent(
                      ctx: context,
                      fixedWidth: kIsWeb ? MediaQuery.of(context).size.width * 0.30 : MediaQuery.of(context).size.width * 0.99,
                      error: false,
                      selectionItem: _department.id.isEmpty
                          ? DepartmentCard(
                              department: Department(),
                              screenMode: ScreenMode.showItem,
                              user: _user,
                            ).emptyCard(context)
                          : DepartmentCard(department: _department, screenMode: ScreenMode.showItem, user: _user, cropped: false),
                      onTap: () {
                        Navigator.pop(ctx);
                        showModalBottomSheet<Department>(
                          constraints: kIsWeb
                              ? BoxConstraints.tightFor(width: MediaQuery.of(context).size.width * 0.55)
                              : BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 32),
                          context: context,
                          isDismissible: true,
                          builder: (context) => DepartmentSelectionList(user: _user),
                        ).then((value) {
                          if (value != null) {
                            setState(() => _department = value);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 5),
                    TebButtonsLine(buttons: [
                      TebButton(
                        label: 'Limpar pesquisa',
                        onPressed: () {
                          setState(() {
                            _userRegistrationSearch = '';
                            _department = Department();
                          });
                          Navigator.pop(ctx);
                        },
                      ),
                      TebButton(label: 'OK', onPressed: () => Navigator.pop(ctx)),
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
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;

      _user = arguments['user'] ?? User();
      _user = User.fromMap(_user.toMap());

      _initializing = false;
    }
    return TebCustomScaffold(
      responsive: true,
      title: const Text('Usuários'),
      body: StreamBuilder<QuerySnapshot>(
        stream: UserController().getUsers(
          registration: _userRegistrationSearch,
          departmentId: _department.id,
          institutionId: _user.institutionId,
          onlyActiveUsers: _onlyActiverUsers,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Ocorreu um erro!');
          }
          if ((!snapshot.hasData) || (snapshot.data!.docs.isEmpty)) {
            return TebSilverBarApp(
              context: context,
              actions: [IconButton(onPressed: () => _showUserSearch(context: context), icon: const Icon(Icons.search))],
              listHeaderitemExtent: MediaQuery.of(context).size.height * 0.08,
              listHeaderArea: onlyActiveUsersFilter(context),
              emptyListMessage: 'Nenhum usuário encontrado',
            );
          }
          // transforma o retorno do snapshot em uma lista de categorias
          List<User> usersList = snapshot.data!.docs.map((e) => User.fromDocument(e)).toList();

          return TebSilverBarApp(
            context: context,
            title: usersList.isEmpty ? 'Usuários' : 'Usuários (${usersList.length} cadastrados)',
            actions: [IconButton(onPressed: () => _showUserSearch(context: context), icon: const Icon(Icons.search))],
            listItens: usersList,
            listHeaderitemExtent: MediaQuery.of(context).size.height * 0.08,
            listHeaderArea: onlyActiveUsersFilter(context),
            sliverChildBuilderDelegate: SliverChildBuilderDelegate(
              childCount: usersList.length,
              (BuildContext context, int index) => UserListCard(
                user: usersList[index],
                userManager: _user,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(Routes.userForm, arguments: {'userManager': _user}),
        child: const Icon(Icons.add),
      ),
    );
  }

  Container onlyActiveUsersFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          TebSwitch(
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
