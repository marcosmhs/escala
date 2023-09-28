import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escala/components/util/custom_return.dart';
import 'package:escala/components/util/uid_generator.dart';
import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/department_controller.dart';
import 'package:escala/features/institution/institution.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:escala/features/user/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InstitutionController with ChangeNotifier {
  final String _institutionCollection = 'institution';
  late Institution _currentInstitution;
  final User currentUser;

  InstitutionController(this.currentUser) {
    _currentInstitution = Institution();
  }

  Institution get currentInstitution {
    return Institution.fromMap(_currentInstitution.toMap());
  }

  Future<CustomReturn> fillCurrentInstitution({required String institutionId}) async {
    final institutionDataRef = await FirebaseFirestore.instance.collection(_institutionCollection).doc(institutionId).get();
    final data = institutionDataRef.data();

    if (data == null) {
      return CustomReturn.error('Instituição não encontrada');
    }

    _currentInstitution = Institution.fromMap(data);

    return CustomReturn.sucess;
  }

  Future<CustomReturn> create({required Institution institution}) async {
    try {
      institution.id = UidGenerator.firestoreUid;
      institution.creationDate = DateTime.now();
      await FirebaseFirestore.instance.collection(_institutionCollection).doc(institution.id).set(institution.toMap());
      _currentInstitution = institution;

      // assim que a instituição é criada, também deve ser criado um departamento inicial
      var departmentController = DepartmentController(currentUser);
      departmentController.save(
        department: Department(
          institutionId: institution.id,
          name: '${institution.name} - Geral',
        ),
      );

      return CustomReturn.sucess;
    } on fb_auth.FirebaseException catch (e) {
      return CustomReturn.error(e.code);
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> update({required Institution institution}) async {
    try {
      institution.updateDate = DateTime.now();
      await FirebaseFirestore.instance.collection(_institutionCollection).doc(institution.id).set(institution.toMap());
      _currentInstitution = institution;
      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> markInstitutionForExclusion({required Institution institution}) async {
    //getUsers para percorrer os usuários e marcar para exclusão
    try {
      var userController = UserController();

      List<User> users = await userController.getInstitutionUsers(institutionId: institution.id);

      for (var user in users) {
        user.exclusionDate = DateTime.now();
        userController.update(user: user);
      }

      institution.exclusionDate = DateTime.now();
      return update(institution: institution);
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> delete({required Institution institution}) async {
    try {
      await FirebaseFirestore.instance.collection(_institutionCollection).doc(institution.id).delete();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }
}
