import 'package:escala/components/messaging/custom_dialog.dart';
import 'package:escala/components/messaging/custom_message.dart';
import 'package:escala/components/screen_elements/custom_scaffold.dart';
import 'package:escala/components/util/custom_return.dart';
import 'package:escala/components/visual_elements/buttons_line.dart';
import 'package:escala/components/visual_elements/custom_checkbox.dart';
import 'package:escala/components/visual_elements/custom_textFormField.dart';
import 'package:escala/features/institution/institution.dart';
import 'package:escala/features/institution/institution_controller.dart';
import 'package:escala/features/main/routes.dart';
import 'package:escala/features/user/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages

class InstitutionForm extends StatefulWidget {
  const InstitutionForm({super.key});

  @override
  State<InstitutionForm> createState() => _InstitutionFormState();
}

class _InstitutionFormState extends State<InstitutionForm> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _saveingData = false;

  bool _initializing = true;
  bool _firstAccess = false;

  var institution = Institution();

  void _submit() async {
    if (_saveingData) return;

    _saveingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _saveingData = false;
    } else {
      // salva os dados
      _formKey.currentState?.save();
      InstitutionController institutionController = Provider.of(context, listen: false);
      CustomReturn retorno;
      try {
        if (institution.id.isEmpty) {
          retorno = await institutionController.create(institution: institution);
          if (retorno.returnType == ReturnType.sucess) {
            // ignore: use_build_context_synchronously
            CustomMessage.sucess(context, message: 'Instituição criado com sucesso');
            // ignore: use_build_context_synchronously
            if (retorno.returnType == ReturnType.sucess) {
              if (_firstAccess) {
                // ignore: use_build_context_synchronously
                Navigator.pushReplacementNamed(
                  context,
                  Routes.userForm,
                  arguments: {'firstAccessInstitution': institutionController.currentInstitution},
                );
              } else {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              }
            }
          }
        } else {
          retorno = await institutionController.update(institution: institution);
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _firstAccess = arguments['firstAccess'] ?? false;

      if (!_firstAccess) {
        institution = Provider.of<UserController>(context, listen: false).currentInstitution;
        _nameController.text = institution.name;
      }

      _initializing = false;
    }

    return CustomScaffold(
      title: 'Instituição',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_firstAccess)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Informe os dados básicos de sua instituição"),
                  ),
                // name
                CustomTextEdit(
                  context: context,
                  controller: _nameController,
                  labelText: 'Nome',
                  hintText: 'Nome da instituição',
                  onSave: (value) => institution.name = value ?? '',
                  prefixIcon: Icons.store,
                  textInputAction: TextInputAction.next,
                  focusNode: _nameFocus,
                  validator: (value) {
                    final finalValue = value ?? '';
                    if (finalValue.trim().isEmpty) return 'O nome deve ser informado';
                    return null;
                  },
                ),
                // Active
                CustomCheckBox(
                  context: context,
                  value: _firstAccess ? true : institution.active,
                  title: 'Instituição ativa',
                  onChanged: (value) => setState(() {
                    if (value == true) {
                      setState(() => institution.active = true);
                    } else {
                      CustomDialog(context: context)
                          .confirmationDialog(
                              message: 'Se desativar a instituição ninguém mais poderá acessar suas escalas. Deseja continuar?')
                          .then(
                            (confirmationValue) => {if (confirmationValue == true) setState(() => institution.active = false)},
                          );
                    }
                  }),
                  enabled: !_firstAccess,
                ),

                if (_firstAccess) const SizedBox(height: 5),
                ButtonsLine(
                  buttons: [
                    Button(label: 'Cancelar', onPressed: () => Navigator.of(context).pop()),
                    Button(
                      label: institution.id == '' ? 'Cadastrar nova instituição' : 'Altera dados da instituição',
                      onPressed: _submit,
                    ),
                  ],
                ),

                if (_firstAccess) const SizedBox(height: 10),
                if (_firstAccess)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Após o cadastro você será direcionado para a tela de cadatro dos seus dados",
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
