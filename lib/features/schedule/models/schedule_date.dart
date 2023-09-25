import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escala/features/schedule/models/schedule.dart';
import 'package:flutter/material.dart';

enum ScheduleDateType { workDay6h, workDay12h, dayOff, vacation }

class ScheduDateTypeList {
  late ScheduleDateType type;
  late String name;
  ScheduDateTypeList({this.type = ScheduleDateType.workDay6h, this.name = ''});
}

class ScheduleDate {
  late String id;
  late String scheduleId;
  late String userId;
  late DateTime? date;
  late ScheduleDateType type;
  late ScheduleStatus status;
  late String userIdCreation;

  ScheduleDate({
    this.id = '',
    this.scheduleId = '',
    this.userId = '',
    this.date,
    this.type = ScheduleDateType.workDay6h,
    this.status = ScheduleStatus.creating,
    this.userIdCreation = '',
  });

  static get icon {
    return Icons.calendar_month;
  }

  factory ScheduleDate.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return ScheduleDate.fromMap(data);
  }

  static ScheduleDate fromMap(Map<String, dynamic> map) {
    return ScheduleDate(
      id: map['id'] ?? '',
      scheduleId: map['scheduleId'] ?? '',
      userId: map['userId'] ?? '',
      date: map['date'] == null ? DateTime.now() : DateTime.tryParse(map['date']),
      type: scheduleStatusFromString(map['type'] ?? ''),
      status: Schedule.scheduleStatusFromString(map['status']),
      userIdCreation: map['userIdCreation'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'userId': userId,
      'date': date.toString(),
      'type': type.toString(),
      'status': status.toString(),
      'userIdCreation': userIdCreation,
    };
  }

  String get typeLabel {
    switch (type) {
      case ScheduleDateType.workDay6h:
        return '6h';
      case ScheduleDateType.workDay12h:
        return '12h';
      case ScheduleDateType.dayOff:
        return 'Folga';
      default:
        return 'Férias';
    }
  }

  static List<ScheduDateTypeList> get scheduDateTypeList {
    List<ScheduDateTypeList> r = [];
    r.add(ScheduDateTypeList(type: ScheduleDateType.dayOff, name: 'Folga'));
    r.add(ScheduDateTypeList(type: ScheduleDateType.vacation, name: 'Férias'));
    r.add(ScheduDateTypeList(type: ScheduleDateType.workDay6h, name: 'Jornada 6h'));
    r.add(ScheduDateTypeList(type: ScheduleDateType.workDay12h, name: 'Jornada 12h'));
    return r;
  }

  static ScheduleDateType scheduleStatusFromString(String stringValue) {
    if (stringValue.isEmpty) return ScheduleDateType.workDay6h;

    switch (stringValue) {
      case 'ScheduleDateType.workDay6h':
        return ScheduleDateType.workDay6h;
      case 'ScheduleDateType.workDay12h':
        return ScheduleDateType.workDay12h;
      case 'ScheduleDateType.dayOff':
        return ScheduleDateType.dayOff;
      default:
        return ScheduleDateType.vacation;
    }
  }
}
