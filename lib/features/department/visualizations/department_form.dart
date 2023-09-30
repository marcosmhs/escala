import 'package:escala/components/messaging/custom_message.dart';
import 'package:escala/components/screen_elements/custom_scaffold.dart';
import 'package:escala/components/util/custom_return.dart';
import 'package:escala/components/visual_elements/buttons_line.dart';
import 'package:escala/components/visual_elements/custom_checkbox.dart';
import 'package:escala/components/visual_elements/custom_textFormField.dart';
import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/department_controller.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:flutter/material.dart';

class DepartmentForm extends StatefulWidget {
  const DepartmentForm({super.key});

  @override
  State<DepartmentForm> createState() => _DepartmentFormState();
}

class _DepartmentFormState extends State<DepartmentForm> {
  var _department = Department();
  bool _initializing = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _maxPeopleDayOffController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saveingData = false;

  var _user = User();

  void _submit() async {
    if (_saveingData) return;

    _saveingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _saveingData = false;
    } else {
      // salva os dados
      _formKey.currentState?.save();
      CustomReturn retorno;
      try {
        retorno = await DepartmentController(_user).save(department: _department);

        if (retorno.returnType == ReturnType.sucess) {
          // ignore: use_build_context_synchronously
          CustomMessage.sucess(context,
              message: _department.id.isEmpty ? 'Área/setor criado com sucesso!' : 'Área/setor alterado com sucesso!');
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        } else {
          // ignore: use_build_context_synchronously
          CustomMessage.error(context, message: retorno.message);
        }
      } finally {
        _saveingData = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;

      _user = arguments['user'] ?? User();
      _user = User.fromMap(_user.toMap());

      _department = arguments['department'] ?? Department();
      _department = Department.fromMap(_department.toMap());
      _nameController.text = _department.name;
      _maxPeopleDayOffController.text = _department.maxPeopleDayOff.toString();
      _initializing = false;
    }

    return CustomScaffold(
      title: _department.id == "" ? 'Nova área/setor' : 'Alterar seus área/setor',
      responsive: true,
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // name
                  CustomTextEdit(
                    context: context,
                    controller: _nameController,
                    labelText: 'Nome',
                    hintText: 'Informe da área/setor',
                    onSave: (value) => _department.name = value ?? '',
                    prefixIcon: Icons.person,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final finalValue = value ?? '';
                      if (finalValue.trim().isEmpty) return 'O nome deve ser informado';
                      return null;
                    },
                  ),
                  // maxPeopleDayOff
                  CustomTextEdit(
                    context: context,
                    controller: _maxPeopleDayOffController,
                    labelText: 'Máximo de pessoas com folga no mesmo dia',
                    hintText: 'Informe o máximo de pessoas com folga no mesmo dia',
                    onSave: (value) => _department.maxPeopleDayOff = int.tryParse(value ?? '') ?? 0,
                    prefixIcon: Icons.people_alt,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final finalValue = int.tryParse(value ?? '') ?? 0;
                      if (finalValue == 0) return 'Informe o máximo de pessoas com folga no mesmo dia';
                      return null;
                    },
                  ),

                  // Active
                  CustomCheckBox(
                    context: context,
                    value: _department.active,
                    title: 'Ativo',
                    onChanged: (value) => setState(() => _department.active = value!),
                  ),

                  ButtonsLine(
                    buttons: [
                      Button(label: 'Cancelar', onPressed: () => Navigator.of(context).pop()),
                      Button(label: 'Salvar dados', onPressed: _submit),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
