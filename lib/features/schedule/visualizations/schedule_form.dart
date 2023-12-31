import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/department_controller.dart';
import 'package:escala/features/department/visualizations/department_card.dart';
import 'package:escala/features/department/visualizations/department_selection_component.dart';
import 'package:escala/features/department/visualizations/department_selection_list.dart';
import 'package:escala/features/institution/institution.dart';
import 'package:escala/features/institution/institution_controller.dart';
import 'package:escala/features/institution/visualizations/schedule_date_config_colors_example.dart';
import 'package:escala/features/schedule/schedule_controller.dart';
import 'package:escala/features/schedule/models/schedule.dart';
import 'package:escala/features/schedule/visualizations/schedule_users_component.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:escala/features/user/user_controller.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:teb_package/messaging/teb_custom_dialog.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_util.dart';
import 'package:teb_package/visual_elements/month_picker/teb_month_picker.dart';
import 'package:teb_package/visual_elements/teb_buttons_line.dart';
import 'package:teb_package/visual_elements/teb_text_form_field.dart';

class ScheduleForm extends StatefulWidget {
  const ScheduleForm({super.key});

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _maxPeopleDayOffController = TextEditingController();
  bool _freshGeneratedSchedule = false;

  bool isButtonLineVisible = true;
  String freshGeneratedScheduleId = '';
  bool _releasingSchedule = false;
  bool _scheduleGenerationFinished = true;
  var _departmentUserAmountText = '';

  Institution _institution = Institution();

  var _departmentError = false;
  var _department = Department();
  late TabController _tabController;

  List<String> _scheduleGenerationStatusList = [];

  Schedule _schedule = Schedule();

  List<ScheduleDateUser> _scheduleDateUsers = [];

  var _user = User();
  var _initializing = true;

  late ScheduleController _scheduleController;

  void _releaseSchedule({required String scheduleId, required ScheduleStatus scheduleStatus}) async {
    if (!_releasingSchedule) {
      TebCustomDialog(context: context)
          .confirmationDialog(
              message: scheduleStatus == ScheduleStatus.teamValidation
                  ? 'Confirma a liberação da escala para o time validá-la?'
                  : 'Liberar a escala? Depois de liberada ela não poderá ser alterada ou excluída.')
          .then((value) async {
        if (value == true) {
          setState(() => _releasingSchedule = true);
          try {
            await _scheduleController.releaseSchedule(
              scheduleId: scheduleId,
              scheduleStatus: scheduleStatus,
            );

            _scheduleController.getScheduleById(scheduleId).then((value) {
              setState(() => _schedule = value);
              setState(() => _releasingSchedule = false);
            });
          } catch (e) {
            setState(() => _releasingSchedule = false);
          }
        }
      });
    }
  }

  void _generateSchedule() {
    if (_schedule.isReleased) {
      TebCustomDialog(context: context).informationDialog(message: 'A escala está finalizada e não pode ser alterada');
      return;
    }

    if (_schedule.departmentId.isEmpty) {
      setState(() => _departmentError = true);
      TebCustomMessage(
        context: context,
        messageText: 'Para gerar uma escala é necessário selecionar a área/departamento',
        messageType: TebMessageType.error,
      );
      return;
    }

    if (_schedule.initialDate == null || _schedule.finalDate == null) {
      setState(() => _departmentError = true);
      TebCustomMessage(
        context: context,
        messageText: 'É necessário selecionar um mês para a geração da escala',
        messageType: TebMessageType.error,
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

      TebCustomMessage(
        context: context,
        messageType: TebMessageType.info,
        durationInSeconds: 5,
        messageText: 'Geração da escala iniciada',
      );

      _scheduleController.generateSchedule(schedule: _schedule).then((customReturn) {
        setState(() {
          _scheduleGenerationFinished = true;
          if (customReturn.returnType == TebReturnType.error) {
            TebCustomMessage.error(context, message: customReturn.message);
          } else {
            TebCustomMessage.sucess(context, message: 'Escala finalizada');
          }
        });
      });
    }
  }

  Widget _buttonsLine() {
    return TebButtonsLine(
      buttons: [
        TebButton(
          label: _schedule.id == '' ? 'Gerar escala' : 'Refazer Escala',
          onPressed: _generateSchedule,
          enabled: _schedule.status != ScheduleStatus.released && !_releasingSchedule,
        ),
        TebButton(
          label: 'Liberar/Finalizar',
          onPressed: () {
            if (_schedule.isReleased) {
              TebCustomDialog(context: context).informationDialog(message: 'A escala está finalizada e não pode ser alterada');
              return;
            }

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
                        title: 'Permitir que as pessoas alocadas nesta área/setor possam validar a escala e sugerir alterações',
                        shadowColor: Theme.of(context).primaryColor,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _releaseSchedule(
                                  scheduleId: _freshGeneratedSchedule ? freshGeneratedScheduleId : _schedule.id,
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
                                  scheduleId: _freshGeneratedSchedule ? freshGeneratedScheduleId : _schedule.id,
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
            );
          },
          enabled: _schedule.status != ScheduleStatus.released && !_releasingSchedule,
        ),
      ],
    );
  }

  void _initializingPreparation({required BuildContext context}) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;

      _user = arguments['user'] ?? User();
      _user = User.fromMap(_user.toMap());

      _schedule = arguments['schedule'] ?? Schedule();
      _schedule = Schedule.fromMap(_schedule.toMap());
      if (_schedule.id.isNotEmpty) {
        _scheduleController.getScheduleDates(scheduleId: _schedule.id).then((value) {
          setState(() => _scheduleDateUsers = value);
          setState(() => _freshGeneratedSchedule = false);
          _maxPeopleDayOffController.text = _schedule.maxPeopleDayOff.toString();
        });

        _department = arguments['department'] ?? Department();
        if (_department.id.isEmpty) {
          _departmentError = true;
          DepartmentController(_user).getDepartmentById(departmentId: _schedule.departmentId).then((value) => setState(() {
                _department = value;
                _departmentError = false;
              }));
        }
        _departmentUserAmount(departmentId: _schedule.departmentId);
      }

      InstitutionController(_user)
          .getInstitutionFromId(institutionId: _user.institutionId)
          .then((institution) => setState(() => _institution = institution));

      _scheduleController = ScheduleController(_user);

      _initializing = false;
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

    UserController().getUsersFromDepartment(departmentId: departmentId, onlyActiveUsers: true).then((value) {
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
                        if (_schedule.isReleased) {
                          TebCustomDialog(context: context)
                              .informationDialog(message: 'A escala está finalizada e não pode ser alterada');
                          return;
                        }
                        TebMonthPicker.showMonthYearPickerDialog(context: context).then((value) {
                          setState(() {
                            _schedule.initialDate = TebUtil.firstDayOfMonth(value);
                            _schedule.finalDate = TebUtil.lastDayOfMonth(value);
                          });
                        });
                      },
                      child: Text(_schedule.id.isEmpty ? 'Selecionar mês' : 'Alterar mês'),
                    ),
                    Text(_schedule.initialDate == null || _schedule.finalDate == null
                        ? 'Selecione um mês'
                        : '${TebUtil.dateTimeFormat(date: _schedule.initialDate!)} à ${TebUtil.dateTimeFormat(date: _schedule.finalDate!)}'),
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
                          ctx: context,
                          fixedWidth: kIsWeb ? MediaQuery.of(context).size.width * 0.45 : MediaQuery.of(context).size.width - 32,
                          error: _departmentError,
                          selectionItem: _schedule.departmentId.isEmpty
                              ? DepartmentCard(
                                  department: Department(),
                                  screenMode: ScreenMode.showItem,
                                  elevation: 0,
                                  user: _user,
                                ).emptyCard(context)
                              : DepartmentCard(
                                  department: _department,
                                  screenMode: ScreenMode.showItem,
                                  cropped: false,
                                  elevation: 0,
                                  user: _user,
                                ),
                          onTap: () {
                            if (_schedule.isReleased) {
                              TebCustomDialog(context: context)
                                  .informationDialog(message: 'A escala está finalizada e não pode ser alterada');
                              return;
                            }
                            showModalBottomSheet<Department>(
                              constraints: kIsWeb
                                  ? BoxConstraints.tightFor(width: MediaQuery.of(context).size.width * 0.55)
                                  : BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 32),
                              context: context,
                              isDismissible: true,
                              builder: (context) => DepartmentSelectionList(user: _user),
                            ).then((value) {
                              if (value != null) {
                                setState(() {
                                  _departmentError = false;
                                  _department = value;
                                  _schedule.departmentId = _department.id;
                                  _schedule.maxPeopleDayOff = _department.maxPeopleDayOff;
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
                        TebTextEdit(
                          enabled: !_schedule.isReleased,
                          context: context,
                          controller: _maxPeopleDayOffController,
                          onSave: (value) {
                            _schedule.maxPeopleDayOff = int.tryParse(value ?? '') ?? 0;
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
                        child: Text(_schedule.statusLabel()),
                      ),
                    ),
                  ],
                ),
                // button line
                if (_scheduleGenerationFinished || !_releasingSchedule)
                  _scheduleOptionsItemStructure(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [_buttonsLine()],
                  ),
                // generation indicator
                if (!_scheduleGenerationFinished || _releasingSchedule)
                  _scheduleOptionsItemStructure(
                    children: [
                      Text(_releasingSchedule ? 'Liberando escala' : 'Gerando a escala'),
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
                  // stream: Provider.of<ScheduleController>(context, listen: false).scheduleStreamController,
                  stream: _scheduleController.scheduleStreamController,
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
            scheduleStatus: _schedule.status,
            scheduleId: _schedule.id,
            initialDate: _schedule.initialDate ?? DateTime.now(),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _scheduleController = ScheduleController(User());
  }

  @override
  Widget build(BuildContext context) {
    _initializingPreparation(context: context);

    return TebCustomScaffold(
      responsive: true,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                  constraints: kIsWeb
                      ? BoxConstraints.tightFor(width: MediaQuery.of(context).size.width * 0.55)
                      : BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 32),
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
            Text(_schedule.id == "" ? 'Nova Escala' : 'Alterar Escala'),
            Text(
              'Situação: ${_schedule.statusLabel()}',
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
