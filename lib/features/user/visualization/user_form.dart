import 'package:escala/components/messaging/custom_message.dart';
import 'package:escala/components/screen_elements/custom_scaffold.dart';
import 'package:escala/components/util/custom_return.dart';
import 'package:escala/components/util/util.dart';
import 'package:escala/components/visual_elements/buttons_line.dart';
import 'package:escala/components/visual_elements/custom_checkbox.dart';
import 'package:escala/components/visual_elements/custom_textFormField.dart';
import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/department_controller.dart';
import 'package:escala/features/department/visualizations/department_card.dart';
import 'package:escala/features/department/visualizations/department_selection_component.dart';
import 'package:escala/features/department/visualizations/department_selection_list.dart';
import 'package:escala/features/institution/institution.dart';
import 'package:escala/features/institution/institution_controller.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:escala/features/user/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _weekHoursController = TextEditingController();
  final TextEditingController _dailyHoursController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _registrationFocus = FocusNode();
  final FocusNode _weekHoursFocus = FocusNode();
  //final FocusNode _dailyHoursFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _saveingData = false;

  var _departmentError = false;
  var _department = Department();
  var _initializing = true;

  var _user = User();
  late Institution? _firstAccessInstitution;

  List<bool> _selectedGender = [true, false];

  void _submit() async {
    if (_saveingData) return;

    if (_user.departmentId.isEmpty) {
      setState(() => _departmentError = true);
      CustomMessage(
        context: context,
        messageText: 'O usuário deve ser vinculado a uma área/setor',
        messageType: MessageType.error,
      );
      return;
    }

    _saveingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _saveingData = false;
    } else {
      // salva os dados
      _formKey.currentState?.save();
      UserController userController = Provider.of(context, listen: false);
      CustomReturn retorno;
      try {
        if (_user.id.isEmpty) {
          _user.institutionId = _firstAccessInstitution != null
              ? _firstAccessInstitution!.id
              : Provider.of<UserController>(context, listen: false).currentInstitution.id;

          retorno = await userController.create(user: _user);
          if (retorno.returnType == ReturnType.sucess) {
            // ignore: use_build_context_synchronously
            CustomMessage.sucess(context, message: 'Login criado com sucesso');
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          }
        } else {
          retorno = await userController.update(user: _user);
          if (retorno.returnType == ReturnType.sucess) {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          }
        }

        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == ReturnType.error) {
          // ignore: use_build_context_synchronously
          CustomMessage.error(context, message: retorno.message);
        }
      } finally {
        _saveingData = false;
      }
    }
  }

  Widget _genderSelection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Padding(padding: EdgeInsets.all(8.0), child: Text('Gênero')),
          const Spacer(),
          Center(
            child: ToggleButtons(
              isSelected: _selectedGender,
              fillColor: Theme.of(context).primaryColor,
              selectedColor: Colors.black,
              onPressed: (index) {
                setState(() {
                  _user.gender = index == 0 ? 'F' : 'M';
                  _selectedGender = [index == 0, index == 1];
                });
              },
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Text(
                      'Feminino',
                      textAlign: TextAlign.center,
                      style: _user.gender == 'F'
                          ? TextStyle(color: Theme.of(context).cardColor)
                          : TextStyle(color: Theme.of(context).primaryColor),
                    )),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Text(
                      'Masculino',
                      textAlign: TextAlign.center,
                      style: _user.gender == 'M'
                          ? TextStyle(color: Theme.of(context).cardColor)
                          : TextStyle(color: Theme.of(context).primaryColor),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _initialization() {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _user = arguments['user'] ?? User();
      _user = User.fromMap(_user.toMap());
      _firstAccessInstitution = arguments['firstAccessInstitution'];

      if (_user.registration.isNotEmpty) {
        _registrationController.text = _user.registration;
        _nameController.text = _user.name;
        _weekHoursController.text = _user.weekHours.toString();
        _dailyHoursController.text = _user.dailyHours.toString();
        Provider.of<DepartmentController>(context, listen: false)
            .getDepartmentById(departmentId: _user.departmentId)
            .then((value) => setState(() {
                  _department = value;
                  _user.departmentId = _department.id;
                }));
        _selectedGender = [_user.gender == 'F', _user.gender == 'M'];
      }

      if (_firstAccessInstitution != null) {
        _user.active = true;
        _user.manager = true;
        _user.institutionResponsible = true;
        Provider.of<DepartmentController>(context, listen: false)
            .getDepartmentByIdFirstAccess(firstAccessInstitutionId: _firstAccessInstitution!.id)
            .then((value) => setState(() {
                  _department = value;
                  _user.departmentId = _department.id;
                }));
      }

      _initializing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _initialization();

    return CustomScaffold(
      title: _user.id == "" ? 'Novo usuário' : 'Alterar dados',
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_firstAccessInstitution != null)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Para utilizar o Escala, você precisa criar um usuário geral e informar os dados básicos da instituição onde trabalha",
                      ),
                    ),
                  if (_firstAccessInstitution == null)
                    DepartmentSelectionComponent(
                      error: _departmentError,
                      selectionItem: _user.departmentId.isEmpty
                          ? DepartmentCard(department: Department(), screenMode: ScreenMode.showItem).emptyCard(context)
                          : DepartmentCard(
                              department: _department,
                              screenMode: ScreenMode.showItem,
                              cropped: false,
                            ),
                      onTap: () async {
                        var department = await showModalBottomSheet<Department>(
                          context: context,
                          isDismissible: true,
                          builder: (context) => const DepartmentSelectionList(),
                        );
                        if (department != null) {
                          setState(() {
                            _departmentError = false;
                            _department = department;
                            _user.departmentId = _department.id;
                          });
                        }
                      },
                    ),

                  // name
                  CustomTextEdit(
                    context: context,
                    controller: _nameController,
                    labelText: 'Nome',
                    hintText: 'Informe seu nome',
                    onSave: (value) => _user.name = value ?? '',
                    prefixIcon: Icons.person,
                    textInputAction: TextInputAction.next,
                    focusNode: _nameFocus,
                    nextFocusNode: _registrationFocus,
                    validator: (value) {
                      final finalValue = value ?? '';
                      if (finalValue.trim().isEmpty) return 'O nome deve ser informado';
                      return null;
                    },
                  ),
                  // registration
                  CustomTextEdit(
                    context: context,
                    controller: _registrationController,
                    labelText: 'Matrícula',
                    hintText: 'Informe a matrícula',
                    onSave: (value) => _user.registration = value ?? '',
                    prefixIcon: Icons.person,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _registrationFocus,
                    nextFocusNode: _weekHoursFocus,
                    validator: (value) {
                      final finalValue = value ?? '';
                      if (finalValue.trim().isEmpty) return 'A matrícula deve ser';
                      return null;
                    },
                  ),
                  _genderSelection(context),
                  // Week Hours
                  //CustomTextEdit(
                  //  context: context,
                  //  controller: _weekHoursController,
                  //  labelText: 'Horas Semanais',
                  //  hintText: 'Informe a quantidade de horas trabalhadas na semana',
                  //  onSave: (value) => _user.weekHours = int.tryParse(value ?? '') ?? 0,
                  //  prefixIcon: Icons.person,
                  //  textInputAction: TextInputAction.next,
                  //  keyboardType: TextInputType.number,
                  //  focusNode: _weekHoursFocus,
                  //  nextFocusNode: _dailyHoursFocus,
                  //  validator: (value) {
                  //    final finalValue = value ?? '';
                  //    if (finalValue.trim().isEmpty) return 'A quantidade de horas';
                  //    return null;
                  //  },
                  //),
                  // Daily Hours
                  //CustomTextEdit(
                  //  context: context,
                  //  controller: _dailyHoursController,
                  //  labelText: 'Horas diárias',
                  //  hintText: 'Informe a quantida de horas trabalhadas diariamente',
                  //  onSave: (value) => _user.dailyHours = int.tryParse(value ?? '') ?? 0,
                  //  prefixIcon: Icons.person,
                  //  textInputAction: TextInputAction.next,
                  //  keyboardType: TextInputType.number,
                  //  focusNode: _dailyHoursFocus,
                  //  nextFocusNode: _passwordFocus,
                  //  validator: (value) {
                  //    final finalValue = value ?? '';
                  //    if (finalValue.trim().isEmpty) return 'A matrícula deve ser';
                  //    return null;
                  //  },
                  //),
                  if (_user.registration.isNotEmpty) const SizedBox(height: 10),
                  if (_user.registration.isNotEmpty)
                    const Text(
                      'Se quiser alterar a senha informe ela e a repita nos campos abaixo, caso contrário deixe-os em branco',
                    ),
                  // password
                  CustomTextEdit(
                    context: context,
                    controller: _passwordController,
                    labelText: 'Senha',
                    hintText: 'Informe sua senha',
                    isPassword: true,
                    onSave: (value) => _user.password = Util.encrypt(value ?? ''),
                    prefixIcon: Icons.lock,
                    textInputAction: TextInputAction.next,
                    focusNode: _passwordFocus,
                    nextFocusNode: _confirmPasswordFocus,
                    validator: (value) {
                      final finalValue = value ?? '';
                      // faz com que a checagem da senha ocorra obrigatoriamente em um novo login
                      if (_user.id.isEmpty) {
                        if (finalValue.trim().isEmpty) return 'Informe a senha';
                        if (finalValue.trim().length < 6) return 'Senha deve possuir 6 ou mais caracteres';
                        if (finalValue != _confirmPasswordController.text) return 'As senhas digitadas não são iguais';
                      } else {
                        // em uma edição a checagem só deve ser feita se houve edição
                        if (finalValue.trim().isNotEmpty && _confirmPasswordController.text.isNotEmpty) {
                          if (finalValue.trim().isEmpty) return 'Informe a senha';
                          if (finalValue.trim().length < 6) return 'Senha deve possuir 6 ou mais caracteres';
                          if (finalValue != _confirmPasswordController.text) return 'As senhas digitadas não são iguais';
                        }
                      }
                      return null;
                    },
                  ),
                  // password confirmation
                  CustomTextEdit(
                    context: context,
                    controller: _confirmPasswordController,
                    labelText: 'Repita a senha',
                    hintText: 'Informe sua senha novamente',
                    isPassword: true,
                    prefixIcon: Icons.lock,
                    textInputAction: TextInputAction.next,
                    focusNode: _confirmPasswordFocus,
                    validator: (value) {
                      final finalValue = value ?? '';
                      if (_user.id.isEmpty) {
                        if (finalValue.trim().isEmpty) return 'Informe a senha';
                        if (finalValue.trim().length < 6) return 'Senha deve possuir 6 ou mais caracteres';
                        if (finalValue != _passwordController.text) return 'As senhas digitadas não são iguais';
                      } else {
                        if (finalValue.trim().isNotEmpty && _passwordController.text.isNotEmpty) {
                          if (finalValue.trim().isEmpty) return 'Informe a senha';
                          if (finalValue.trim().length < 6) return 'Senha deve possuir 6 ou mais caracteres';
                          if (finalValue != _passwordController.text) return 'As senhas digitadas não são iguais';
                        }
                      }
                      return null;
                    },
                  ),
                  // Manager
                  CustomCheckBox(
                    context: context,
                    value: _firstAccessInstitution != null ? true : _user.manager,
                    title: 'Gestor',
                    onChanged: (value) => setState(() => _user.manager = value!),
                    enabled: _firstAccessInstitution != null ||
                        Provider.of<UserController>(context, listen: false).currentUser.manager,
                  ),
                  // Active
                  CustomCheckBox(
                    context: context,
                    value: _firstAccessInstitution != null ? true : _user.active,
                    title: 'Ativo',
                    onChanged: (value) => setState(() => _user.active = value!),
                    enabled: _firstAccessInstitution != null ||
                        Provider.of<UserController>(context, listen: false).currentUser.manager,
                  ),
                  // Institution Responsible
                  CustomCheckBox(
                    context: context,
                    value: _firstAccessInstitution != null ? true : _user.institutionResponsible,
                    title: 'Responsável pela instituição',
                    onChanged: (value) => setState(() => _user.institutionResponsible = value!),
                    enabled: _firstAccessInstitution != null ||
                        Provider.of<UserController>(context, listen: false).currentUser.manager,
                  ),

                  if (_firstAccessInstitution != null) const SizedBox(height: 5),
                  // Buttons
                  ButtonsLine(
                    buttons: [
                      Button(
                        label: 'Cancelar',
                        onPressed: () async {
                          if (_firstAccessInstitution != null) {
                            await Provider.of<InstitutionController>(context, listen: false).delete(
                              institution: _firstAccessInstitution!,
                            );
                            Util.restartApplication();
                          }
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        },
                      ),
                      Button(label: _user.registration == '' ? 'Cadastrar novo usuário' : 'Confirmar', onPressed: _submit),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
