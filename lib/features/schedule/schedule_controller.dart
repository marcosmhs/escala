import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escala/components/util/custom_return.dart';
import 'package:escala/components/util/uid_generator.dart';
import 'package:escala/components/util/util.dart';
import 'package:escala/features/schedule/models/schedule.dart';
import 'package:escala/features/schedule/models/schedule_date.dart';
import 'package:escala/features/user/user_controller.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ScheduleStreamReturnStatus { info, weekendDayOff, weeydayDayOff, fullDayWork, finished, error }

class ScheduleDateUser {
  late User user = User();
  late List<ScheduleDate> scheduleDates = [];

  ScheduleDateUser(User user, List<ScheduleDate> scheduleDates) {
    this.user = User.fromMap(user.toMap());
    this.scheduleDates.addAll([...scheduleDates]);
  }

  void addScheduleDate(ScheduleDate scheduleDate) {
    scheduleDates.add(scheduleDate);
  }

  static ScheduleDateUser single(User user, ScheduleDate scheduleDate) {
    List<ScheduleDate> scheduleDates = [];
    scheduleDates.add(scheduleDate);
    return ScheduleDateUser(user, scheduleDates);
  }
}

class ScheduleStreamReturn {
  late List<String> statusList = [];
  late List<ScheduleDateUser> scheduleDateUsers;
  late ScheduleStreamReturnStatus status;

  ScheduleStreamReturn(this.statusList, this.scheduleDateUsers, this.status);
}

class ScheduleController with ChangeNotifier {
  final String _scheduleCollection = 'schedule';
  final String _scheduleDateCollection = 'scheduleDate';
  final String _scheduleDateUserCollection = 'scheduleDateUser';
  final String _userInformationCollection = 'user';

  final StreamController<ScheduleStreamReturn> _scheduleStreamController = StreamController<ScheduleStreamReturn>.broadcast();

  Stream<ScheduleStreamReturn> get scheduleStreamController => _scheduleStreamController.stream;

  final StreamController<List<ScheduleDateUser>> _scheduleDatesStreamController =
      StreamController<List<ScheduleDateUser>>.broadcast();

  Stream<List<ScheduleDateUser>> get scheduleDatesStreamController => _scheduleDatesStreamController.stream;

  final List<String> scheduleStreamStringList = [];

  final User currentUser;

  ScheduleController(this.currentUser);

  // ------------------------------------------------------------------------------
  // CRUD Schedule
  // ------------------------------------------------------------------------------

  Future<CustomReturn> _addSchedule({required Schedule schedule}) async {
    try {
      await FirebaseFirestore.instance.collection(_scheduleCollection).doc(schedule.id).set(schedule.toMap());

      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> _updateSchedule({required Schedule schedule}) async {
    try {
      await FirebaseFirestore.instance.collection(_scheduleCollection).doc(schedule.id).update(schedule.toMap());
      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> deleteSchedule({required Schedule schedule}) async {
    try {
      // se a escala está em validação do time
      if (schedule.status == ScheduleStatus.teamValidation) {
        // remove a escala das pessoas
        var r = await deleteScheduleDateUser(schedule: schedule);
        if (r.returnType == ReturnType.error) {
          return CustomReturn.error(e.toString());
        }
      }

      FirebaseFirestore.instance
          .collection(_scheduleCollection)
          .doc(schedule.id)
          .collection(_scheduleDateCollection)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      await FirebaseFirestore.instance.collection(_scheduleCollection).doc(schedule.id).delete();

      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> deleteScheduleDateUser({required Schedule schedule}) async {
    try {
      // se a escala está em validação do time
      // localiza todos os usuários da área/setor (independente se estão ativos ou não)
      final usersQuery = await FirebaseFirestore.instance
          .collection(_userInformationCollection)
          .where("departmentId", isEqualTo: schedule.departmentId)
          .get();
      final usersFromDepartment = usersQuery.docs.map((doc) => doc.data()).toList();

      // Para cada usuário
      for (var user in usersFromDepartment) {
        // localiza as datas daquela escala
        final userScheduleDatesQuery = await FirebaseFirestore.instance
            .collection(_userInformationCollection)
            .doc(user["id"])
            .collection(_scheduleDateUserCollection)
            .where("scheduleId", isEqualTo: schedule.id)
            .get();
        // exclui todas as datas
        for (var userScheduleDate in userScheduleDatesQuery.docs) {
          userScheduleDate.reference.delete();
        }
      }

      FirebaseFirestore.instance
          .collection(_scheduleCollection)
          .doc(schedule.id)
          .collection(_scheduleDateCollection)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      await FirebaseFirestore.instance.collection(_scheduleCollection).doc(schedule.id).delete();

      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Stream<QuerySnapshot<Object?>> getSchedules() {
    return FirebaseFirestore.instance
        .collection(_scheduleCollection)
        .where('institutionId', isEqualTo: currentUser.institutionId)
        .snapshots();
  }

  Future<Schedule> getScheduleById(String scheduleId) async {
    try {
      final query = FirebaseFirestore.instance.collection(_scheduleCollection).where("id", isEqualTo: scheduleId);

      final schedules = await query.get();
      final dataList = schedules.docs.map((doc) => doc.data()).toList();

      final List<Schedule> r = [];
      for (var schedule in dataList) {
        r.add(Schedule.fromMap(schedule));
      }
      return r.first;
    } catch (e) {
      return Schedule();
    }
  }

  // ------------------------------------------------------------------------------
  // CRUD ScheduleDate
  // ------------------------------------------------------------------------------

  Future<CustomReturn> addScheduleDate({required ScheduleDate scheduleDate, bool needNotifyListeners = true}) async {
    try {
      var scheduleDateId = UidGenerator.firestoreUid;
      scheduleDate.id = scheduleDateId;
      await FirebaseFirestore.instance
          .collection(_scheduleCollection)
          .doc(scheduleDate.scheduleId)
          .collection(_scheduleDateCollection)
          .doc(scheduleDate.id)
          .set(scheduleDate.toMap());

      if (needNotifyListeners) notifyListeners();

      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> deleteScheduleDate({required ScheduleDate scheduleDate}) async {
    try {
      await FirebaseFirestore.instance
          .collection(_scheduleCollection)
          .doc(scheduleDate.scheduleId)
          .collection(_scheduleDateCollection)
          .doc(scheduleDate.id)
          .delete();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<List<ScheduleDateUser>> getScheduleDates({required String scheduleId}) async {
    try {
      // lista com o retorno final
      final List<ScheduleDateUser> scheduleDateUsers = [];

      // usuários
      var users = UserController();

      // escalas
      final scheduleDates = await FirebaseFirestore.instance
          .collection(_scheduleCollection)
          .doc(scheduleId)
          .collection(_scheduleDateCollection)
          .get();

      var schedule = await getScheduleById(scheduleId);
      var usersList = await users.getUsersFromDepartment(departmentId: schedule.departmentId, onlyActiveUsers: false);

      final dataList = scheduleDates.docs.map((doc) => doc.data()).toList();

      var scheduleDate = ScheduleDate();

      for (var data in dataList) {
        // transforma retorno em escala
        scheduleDate = ScheduleDate.fromMap(data);

        // verifica se usuário da escala já foi adicionado à lista de retorno
        var scheduleDateUser = scheduleDateUsers.where((element) => element.user.id == scheduleDate.userId).singleOrNull;

        // se não existe
        if (scheduleDateUser != null) {
          scheduleDateUser.addScheduleDate(scheduleDate);
        } else {
          // obtem os dados do usuário
          for (var u in usersList) {
            if (u.id == scheduleDate.userId) {
              scheduleDateUsers.add(ScheduleDateUser(User.fromMap(u.toMap()), [scheduleDate]));
              break;
            }
          }
        }
      }

      return scheduleDateUsers;
    } catch (e) {
      return [];
    }
  }

  Stream<QuerySnapshot<Object?>> getUserSchadule({required String userId}) {
    return FirebaseFirestore.instance
        .collection(_userInformationCollection)
        .doc(userId)
        .collection(_scheduleDateUserCollection)
        .snapshots();
  }

  Future<List<ScheduleDateUser>> getUsersOnScheduleDate({
    required String departmentId,
    required String scheduleId,
    required DateTime date,
  }) async {
    try {
      var userController = UserController();

      var users = await userController.getUsersFromDepartment(departmentId: departmentId, onlyActiveUsers: true);

      final List<ScheduleDateUser> userList = [];
      for (var user in users) {
        final query = await FirebaseFirestore.instance
            .collection(_userInformationCollection)
            .doc(user.id)
            .collection(_scheduleDateUserCollection)
            .where("scheduleId", isEqualTo: scheduleId)
            .where("date", isEqualTo: date.toString())
            .get();

        final scheduleDates = query.docs.map((doc) => doc.data()).toList();

        for (var scheduleDate in scheduleDates) {
          if (userList.where((u) => u.user.id == scheduleDate['userId']).isEmpty) {
            userList.add(ScheduleDateUser(user, [ScheduleDate.fromMap(scheduleDate)]));
          }
        }
      }

      return userList;
    } catch (e) {
      return [];
    }
  }

  // ------------------------------------------------------------------------------
  // Schedule Creation
  // ------------------------------------------------------------------------------

  void _addStreamResult({
    String message = '',
    List<ScheduleDateUser>? scheduleDateUsers,
    ScheduleStreamReturnStatus status = ScheduleStreamReturnStatus.info,
  }) {
    scheduleStreamStringList.add(message);
    _scheduleStreamController.sink.add(ScheduleStreamReturn(scheduleStreamStringList, scheduleDateUsers ?? [], status));
  }

  String _formatDayOffStatus(int dayOffSequence, DateTime dayOff) {
    String dayOfWeek = '';

    switch (dayOff.weekday) {
      case 1:
        dayOfWeek = 'segunda-feira';
      case 2:
        dayOfWeek = 'terça-feira';
      case 3:
        dayOfWeek = 'quarta-feira';
      case 4:
        dayOfWeek = 'quinta-feira';
      case 5:
        dayOfWeek = 'sexta-feira';
      case 6:
        dayOfWeek = 'sábado';
      case 7:
        dayOfWeek = 'domingo';
      default:
        dayOfWeek = '';
    }

    return '${dayOffSequence + 1}a folga -  ${DateFormat('dd/MM/yyyy').format(dayOff)} - $dayOfWeek';
    //'${i + 1}a folga ${dayOffList[i].toString()} - ${dayOffList[i].weekday}'
  }

  List<DateTime> _getWeekendDayOffs(
      {required List<DateTime> sundayList,
      required String gender,
      DateTime? lastScheduleDate,
      required List<DateTime> usedDates,
      required int usersDateLimit}) {
    List<DateTime> weekendDayOffList = [];

    DateTime firstSunday;
    DateTime secondSunday;
    DateTime selectedSunday;
    var i = 0;

    // lista dos domingos do mês
    // se não existe um último dia de folga (se é a primeira escala assume o primeiro domingo como possível)
    int minSunday = lastScheduleDate == null
        ? 1
        // se a ultima folga foi antes de 6 dias do primeiro domingo ele deve ser desconsiderado
        : sundayList[0].difference(lastScheduleDate).inDays < 6
            ? 2
            : 1;

    // o Range para definir o primeiro domingo depende da quantidad e de domingos do mês:
    // em meses com 4 domingos devem se considerados o 1 e o 2 mês como os primeiros, dado que pessoas com mais domingos
    // devem intercalar um final de semana com folga e outro trabalhando, neste caso 1 e 3 ou 2 e 4.
    // para meses com 5 domingos é possível pegar os três primeiros domingos já que podemos fazer 1 e 3, 2 e 4 e 3 e 5
    int maxSunday = gender == 'F'
        ? sundayList.length == 4
            ? 2
            : 3
        : sundayList.length;

    if (minSunday == maxSunday) {
      firstSunday = sundayList[(minSunday) - 1];
    } else {
      firstSunday = sundayList[(Random().nextInt(maxSunday - minSunday + 1) + minSunday) - 1];
    }

    while (!validDayOff(usedDates: usedDates, dayOff: firstSunday, usersDateLimit: usersDateLimit)) {
      if (minSunday == maxSunday) {
        firstSunday = sundayList[(minSunday) - 1];
      } else {
        firstSunday = sundayList[(Random().nextInt(maxSunday - minSunday + 1) + minSunday) - 1];
      }
      i++;
      i++;
      if (i > 1000) {
        _addStreamResult(message: "Falha na definição de final de semana único, assumindo data disponível");
        break;
      }
    }

    //firstSunday = sundayList[Random().nextInt((maxSunday + 1) - 1)];

    weekendDayOffList.add(firstSunday);

    // Quantidade de domingos depende do gênero
    // - Feminino: 2
    // - Masculino: 1
    if (gender == 'M') {
      // para homens o sábado deve ser junto com o domingo selecionado
      weekendDayOffList.add(firstSunday.subtract(const Duration(days: 1)));
    }
    // Segundo domingo somente para quem tem esse direito (mulhers)
    else {
      // o segundo domingo deve ser após 2 semanas do primeiro
      secondSunday = firstSunday.add(const Duration(days: 14));
      weekendDayOffList.add(secondSunday);

      // Para o caso das mulheres é necessário sortear qual será o final de semana
      // com um sábado e domingo ela terá direito
      selectedSunday = Random().nextInt(3 - 1) == 0 ? firstSunday : secondSunday;
      weekendDayOffList.add(selectedSunday.subtract(const Duration(days: 1)));
    }
    weekendDayOffList.sort();

    return weekendDayOffList;
  }

  List<DateTime> _getRegularDayOffs({
    required DateTime initialDate, // data inicial do período
    required DateTime finalDate, // data final do período
    required List<DateTime> weekendDayOffs, // lista de folga nos finais de semana
    required int dayOffTotalCount, // total de folgas que a pessoa pode ter no período
    required String gender, // gênero
    required DateTime? lastScheduleDate, // última folga que a pessoa teve
    required List<DateTime> usedDates,
    required int usersDateLimit,
  }) {
    List<DateTime> regularDayOffList = [];
    // se a pessoa não possui uma úlima folga (se é a primeira escala)
    // assume o primeiro dia como a base para as demais folgas
    DateTime currentLastDayOff = lastScheduleDate ?? initialDate;

    // a quantidade disponível de folgas é o:
    // total de domingos do mês - as folgas dadas nos finais de semana
    int regularDayOffCount = dayOffTotalCount - weekendDayOffs.length;

    DateTime date = initialDate;
    var i = 0;

    // enquanto a data atual for menor que o final do mês (adiciona mais um dia na data final para garantir que irá pegar o mês inteiro)
    // e a quantidade de folgas for menor que o total disponível
    while (date.isBefore(finalDate.add(const Duration(days: 1))) && regularDayOffList.length < regularDayOffCount) {
      //  if (validDayOff(usedDates: usedDates, dayOff: date, usersDateLimit: usersDateLimit)) {
      // primeiro verifica se aquela data é um final de semana de folga
      if (weekendDayOffs.contains(date)) {
        // se esta data está ali, deve ser salva como última folga disponível
        currentLastDayOff = date;
      }

      // quando a diferença entre a última folga e a data atual for maior que 6 dias
      // deve calcular a próxima folga
      if (date.difference(currentLastDayOff).inDays > 6) {
        // a data não pode ser um final de semana
        if (date.weekday <= 5) {
          // se ela não for uma folga de final de semana ela é considerada folga regular

          // antes de definir a data como um folga, verifica se ela pode ser utilizada.
          while (!validDayOff(usedDates: usedDates, dayOff: date, usersDateLimit: usersDateLimit)) {
            date = date.add(const Duration(days: 1));
            i++;
            if (i > 1000) {
              _addStreamResult(message: "Falha na definição de final de semana único, assumindo data disponível");
              break;
            }
          }

          // salva como última folta
          currentLastDayOff = date;
          // adiciona na lista
          regularDayOffList.add(date);
          // interrompe a verificação de final de semana
        }
        //  }
      }
      date = date.add(const Duration(days: 1));
    }

    return regularDayOffList;
  }

  Future<CustomReturn> saveScheduleDateList({
    required Schedule schedule,
    required List<ScheduleDate> scheduleDateList,
  }) async {
    _addStreamResult(message: 'Salvando todas as datas');
    CustomReturn r = CustomReturn.sucess;
    for (var scheduleDate in scheduleDateList) {
      r = await addScheduleDate(scheduleDate: scheduleDate, needNotifyListeners: false);
      if (r.returnType == ReturnType.error) {
        break;
      }
    }
    notifyListeners();
    return r;
  }

  bool validDayOff({
    required List<DateTime> usedDates,
    required DateTime dayOff,
    required int usersDateLimit,
  }) {
    // se a data de folga ainda não existe na lista, apenas retorna como válida e adiciona.
    if (usedDates.where((date) => date == dayOff).isEmpty) {
      //usedDates.add(dayOff);
      return true;
    }

    // Se a quantidade de folgas está abaixo do limite, adiciona na lista e retorna a data como válida
    if (usedDates.where((date) => date == dayOff).length < usersDateLimit) {
      //usedDates.add(dayOff);
      return true;
    }

    return false;
  }

  Future<CustomReturn> generateSchedule({required Schedule schedule}) async {
    var userController = UserController();
    scheduleStreamStringList.clear();

    List<User> usersList = [];
    List<DateTime> userDayOffList = [];
    List<ScheduleDate> scheduleDateList = [];
    List<DateTime> usedDates = [];

    List<DateTime> sundayList = Util.getSundayList(schedule.initialDate!, schedule.finalDate!);
    List<ScheduleDateUser> scheduleDateUsers = [];

    CustomReturn r;

    // ---------------------------------------------
    // salva a escala que está sendo criada
    // ---------------------------------------------

    if (schedule.id.isNotEmpty) {
      _addStreamResult(message: "Excluindo dados da escala anterior");
      await Future.delayed(const Duration(milliseconds: 500));
      r = await deleteSchedule(schedule: schedule);

      if (r.returnType == ReturnType.error) {
        _addStreamResult(message: 'Ocorreu um erro: ${r.message}', status: ScheduleStreamReturnStatus.error);
        return CustomReturn.error('Ocorreu um erro: ${r.message}');
      }
    }

    _addStreamResult(message: 'Salvando dados da escala');
    schedule.id = UidGenerator.firestoreUid;
    schedule.institutionId = currentUser.institutionId;
    schedule.status = ScheduleStatus.creating;
    schedule.userCreatorId = currentUser.id;

    r = await _addSchedule(schedule: schedule);

    if (r.returnType == ReturnType.error) {
      _addStreamResult(message: 'Ocorreu um erro: ${r.message}', status: ScheduleStreamReturnStatus.error);
      return CustomReturn.error('Ocorreu um erro: ${r.message}');
    }

    try {
      // ---------------------------------------------
      // Obtem a lista de pessoas
      // ---------------------------------------------
      _addStreamResult(message: "Selecionando pessoas");
      _addStreamResult();

      // randomiza a lista de pessoas
      usersList = await userController.getUsersFromDepartment(departmentId: schedule.departmentId, onlyActiveUsers: true);
      usersList.shuffle();
      await Future.delayed(const Duration(milliseconds: 500));

      // ---------------------------------------------
      // percorre lista de pessoas
      // ---------------------------------------------
      for (var user in usersList) {
        // limpa a lista de feriados para recomeçar com nova pessoa
        userDayOffList = [];
        if (user.lastScheduleDate != null) {
          _addStreamResult(
            message: 'Escala de ${user.name}, última folga: ${Util.dateTimeFormat(date: user.lastScheduleDate!)}',
          );
        } else {
          _addStreamResult(message: 'Escala de ${user.name}');
        }

        // ---------------------------------------------
        // adiciona as folgas de sábado e domingo
        // ---------------------------------------------

        // retorna, dentro da lista de domingos disponível, os finais de semana de folga
        // considerando a regra para sábado e domingos
        userDayOffList.addAll(_getWeekendDayOffs(
          sundayList: sundayList,
          gender: user.gender,
          lastScheduleDate: user.lastScheduleDate,
          usedDates: usedDates,
          usersDateLimit: schedule.maxPeopleDayOff,
        ));

        // ---------------------------------------------
        // adiciona as demais folgas duranta a semana
        // ---------------------------------------------
        userDayOffList.addAll(_getRegularDayOffs(
          initialDate: schedule.initialDate!,
          finalDate: schedule.finalDate!,
          weekendDayOffs: userDayOffList,
          dayOffTotalCount: sundayList.length,
          gender: user.gender,
          lastScheduleDate: user.lastScheduleDate,
          usedDates: usedDates,
          usersDateLimit: schedule.maxPeopleDayOff,
        ));

        usedDates.addAll(userDayOffList);

        userDayOffList.sort();

        //  Mostra as folgas
        for (int i = 0; i < userDayOffList.length; i++) {
          _addStreamResult(message: _formatDayOffStatus(i, userDayOffList[i]));
        }

        // ---------------------------------------------
        // salva as folgas no Firestore
        // ---------------------------------------------

        scheduleDateList = [];

        // gera a escala do mês
        for (var dayOff in userDayOffList) {
          scheduleDateList.add(ScheduleDate(
            date: dayOff,
            userId: user.id,
            type: ScheduleDateType.dayOff,
            userIdCreation: currentUser.id,
            scheduleId: schedule.id,
          ));
        }

        r = await saveScheduleDateList(
          schedule: schedule,
          scheduleDateList: scheduleDateList,
        );

        if (r.returnType == ReturnType.error) {
          _addStreamResult(message: 'Ocorreu um erro: ${r.message}');

          break;
        }

        scheduleDateUsers.add(ScheduleDateUser(User.fromMap(user.toMap()), [...scheduleDateList]));
        _addStreamResult();
      }
      schedule.status = ScheduleStatus.validating;
      r = await _updateSchedule(schedule: schedule);

      if (r.returnType == ReturnType.error) {
        _addStreamResult(message: 'Ocorreu um erro: ${r.message}');
        return CustomReturn.error('Ocorreu um erro: ${r.message}');
      }
      _addStreamResult(message: 'Finalizado', scheduleDateUsers: scheduleDateUsers, status: ScheduleStreamReturnStatus.finished);
      return CustomReturn.sucess;
    } finally {
      userController.dispose();
    }
  }

  Future<CustomReturn> releaseSchedule({required String scheduleId, required ScheduleStatus scheduleStatus}) async {
    try {
      var schedule = await getScheduleById(scheduleId);
      var scheduleDateUsers = await getScheduleDates(scheduleId: schedule.id);
      var userController = UserController();

      // Se está fazendo a liberação da escala e seu status anterior é validação do time faz
      // a exclusão da escala nos usuários
      if (scheduleStatus == ScheduleStatus.released && schedule.status == ScheduleStatus.teamValidation) {
        var r = await deleteScheduleDateUser(schedule: schedule);
        if (r.returnType == ReturnType.error) {
          return CustomReturn.error(e.toString());
        }
      }

      for (var scheduleDateUser in scheduleDateUsers) {
        // ordena as datas em ordem crescente para que a última data seja a maior
        scheduleDateUser.scheduleDates.sort((a, b) => a.date!.compareTo(b.date!));
        var lastScheduleDate = scheduleDateUser.scheduleDates.last.date;

        var date = schedule.initialDate;
        var baseScheduleDate = ScheduleDate.fromMap(scheduleDateUser.scheduleDates.first.toMap());

        while (date!.isBefore(schedule.finalDate!.add(const Duration(days: 1)))) {
          if (scheduleDateUser.scheduleDates.where((e) => e.date == date).isEmpty) {
            baseScheduleDate.id = UidGenerator.firestoreUid;
            baseScheduleDate.date = date;
            baseScheduleDate.type = ScheduleDateType.workDay6h;
            scheduleDateUser.scheduleDates.add(ScheduleDate.fromMap(baseScheduleDate.toMap()));
          }
          date = date.add(const Duration(days: 1));
        }

        for (var scheduleDate in scheduleDateUser.scheduleDates) {
          scheduleDate.status = scheduleStatus;

          await FirebaseFirestore.instance
              .collection(_userInformationCollection)
              .doc(scheduleDateUser.user.id)
              .collection(_scheduleDateUserCollection)
              .doc(scheduleDate.id)
              .set(scheduleDate.toMap());
        }

        // ordena as datas em ordem crescente para que a última data seja a maior
        // atualiza a última escala daquela pessoa.
        scheduleDateUser.user.lastScheduleDate = lastScheduleDate;
        userController.update(user: scheduleDateUser.user);
      }

      schedule.status = scheduleStatus;
      await _updateSchedule(schedule: schedule);
      notifyListeners();

      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scheduleStreamController.close();
    _scheduleDatesStreamController.close();
  }
}
