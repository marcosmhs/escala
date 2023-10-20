import 'package:escala/features/institution/institution.dart';
import 'package:escala/features/institution/institution_controller.dart';
import 'package:escala/features/main/routes.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/messaging/teb_custom_dialog.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/visual_elements/teb_buttons_line.dart';
import 'package:teb_package/visual_elements/teb_checkbox.dart';
import 'package:teb_package/visual_elements/teb_text_form_field.dart';

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

  var _institution = Institution();
  var _user = User();

  void _submit() async {
    if (_saveingData) return;

    _saveingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _saveingData = false;
    } else {
      // salva os dados
      _formKey.currentState?.save();
      TebCustomReturn retorno;
      try {
        if (_institution.id.isEmpty) {
          retorno = await InstitutionController(_user).create(institution: _institution);
          if (retorno.returnType == TebReturnType.sucess) {
            // ignore: use_build_context_synchronously
            TebCustomMessage.sucess(context, message: 'Instituição criado com sucesso');
            // ignore: use_build_context_synchronously
            if (retorno.returnType == TebReturnType.sucess) {
              if (_firstAccess) {
                // ignore: use_build_context_synchronously
                Navigator.pushReplacementNamed(
                  context,
                  Routes.userForm,
                  arguments: {'firstAccessInstitution': _institution},
                );
              } else {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              }
            }
          }
        } else {
          retorno = await InstitutionController(_user).update(institution: _institution);
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }

        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == TebReturnType.error) {
          // ignore: use_build_context_synchronously
          TebCustomMessage.error(context, message: retorno.message);
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

      _user = arguments['user'] ?? User();
      _user = User.fromMap(_user.toMap());

      if (!_firstAccess) {
        InstitutionController(_user).getInstitutionFromId(institutionId: _user.institutionId).then((institution) {
          setState(() {
            _institution = institution;
            _nameController.text = _institution.name;
          });
        });
      }

      _initializing = false;
    }

    return TebCustomScaffold(
      responsive: true,
      title: const Text('Instituição'),
      body: Padding(
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
              TebTextEdit(
                context: context,
                controller: _nameController,
                labelText: 'Nome',
                hintText: 'Nome da instituição',
                onSave: (value) => _institution.name = value ?? '',
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
              TebCheckBox(
                context: context,
                value: _firstAccess ? true : _institution.active,
                title: 'Instituição ativa',
                onChanged: (value) => setState(() {
                  if (value == true) {
                    setState(() => _institution.active = true);
                  } else {
                    TebCustomDialog(context: context)
                        .confirmationDialog(
                            message: 'Se desativar a instituição ninguém mais poderá acessar suas escalas. Deseja continuar?')
                        .then(
                          (confirmationValue) => {if (confirmationValue == true) setState(() => _institution.active = false)},
                        );
                  }
                }),
                enabled: !_firstAccess,
              ),

              if (_firstAccess) const SizedBox(height: 5),
              TebButtonsLine(
                buttons: [
                  TebButton(label: 'Cancelar', onPressed: () => Navigator.of(context).pop()),
                  TebButton(
                    label: _institution.id == '' ? 'Cadastrar nova instituição' : 'Altera dados da instituição',
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
              const Spacer(),
              if (!_firstAccess)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    child: const Text('Remover dados da instituição'),
                    onPressed: () => Navigator.of(context).pushNamed(Routes.removeInstitution, arguments: {'user': _user}),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
