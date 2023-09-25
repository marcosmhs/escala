import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Department {
  late String id;
  late String name;
  late int maxPeopleDayOff;
  late String institutionId;
  late bool active;
  late DateTime? creationDate;
  late DateTime? updateDate;

  Department({
    this.id = '',
    this.name = '',
    this.institutionId = '',
    this.active = true,
    this.creationDate,
    this.updateDate,
    this.maxPeopleDayOff = 0,
  });

  static get icon {
    return Icons.door_sliding_outlined;
  }

  factory Department.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Department.fromMap(data);
  }

  static Department fromMap(Map<String, dynamic> map) {
    var i = Department();

    i = Department(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      institutionId: map['institutionId'] ?? '',
      maxPeopleDayOff: map['maxPeopleDayOff'] ?? 0,
      active: map['active'] ?? false,
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
      'maxPeopleDayOff': maxPeopleDayOff,
      'institutionId': institutionId,
      'active': active,
      'creationDate': creationDate.toString(),
      'updateDate': updateDate.toString(),
    };

    return r;
  }
}
