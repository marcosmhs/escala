import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escala/features/department/department.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class DepartmentController with ChangeNotifier {
  final String _departmentCollection = 'department';
  final String _institutionCollection = 'institution';

  late User _user;

  DepartmentController(User user) {
    _user = user;
  }

  // ------------------------------------------------------------------------------
  // CRUD Schedule
  // ------------------------------------------------------------------------------

  Future<TebCustomReturn> save({required Department department}) async {
    return department.id.isEmpty ? _add(department: department) : _update(department: department);
  }

  Future<TebCustomReturn> _add({required Department department}) async {
    try {
      department.id = TebUidGenerator.firestoreUid;
      department.institutionId = department.institutionId.isNotEmpty ? department.institutionId : _user.institutionId;
      department.creationDate = DateTime.now();
      await FirebaseFirestore.instance
          .collection(_institutionCollection)
          .doc(department.institutionId)
          .collection(_departmentCollection)
          .doc(department.id)
          .set(department.toMap());

      notifyListeners();
      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Future<TebCustomReturn> _update({required Department department}) async {
    try {
      department.updateDate = DateTime.now();
      await FirebaseFirestore.instance
          .collection(_institutionCollection)
          .doc(_user.institutionId)
          .collection(_departmentCollection)
          .doc(department.id)
          .update(department.toMap());

      notifyListeners();
      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Future<TebCustomReturn> delete({required Department department}) async {
    try {
      await FirebaseFirestore.instance
          .collection(_institutionCollection)
          .doc(_user.institutionId)
          .collection(_departmentCollection)
          .doc(department.id)
          .delete();

      notifyListeners();
      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Stream<QuerySnapshot<Object?>> getDepartments() {
    return FirebaseFirestore.instance
        .collection(_institutionCollection)
        .doc(_user.institutionId)
        .collection(_departmentCollection)
        .snapshots();
  }

  Future<List<Department>> getDepartmentList() async {
    try {
      var query = FirebaseFirestore.instance
          .collection(_institutionCollection)
          .doc(_user.institutionId)
          .collection(_departmentCollection);

      final departments = await query.get();
      final dataList = departments.docs.map((doc) => doc.data()).toList();

      final List<Department> r = [];
      for (var department in dataList) {
        r.add(Department.fromMap(department));
      }
      return r;
    } catch (e) {
      return [];
    }
  }

  Future<Department> getDepartmentById({required String departmentId, String institutionId = ''}) async {
    try {
      var query = FirebaseFirestore.instance
          .collection(_institutionCollection)
          .doc(institutionId.isNotEmpty ? institutionId : _user.institutionId)
          .collection(_departmentCollection)
          .where('id', isEqualTo: departmentId);

      final departments = await query.get();
      final dataList = departments.docs.map((doc) => doc.data()).toList();

      final List<Department> r = [];
      for (var department in dataList) {
        r.add(Department.fromMap(department));
      }

      return r.first;
    } catch (e) {
      return Department();
    }
  }

  Future<Department> getDepartmentByIdFirstAccess({required String firstAccessInstitutionId}) async {
    try {
      var query = FirebaseFirestore.instance
          .collection(_institutionCollection)
          .doc(firstAccessInstitutionId)
          .collection(_departmentCollection);

      final departments = await query.get();
      final dataList = departments.docs.map((doc) => doc.data()).toList();

      final List<Department> r = [];
      for (var department in dataList) {
        r.add(Department.fromMap(department));
      }

      return r.first;
    } catch (e) {
      return Department();
    }
  }
}
