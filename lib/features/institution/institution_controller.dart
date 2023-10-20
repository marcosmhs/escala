import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/department_controller.dart';
import 'package:escala/features/institution/institution.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:escala/features/user/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class InstitutionController with ChangeNotifier {
  final String _institutionCollection = 'institution';
  late Institution _currentInstitution;
  final User currentUser;

  InstitutionController(this.currentUser) {
    _currentInstitution = Institution();
  }

  Institution get currentInstitution => Institution.fromMap(_currentInstitution.toMap());

  Future<TebCustomReturn> fillCurrentInstitution({required String institutionId}) async {
    final institutionDataRef = await FirebaseFirestore.instance.collection(_institutionCollection).doc(institutionId).get();
    final data = institutionDataRef.data();

    if (data == null) {
      return TebCustomReturn.error('Instituição não encontrada');
    }

    _currentInstitution = Institution.fromMap(data);

    return TebCustomReturn.sucess;
  }

  Future<Institution> getInstitutionFromId({required String institutionId}) async {
    final institutionDataRef = await FirebaseFirestore.instance.collection(_institutionCollection).doc(institutionId).get();
    final data = institutionDataRef.data();

    return data == null ? Institution() : Institution.fromMap(data);
  }

  Future<TebCustomReturn> create({required Institution institution}) async {
    try {
      institution.id = TebUidGenerator.firestoreUid;
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

      return TebCustomReturn.sucess;
    } on fb_auth.FirebaseException catch (e) {
      return TebCustomReturn.error(e.code);
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Future<TebCustomReturn> update({required Institution institution}) async {
    try {
      institution.updateDate = DateTime.now();
      await FirebaseFirestore.instance.collection(_institutionCollection).doc(institution.id).set(institution.toMap());
      _currentInstitution = institution;
      notifyListeners();
      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Future<TebCustomReturn> markInstitutionForExclusion({required Institution institution, required User user}) async {
    //getUsers para percorrer os usuários e marcar para exclusão
    try {
      var userController = UserController();

      List<User> users = await userController.getInstitutionUsers(institutionId: institution.id);

      for (var user in users) {
        user.exclusionDate = DateTime.now();
        userController.update(user: user, loggedUser: user);
      }

      institution.exclusionDate = DateTime.now();
      return update(institution: institution);
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Future<TebCustomReturn> delete({required Institution institution}) async {
    try {
      await FirebaseFirestore.instance.collection(_institutionCollection).doc(institution.id).delete();
      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }
}
