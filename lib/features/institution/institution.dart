import 'package:escala/features/schedule/models/schedule_date.dart';
import 'package:flutter/material.dart';

class Institution {
  late String id;
  late String name;
  late bool active;

  late Color workDay6hColor;
  late Color workDay12hColor;
  late Color dayOffColor;
  late Color vacationColor;

  late DateTime? creationDate;
  late DateTime? updateDate;

  Institution({
    this.id = '',
    this.name = '',
    this.active = true,
    this.workDay12hColor = Colors.black,
    this.workDay6hColor = Colors.black,
    this.dayOffColor = Colors.black,
    this.vacationColor = Colors.black,
    this.creationDate,
    this.updateDate,
  });

  static Institution fromMap(Map<String, dynamic> map) {
    var i = Institution();

    i = Institution(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      active: map['active'] ?? true,
      workDay6hColor: map['workDay6hColor'] == null ? Colors.black : Color(map['workDay6hColor']),
      workDay12hColor: map['workDay12hColor'] == null ? Colors.black : Color(map['workDay12hColor'] ?? ''),
      dayOffColor: map['dayOffColor'] == null ? Colors.black : Color(map['dayOffColor'] ?? ''),
      vacationColor: map['vacationColor'] == null ? Colors.black : Color(map['vacationColor'] ?? ''),
      creationDate: map['creationDate'] == null ? DateTime.now() : DateTime.tryParse(map['creationDate']),
      updateDate: map['updateDate'] == null ? DateTime.now() : DateTime.tryParse(map['updateDate']),
    );
    return i;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> r = {};
    r = {
      'id': id,
      'name': name,
      'active': active,
      'workDay6hColor': workDay6hColor.value,
      'workDay12hColor': workDay12hColor.value,
      'dayOffColor': dayOffColor.value,
      'vacationColor': vacationColor.value,
      'creationDate': creationDate.toString(),
      'updateDate': updateDate.toString(),
    };

    return r;
  }

  Color scheduleDateTypeColor(ScheduleDateType type) {
    switch (type) {
      case ScheduleDateType.dayOff:
        return dayOffColor;
      case ScheduleDateType.vacation:
        return vacationColor;
      case ScheduleDateType.workDay6h:
        return workDay6hColor;
      case ScheduleDateType.workDay12h:
        return workDay12hColor;
      default:
        return dayOffColor;
    }
  }
}
