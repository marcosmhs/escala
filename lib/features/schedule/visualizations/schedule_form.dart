import 'package:escala/components/messaging/custom_dialog.dart';
import 'package:escala/components/messaging/custom_message.dart';
import 'package:escala/components/util/custom_return.dart';
import 'package:escala/components/util/util.dart';
import 'package:escala/components/visual_elements/buttons_line.dart';
import 'package:escala/components/screen_elements/custom_scaffold.dart';
import 'package:escala/components/visual_elements/custom_textFormField.dart';
import 'package:escala/components/visual_elements/month_picker/custom_month_picker.dart';
import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/department_controller.dart';
import 'package:escala/features/department/visualizations/department_card.dart';
import 'package:escala/features/department/visualizations/department_selection_component.dart';
import 'package:escala/features/department/visualizations/department_selection_list.dart';
import 'package:escala/features/institution/institution.dart';
import 'package:escala/features/institution/visualizations/schedule_date_config_colors_example.dart';
import 'package:escala/features/schedule/schedule_controller.dart';
import 'package:escala/features/schedule/models/schedule.dart';
import 'package:escala/features/schedule/visualizations/schedule_users_component.dart';
import 'package:escala/features/user/user_controller.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleForm extends StatefulWidget {
  const ScheduleForm({super.key});

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _maxPeopleDayOffController = TextEditingController();
  bool _isInitialized = false;
  bool _freshGeneratedSchedule = false;

  bool isButtonLineVisible = true;
  String freshGeneratedScheduleId = '';
  bool releasingSchedule = false;
  bool _scheduleGenerationFinished = true;
  var _departmentUserAmountText = '';

  Institution _institution = Institution();

  var _departmentError = false;
  var _department = Department();
  late TabController _tabController;

  List<String> _scheduleGenerationStatusList = [];

  Schedule schedule = Schedule();

  List<ScheduleDateUser> _scheduleDateUsers = [];

  void _releaseSchedule({required String scheduleId, required ScheduleStatus scheduleStatus}) async {
    if (!releasingSchedule) {
      CustomDialog(context: context)
          .confirmationDialog(
              message: scheduleStatus == ScheduleStatus.teamValidation
                  ? 'Confirma a liberação da escala para o time validá-la?'
                  : 'Liberar a escala? Depois de liberada ela não poderá ser alterada ou excluída.')
          .then((value) {
        if (value == true) {
          setState(() => releasingSchedule = true);
          try {
            Provider.of<ScheduleController>(context, listen: false)
                .releaseSchedule(scheduleId: scheduleId, scheduleStatus: scheduleStatus)
                .then((value) {
              Provider.of<ScheduleController>(context, listen: false).getScheduleById(scheduleId).then((value) {
                setState(() => schedule = value);
                setState(() => releasingSchedule = false);
              });
            });
          } catch (e) {
            setState(() => releasingSchedule = false);
          }
        }
      });
    }
  }

  void _generateSchedule() {
    if (schedule.departmentId.isEmpty) {
      setState(() => _departmentError = true);
      CustomMessage(
        context: context,
        messageText: 'Para gerar uma escala é necessário selecionar a área/departamento',
        messageType: MessageType.error,
      );
      return;
    }

    if (schedule.initialDate == null || schedule.finalDate == null) {
      setState(() => _departmentError = true);
      CustomMessage(
        context: context,
        messageText: 'É necessário selecionar um mês para a geração da escala',
        messageType: MessageType.error,
      );
      return;
    }
    if ((_formKey.currentState?.validate() ?? true)) {
      _formKey.currentState?.save();
      setState(() {
        _scheduleGenerationFinished = false;
        _freshGeneratedSchedule = true;
        _scheduleGenerationStatusList = [];
      });

      CustomMessage(
        context: context,
        messageType: MessageType.info,
        durationInSeconds: 5,
        messageText: 'Geração da escala iniciada',
      );

      Provider.of<ScheduleController>(context, listen: false).generateSchedule(schedule: schedule).then((customReturn) {
        setState(() {
          _scheduleGenerationFinished = true;
          if (customReturn.returnType == ReturnType.error) {
            CustomMessage.error(context, message: customReturn.message);
          } else {
            CustomMessage.sucess(context, message: 'Escala finalizada');
          }
        });
      });
    }
  }

  Widget _buttonsLine() {
    return ButtonsLine(
      buttons: [
        Button(
          label: schedule.id == '' ? 'Gerar escala' : 'Refazer Escala',
          onPressed: _generateSchedule,
          enabled: schedule.status != ScheduleStatus.released && !releasingSchedule,
        ),
        Button(
          label: 'Liberar/Finalizar',
          onPressed: () => {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('O que deseja fazer?'),
                  content: Container(
                    padding: const EdgeInsets.all(8),
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(children: [
                      _scheduleOptionsItemStructure(
                        title: 'Permitir que as pessoas alocas nesta área/setor possam validar a escala e sugerir alterações',
                        shadowColor: Theme.of(context).primaryColor,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _releaseSchedule(
                                  scheduleId: _freshGeneratedSchedule ? freshGeneratedScheduleId : schedule.id,
                                  scheduleStatus: ScheduleStatus.teamValidation);
                            },
                            child: const Text('Liberar para validação'),
                          )
                        ],
                      ),
                      _scheduleOptionsItemStructure(
                        title: 'Finalizar a escala e compartilhar com todo sem permitir sugestões de alteração',
                        shadowColor: Theme.of(context).primaryColor,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _releaseSchedule(
                                  scheduleId: _freshGeneratedSchedule ? freshGeneratedScheduleId : schedule.id,
                                  scheduleStatus: ScheduleStatus.released);
                            },
                            child: const Text('Finalizar e liberar'),
                          )
                        ],
                      ),
                    ]),
                  ),
                );
              },
            )
          },
          enabled: schedule.status != ScheduleStatus.released && !releasingSchedule,
        ),
      ],
    );
  }

  void _initializingPreparation({required BuildContext context}) {
    if (!_isInitialized) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      schedule = arguments['schedule'] ?? Schedule();
      schedule = Schedule.fromMap(schedule.toMap());
      if (schedule.id.isNotEmpty) {
        Provider.of<ScheduleController>(context, listen: false).getScheduleDates(scheduleId: schedule.id).then((value) {
          setState(() => _scheduleDateUsers = value);
          setState(() => _freshGeneratedSchedule = false);
          _maxPeopleDayOffController.text = schedule.maxPeopleDayOff.toString();
        });

        _department = arguments['department'] ?? Department();
        if (_department.id.isEmpty) {
          _departmentError = true;
          Provider.of<DepartmentController>(context, listen: false)
              .getDepartmentById(departmentId: schedule.departmentId)
              .then((value) => setState(() {
                    _department = value;
                    _departmentError = false;
                  }));
        }
        _departmentUserAmount(departmentId: schedule.departmentId);
      }
      _institution = Provider.of<UserController>(context, listen: false).currentInstitution;
      _isInitialized = true;
    }
  }

  Widget _scheduleOptionsItemStructure({
    String title = '',
    required List<Widget> children,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    Color? shadowColor,
  }) {
    return Card(
      shadowColor: shadowColor,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            if (title.isNotEmpty) Text(title),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            ),
          ],
        ),
      ),
    );
  }

  void _departmentUserAmount({required String departmentId}) {
    if (departmentId.isEmpty) return;

    Provider.of<UserController>(context, listen: false)
        .getUsersFromDepartment(departmentId: departmentId, onlyActiveUsers: true)
        .then((value) {
      if (value.isNotEmpty) {
        setState(() => _departmentUserAmountText = '${value.length} pessoas alocadas nesta área/setor');
      }
    });
  }

  Widget _scheduleParameters(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // month
                _scheduleOptionsItemStructure(
                  title: 'Mês da escala',
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        CustomMonthPicker.showMonthYearPickerDialog(context: context).then((value) {
                          setState(() {
                            schedule.initialDate = Util.firstDayOfMonth(value);
                            schedule.finalDate = Util.lastDayOfMonth(value);
                          });
                        });
                      },
                      child: Text(schedule.id.isEmpty ? 'Selecionar mês' : 'Alterar mês'),
                    ),
                    Text(schedule.initialDate == null || schedule.finalDate == null
                        ? 'Selecione um mês'
                        : '${Util.dateTimeFormat(date: schedule.initialDate!)} à ${Util.dateTimeFormat(date: schedule.finalDate!)}'),
                  ],
                ),
                // department
                _scheduleOptionsItemStructure(
                  title: 'Área/setor',
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DepartmentSelectionComponent(
                          error: _departmentError,
                          selectionItem: schedule.departmentId.isEmpty
                              ? DepartmentCard(
                                  department: Department(),
                                  screenMode: ScreenMode.showItem,
                                  elevation: 0,
                                ).emptyCard(context)
                              : DepartmentCard(
                                  department: _department,
                                  screenMode: ScreenMode.showItem,
                                  cropped: false,
                                  elevation: 0,
                                ),
                          onTap: () {
                            showModalBottomSheet<Department>(
                              context: context,
                              isDismissible: true,
                              builder: (context) => const DepartmentSelectionList(),
                            ).then((value) {
                              if (value != null) {
                                setState(() {
                                  _departmentError = false;
                                  _department = value;
                                  schedule.departmentId = _department.id;
                                  schedule.maxPeopleDayOff = _department.maxPeopleDayOff;
                                  _maxPeopleDayOffController.text = _department.maxPeopleDayOff.toString();
                                });
                                _departmentUserAmount(departmentId: _department.id);
                              }
                            });
                          },
                        ),
                        if (_departmentUserAmountText.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(_departmentUserAmountText),
                          ),
                      ],
                    ),
                  ],
                ),
                // max person with dayoff on same day
                Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Máximo de pessoas com folga no mesmo dia'),
                        const SizedBox(height: 5),
                        CustomTextEdit(
                          context: context,
                          controller: _maxPeopleDayOffController,
                          onSave: (value) {
                            schedule.maxPeopleDayOff = int.tryParse(value ?? '') ?? 0;
                          },
                          labelText: '',
                          hintText: 'Informe o máximo de pessoas com folga no mesmo dia',
                          prefixIcon: Icons.people_alt,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            final finalValue = int.tryParse(value ?? '') ?? 0;
                            if (finalValue == 0) return 'Informe o máximo de pessoas com folga no mesmo dia';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // schedule status
                _scheduleOptionsItemStructure(
                  title: 'Situação da escala',
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text(schedule.statusLabel()),
                      ),
                    ),
                  ],
                ),
                // button line
                if (_scheduleGenerationFinished)
                  _scheduleOptionsItemStructure(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [_buttonsLine()],
                  ),
                // generation indicator
                if (!_scheduleGenerationFinished)
                  _scheduleOptionsItemStructure(
                    children: [
                      const Text('Gerando a escala'),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ],
                  ),
                StreamBuilder<ScheduleStreamReturn>(
                  stream: Provider.of<ScheduleController>(context, listen: false).scheduleStreamController,
                  initialData: ScheduleStreamReturn([], [], ScheduleStreamReturnStatus.finished),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.none) {
                      return const Text('Verifique sua conexão com a internet');
                    } else if (snapshot.hasError) {
                      return Text('Erro: ${snapshot.error}');
                    } else {
                      final data = snapshot.data;
                      // Controla a visibilidade do botão
                      isButtonLineVisible =
                          data!.status == ScheduleStreamReturnStatus.finished || data.status == ScheduleStreamReturnStatus.error;
                      if (data.scheduleDateUsers.isNotEmpty) {
                        freshGeneratedScheduleId = data.scheduleDateUsers.first.scheduleDates.first.scheduleId;
                      }

                      if (data.status == ScheduleStreamReturnStatus.finished && data.scheduleDateUsers.isNotEmpty) {
                        _scheduleDateUsers.clear();
                        _scheduleDateUsers.addAll(data.scheduleDateUsers);
                        _tabController.animateTo(
                          1,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeOut,
                        );
                      }

                      if (data.statusList.isNotEmpty) {
                        _scheduleGenerationStatusList.clear();
                        _scheduleGenerationStatusList.addAll(data.statusList);
                      }

                      return Column(
                        children: [
                          if (_scheduleGenerationStatusList.isNotEmpty)
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _scheduleGenerationStatusList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  child: Text(_scheduleGenerationStatusList[index]),
                                );
                              },
                            ),
                        ],
                      );
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleDates(BuildContext ctx) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ScheduleUsersComponent(
            context: ctx,
            institution: _institution,
            scheduleDateUsers: _scheduleDateUsers,
            scheduleStatus: schedule.status,
            scheduleId: schedule.id,
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    _initializingPreparation(context: context);

    return CustomScaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isDismissible: true,
                  builder: (context) => ScheduleDateConfigColorsExample(institution: _institution),
                );
              },
              icon: const Icon(Icons.question_mark))
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(schedule.id == "" ? 'Nova Escala' : 'Alterar Escala'),
            Text(
              'Situação: ${schedule.statusLabel()}',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
                color: Theme.of(context).cardColor,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Parâmetros'),
            Tab(text: 'Escalas geradas'),
          ],
        ),
      ),
      showAppDrawer: true,
      body: TabBarView(
        controller: _tabController,
        children: [_scheduleParameters(context), _scheduleDates(context)],
      ),
    );
  }
}
