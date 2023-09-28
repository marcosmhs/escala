// ignore_for_file: use_build_context_synchronously

import 'package:escala/components/messaging/custom_dialog.dart';
import 'package:escala/components/messaging/custom_message.dart';
import 'package:escala/components/screen_elements/custom_scaffold.dart';
import 'package:escala/components/util/custom_return.dart';
import 'package:escala/components/util/util.dart';
import 'package:escala/components/visual_elements/buttons_line.dart';
import 'package:escala/components/visual_elements/custom_checkbox.dart';
import 'package:escala/components/visual_elements/custom_textFormField.dart';
import 'package:escala/features/institution/institution.dart';
import 'package:escala/features/institution/institution_controller.dart';
import 'package:escala/features/main/routes.dart';
import 'package:escala/features/user/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InstitutionRemoveScreen extends StatefulWidget {
  const InstitutionRemoveScreen({super.key});

  @override
  State<InstitutionRemoveScreen> createState() => _InstitutionRemoveScreenState();
}

class _InstitutionRemoveScreenState extends State<InstitutionRemoveScreen> {
  bool _saveingData = false;

  bool _initializing = true;
  var _userPasseword = '';
  var _confirmExclusion = false;

  var institution = Institution();

  void _submit() async {
    if (_saveingData) return;

    if (_userPasseword.isEmpty) {
      CustomDialog(context: context).errorMessage(message: 'Informe sua senha para iniciar a exclusão da instituição');
      return;
    }

    if (Provider.of<UserController>(context, listen: false).currentUser.password != Util.encrypt(_userPasseword)) {
      CustomDialog(context: context).errorMessage(message: 'Senha inválida');
      return;
    }

    if (!_confirmExclusion) {
      CustomDialog(context: context).errorMessage(message: 'Marque a opção de confirmação da exclusão');
      return;
    }

    CustomDialog(context: context)
        .confirmationDialog(
            message: 'Deseja realmente excluir os dados de sua instituição? \n\n Este processo não pode ser revertido')
        .then((response) async {
      if (response != true) return;

      _saveingData = true;
      // salva os dados
      InstitutionController institutionController = Provider.of(context, listen: false);
      CustomReturn retorno;
      try {
        retorno = await institutionController.markInstitutionForExclusion(
          institution: Provider.of<UserController>(context, listen: false).currentInstitution,
        );

        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == ReturnType.error) {
          CustomMessage.error(context, message: retorno.message);
        }
        Provider.of<UserController>(context, listen: false).logout();
        Navigator.restorablePushNamedAndRemoveUntil(
          context,
          Routes.landingScreen,
          (route) => false,
        );
      } finally {
        _saveingData = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      institution = Provider.of<UserController>(context, listen: false).currentInstitution;

      _initializing = false;
    }

    return CustomScaffold(
      title: 'Remover dados da instituição',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text('Como funciona este processo', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              const Text(
                  'Assim que a solicitação for confirmada os dados da instituição serão marcados para exclusão e todos os acessos serão bloqueados'),
              const SizedBox(height: 5),
              const Text(
                  'Em até 5 dias após a solicitação os dados (inclusive os dados das pessoas) serão removidos permanentemente'),
              const SizedBox(height: 5),
              const Text('Somente uma pessoa responsável pela instituição pode solicitar o acesso'),

              const SizedBox(height: 15),
              const Text('Para seguir com o processo informe sua senha'),
              // password
              CustomTextEdit(
                context: context,
                labelText: 'Senha',
                hintText: 'Confirme sua senha',
                onSave: (value) => institution.name = value ?? '',
                prefixIcon: Icons.password,
                textInputAction: TextInputAction.next,
                onChanged: (value) => _userPasseword = value ?? '',
                isPassword: true,
              ),
              const SizedBox(height: 20),
              CustomCheckBox(
                context: context,
                value: _confirmExclusion,
                title: 'Marque esta opção para confirmar que deseja excluir os dados de sua instituição',
                onChanged: (value) => setState(() => _confirmExclusion = value!),
              ),
              const SizedBox(height: 20),
              ButtonsLine(
                buttons: [
                  Button(label: 'Cancelar', onPressed: () => Navigator.of(context).pop()),
                  Button(
                    label: 'Remover dados da instituição',
                    onPressed: _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
