// ignore_for_file: use_build_context_synchronously
import 'package:escala/features/institution/institution.dart';
import 'package:escala/features/institution/institution_controller.dart';
import 'package:escala/features/main/routes.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:escala/features/user/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/messaging/teb_custom_dialog.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_util.dart';
import 'package:teb_package/visual_elements/teb_buttons_line.dart';
import 'package:teb_package/visual_elements/teb_checkbox.dart';
import 'package:teb_package/visual_elements/teb_text_form_field.dart';

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

  var _institution = Institution();
  var _user = User();

  void _submit() async {
    if (_saveingData) return;

    if (_userPasseword.isEmpty) {
      TebCustomDialog(context: context).errorMessage(message: 'Informe sua senha para iniciar a exclusão da instituição');
      return;
    }

    if (_user.password != TebUtil.encrypt(_userPasseword)) {
      TebCustomDialog(context: context).errorMessage(message: 'Senha inválida');
      return;
    }

    if (!_confirmExclusion) {
      TebCustomDialog(context: context).errorMessage(message: 'Marque a opção de confirmação da exclusão');
      return;
    }

    TebCustomDialog(context: context)
        .confirmationDialog(
            message: 'Deseja realmente excluir os dados de sua instituição? \n\n Este processo não pode ser revertido')
        .then((response) async {
      if (response != true) return;

      _saveingData = true;
      // salva os dados
      TebCustomReturn retorno;
      try {
        retorno = await InstitutionController(_user).markInstitutionForExclusion(institution: _institution, user: _user);

        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == TebReturnType.error) {
          TebCustomMessage.error(context, message: retorno.message);
        }
        UserController().logout();
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
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _user = arguments['user'] ?? User();

      InstitutionController(_user)
          .getInstitutionFromId(institutionId: _user.institutionId)
          .then((institution) => setState(() => _institution = institution));

      _initializing = false;
    }

    return TebCustomScaffold(
      responsive: true,
      title: const Text('Remover dados da instituição'),
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
              TebTextEdit(
                context: context,
                labelText: 'Senha',
                hintText: 'Confirme sua senha',
                onSave: (value) => _institution.name = value ?? '',
                prefixIcon: Icons.password,
                textInputAction: TextInputAction.next,
                onChanged: (value) => _userPasseword = value ?? '',
                isPassword: true,
              ),
              const SizedBox(height: 20),
              TebCheckBox(
                context: context,
                value: _confirmExclusion,
                title: 'Marque esta opção para confirmar que deseja excluir os dados de sua instituição',
                onChanged: (value) => setState(() => _confirmExclusion = value!),
              ),
              const SizedBox(height: 20),
              TebButtonsLine(
                buttons: [
                  TebButton(label: 'Cancelar', onPressed: () => Navigator.of(context).pop()),
                  TebButton(
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
