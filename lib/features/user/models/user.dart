import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  // Google User Data
  @HiveField(0)
  late String id;
  @HiveField(1)
  late String registration;
  @HiveField(2)
  late String password;
  @HiveField(3)
  late bool active;
  @HiveField(4)
  late bool manager;
  @HiveField(5)
  late bool institutionResponsible;
  @HiveField(6)
  late String institutionId;
  @HiveField(7)
  late String departmentId;
  @HiveField(8)
  late bool needChangePassword;

  // Schedule data
  @HiveField(9)
  late String name;
  @HiveField(10)
  late String gender;
  @HiveField(11)
  late int weekHours;
  @HiveField(12)
  late int dailyHours;
  @HiveField(13)
  late DateTime? lastScheduleDate;
  @HiveField(14)
  late DateTime? exclusionDate;

  User(
      {this.id = '',
      this.registration = '',
      this.password = '',
      this.name = '',
      this.gender = '',
      this.weekHours = 0,
      this.dailyHours = 0,
      this.active = false,
      this.manager = false,
      this.institutionResponsible = false,
      this.institutionId = '',
      this.departmentId = '',
      this.needChangePassword = true,
      this.lastScheduleDate,
      this.exclusionDate});

  factory User.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return User.fromMap(data);
  }

  static User fromMap(Map<String, dynamic> map) {
    var u = User();

    u = User(
      id: map['id'] ?? '',
      registration: map['registration'] ?? '',
      password: map['password'] ?? '',
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
      weekHours: map['weekHours'] ?? 0,
      dailyHours: map['dailyHours'] ?? 0,
      active: map['active'] ?? false,
      manager: map['manager'] ?? false,
      institutionResponsible: map['institutionResponsible'] ?? false,
      institutionId: map['institutionId'] ?? '',
      departmentId: map['departmentId'] ?? '',
      needChangePassword: map['needChangePassword'] ?? true,
      lastScheduleDate: map['lastScheduleDate'] == null ? null : DateTime.tryParse(map['lastScheduleDate']),
      exclusionDate: map['exclusionDate'] == null ? null : DateTime.tryParse(map['exclusionDate']),
    );
    return u;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> r = {};
    r = {
      'id': id,
      'registration': registration,
      'password': password,
      'name': name,
      'gender': gender,
      'weekHours': weekHours,
      'dailyHours': dailyHours,
      'active': active,
      'manager': manager,
      'institutionResponsible': institutionResponsible,
      'institutionId': institutionId,
      'departmentId': departmentId,
      'needChangePassword': needChangePassword,
      'lastScheduleDate': lastScheduleDate.toString(),
      'exclusionDate': exclusionDate.toString(),
    };

    return r;
  }
}
