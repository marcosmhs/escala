import 'package:escala/components/messaging/custom_message.dart';
import 'package:escala/components/screen_elements/custom_scaffold.dart';
import 'package:escala/components/util/custom_return.dart';
import 'package:escala/components/visual_elements/buttons_line.dart';

import 'package:escala/features/institution/institution.dart';
import 'package:escala/features/institution/institution_controller.dart';

import 'package:escala/features/user/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class InstitutionConfigForm extends StatefulWidget {
  const InstitutionConfigForm({super.key});

  @override
  State<InstitutionConfigForm> createState() => _InstitutionConfigFormState();
}

class _InstitutionConfigFormState extends State<InstitutionConfigForm> {
  final _formKey = GlobalKey<FormState>();
  bool _saveingData = false;
  Color currentColor = Colors.amber;

  bool _initializing = true;

  void changeColor(Color color) => setState(() => currentColor = color);

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
        retorno = await institutionController.update(institution: institution);
        if (retorno.returnType == ReturnType.error) {
          // ignore: use_build_context_synchronously
          CustomMessage.sucess(context, message: retorno.message);
        } else {
          // ignore: use_build_context_synchronously
          CustomMessage.sucess(context, message: 'Configurações alteradas com sucesso');

          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }
      } finally {
        _saveingData = false;
      }
    }
  }

  Card colorSelectionCard({
    required BuildContext context,
    required String buttonLabel,
    required Color pickerColor,
    required void Function(Color) onColorChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //const Text('Dia de trabalho de 6 horas'),
            //const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Selecione uma cor'),
                          content: BlockPicker(
                            pickerColor: pickerColor,
                            onColorChanged: (selectecColor) {
                              onColorChanged(selectecColor);
                              Navigator.of(context).pop();
                            },
                            useInShowDialog: true,
                          ),
                        );
                      },
                    );
                  },
                  child: Text(buttonLabel),
                ),
                const Spacer(),
                Container(
                  width: 60,
                  height: 40,
                  color: pickerColor,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      institution = Provider.of<UserController>(context, listen: false).currentInstitution;
      _initializing = false;
    }

    return CustomScaffold(
      title: 'Configurações',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Cores de indicação da escala',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
                        color: Theme.of(context).cardColor,
                      ),
                    ),
                  ),
                ),
                colorSelectionCard(
                  context: context,
                  buttonLabel: 'Dia de trabalho de 6 horas',
                  pickerColor: institution.workDay6hColor,
                  onColorChanged: (selectecColor) {
                    setState(() => institution.workDay6hColor = selectecColor);
                  },
                ),
                colorSelectionCard(
                  context: context,
                  buttonLabel: 'Dia de trabalho de 12 horas',
                  pickerColor: institution.workDay12hColor,
                  onColorChanged: (selectecColor) {
                    setState(() => institution.workDay12hColor = selectecColor);
                  },
                ),
                colorSelectionCard(
                  context: context,
                  buttonLabel: 'Folga',
                  pickerColor: institution.dayOffColor,
                  onColorChanged: (selectecColor) {
                    setState(() => institution.dayOffColor = selectecColor);
                  },
                ),
                colorSelectionCard(
                  context: context,
                  buttonLabel: 'Férias',
                  pickerColor: institution.vacationColor,
                  onColorChanged: (selectecColor) {
                    setState(() => institution.vacationColor = selectecColor);
                  },
                ),
                const SizedBox(height: 10),
                ButtonsLine(
                  buttons: [
                    Button(label: 'Cancelar', onPressed: () => Navigator.of(context).pop()),
                    Button(
                      label: institution.id == '' ? 'Cadastrar nova instituição' : 'Altera dados da instituição',
                      onPressed: _submit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}