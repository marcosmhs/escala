import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  // Google User Data
  late String id;
  late String registration;
  late String password;
  late bool active;
  late bool manager;
  late bool institutionResponsible;
  late String institutionId;
  late String departmentId;
  late bool needChangePassword;
  // Schedule data
  late String name;
  late String gender;
  late int weekHours;
  late int dailyHours;
  late DateTime? lastScheduleDate;
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
