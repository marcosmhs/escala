import 'package:cloud_firestore/cloud_firestore.dart';

enum ScheduleStatus { creating, validating, teamValidation, released }

class Schedule {
  late String id;
  late String userCreatorId;
  late String institutionId;
  late String departmentId;
  late DateTime? initialDate;
  late DateTime? finalDate;
  late ScheduleStatus status;
  late int maxPeopleDayOff;

  Schedule({
    this.id = '',
    this.userCreatorId = '',
    this.institutionId = '',
    this.departmentId = '',
    this.initialDate,
    this.finalDate,
    this.status = ScheduleStatus.creating,
    this.maxPeopleDayOff = 0,
  });

  
  bool get isCreating => status == ScheduleStatus.creating;
  bool get isValidating => status == ScheduleStatus.validating;
  bool get isTeamValidation => status == ScheduleStatus.teamValidation;
  bool get isReleased => status == ScheduleStatus.released;
  
  factory Schedule.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Schedule.fromMap(data);
  }

  static Schedule fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] ?? '',
      userCreatorId: map['userCreatorId'] ?? '',
      institutionId: map['institutionId'] ?? '',
      departmentId: map['departmentId'] ?? '',
      initialDate: map['initialDate'] == null ? DateTime.now() : DateTime.tryParse(map['initialDate']),
      finalDate: map['finalDate'] == null ? DateTime.now() : DateTime.tryParse(map['finalDate']),
      maxPeopleDayOff: map['maxPeopleDayOff'] ?? 0,
      status: scheduleStatusFromString(map['status']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userCreatorId': userCreatorId,
      'institutionId': institutionId,
      'departmentId': departmentId,
      'initialDate': initialDate.toString(),
      'finalDate': finalDate.toString(),
      'maxPeopleDayOff': maxPeopleDayOff,
      'status': status.toString(),
    };
  }

  String statusLabel() {
    switch (status) {
      case ScheduleStatus.creating:
        return 'Em criação';
      case ScheduleStatus.validating:
        return 'Em validação';
      case ScheduleStatus.teamValidation:
        return 'Liberado para time validar';
      default:
        return 'Finalizada (liberada)';
    }
  }

  static ScheduleStatus scheduleStatusFromString(String stringValue) {
    if (stringValue.isEmpty) return ScheduleStatus.creating;

    switch (stringValue) {
      case 'ScheduleStatus.creating':
        return ScheduleStatus.creating;
      case 'ScheduleStatus.validating':
        return ScheduleStatus.validating;
      case 'ScheduleStatus.teamValidation':
        return ScheduleStatus.teamValidation;
      default:
        return ScheduleStatus.released;
    }
  }
}
