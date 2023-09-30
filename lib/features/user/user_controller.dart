import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escala/components/util/custom_return.dart';
import 'package:escala/components/util/uid_generator.dart';
import 'package:escala/features/department/department.dart';
import 'package:escala/features/department/department_controller.dart';
import 'package:escala/features/institution/institution_controller.dart';
import 'package:escala/features/institution/institution.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:escala/hive_controller.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';

class UserController with ChangeNotifier {
  final String _userInformationCollection = 'user';
  late User _currentUser;
  late Institution _currentInstitution;
  late Department _currentUserDepartment;

  UserController() {
    _currentUser = User();
    _currentInstitution = Institution();
    _currentUserDepartment = Department();
  }

  User get currentUser => User.fromMap(_currentUser.toMap());
  Department get currentUserDepartment => Department.fromMap(_currentUserDepartment.toMap());
  Institution get currentInstitution => Institution.fromMap(_currentInstitution.toMap());

  Future<CustomReturn> login({required User user, bool saveLoginData = false}) async {
    try {
      final temporaryUserData = await _getUsersByRegistration(user.registration);

      if (temporaryUserData.registration.isEmpty) return CustomReturn.error('Usuário não encontrado');
      if (temporaryUserData.password != user.password) return CustomReturn.error('Senha inválida');
      if (!temporaryUserData.active) return CustomReturn.error('Usuário Inativo');
      if (temporaryUserData.institutionId.isEmpty) return CustomReturn.error('Usuário sem instituição');
      if (temporaryUserData.exclusionDate != null) return CustomReturn.error('Instituição do usuário em processo de remoção');

      var institutionController = InstitutionController(_currentUser);

      var r = await institutionController.fillCurrentInstitution(institutionId: temporaryUserData.institutionId);
      if (r.returnType == ReturnType.error) {
        return CustomReturn.error('Erro ao localizar a instituição do usuário: ${r.message}');
      }
      _currentInstitution = institutionController.currentInstitution;

      var departmentCotnroller = DepartmentController(currentUser);
      _currentUserDepartment = await departmentCotnroller.getDepartmentById(
        departmentId: temporaryUserData.departmentId,
        institutionId: temporaryUserData.institutionId,
      );

      if (_currentUserDepartment.id.isEmpty) {
        return CustomReturn.error('Erro ao localizar a área/setor do usuário: ${r.message}');
      }

      _currentUser = temporaryUserData;

      var hiveController = HiveController();
      hiveController.saveUser(user: _currentUser);

      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  void logout() async {
    _currentUser = User();
    _currentInstitution = Institution();
    var hiveController = HiveController();
    hiveController.removeBox();
    notifyListeners();
  }

  Future<bool> userRegistrationExists({required String registratiton, required String id}) async {
    var userQuery = FirebaseFirestore.instance.collection(_userInformationCollection).where(
          "registration",
          isEqualTo: registratiton,
        );

    final users = await userQuery.get();
    final dataList = users.docs.map((doc) => doc.data()).toList();
    final List<User> u = [];

    for (var user in dataList) {
      u.add(User.fromMap(user));
    }
    var check = u.where((user) => user.id != id).isNotEmpty;
    return check;
  }

  Future<User> getUserData({required String userId, String setToken = ''}) async {
    final userDataRef = await FirebaseFirestore.instance.collection(_userInformationCollection).doc(userId).get();
    final userData = userDataRef.data();

    if (userData == null) {
      return User();
    }

    User user = User.fromMap(userData);
    return user;
  }

  Future<CustomReturn> create({required User user}) async {
    try {
      var checkUserRegistration = await userRegistrationExists(registratiton: user.registration, id: user.id);
      if (checkUserRegistration) {
        return CustomReturn.error("Matrícula ${user.registration} já existe");
      }

      user.id = UidGenerator.firestoreUid;
      await FirebaseFirestore.instance.collection(_userInformationCollection).doc(user.id).set(user.toMap());

      var hiveController = HiveController();
      hiveController.saveUser(user: user);

      return CustomReturn.sucess;
    } on fb_auth.FirebaseException catch (e) {
      return CustomReturn.error(e.code);
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> update({required User user, required User loggedUser}) async {
    try {
      if (await userRegistrationExists(registratiton: user.registration, id: user.id)) {
        return CustomReturn.error("Matrícula ${user.registration} já existe");
      }

      // preenche a senha do usuário com a senha corrente, para evitar que ela fique em branco.
      // somente é feito se a senha não foi preenchida, o que indica que ela não foi alterada.
      if (user.id == _currentUser.id) {
        user.password = user.password.isNotEmpty ? user.password : loggedUser.password;
      } else {
        if (user.password.isEmpty) {
          // isso é feito para garantir que a senha não é perdida
          var oldUser = await getUserData(userId: user.id);
          user.password = oldUser.password;
        }
      }

      await FirebaseFirestore.instance.collection(_userInformationCollection).doc(user.id).set(user.toMap());

      var hiveController = HiveController();
      hiveController.saveUser(user: user);

      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Stream<QuerySnapshot<Object?>> getUsers({
    String registration = '',
    String departmentId = '',
    bool onlyActiveUsers = false,
    String institutionId = '',
  }) {
    var collection = FirebaseFirestore.instance.collection(_userInformationCollection);

    var userQuery = collection.where(
      "institutionId",
      isEqualTo: institutionId.isNotEmpty ? institutionId : _currentInstitution.id,
    );

    if (registration.isNotEmpty) userQuery = userQuery.where("registration", isEqualTo: registration);
    if (departmentId.isNotEmpty) userQuery = userQuery.where("departmentId", isEqualTo: departmentId);
    if (onlyActiveUsers) userQuery = userQuery.where("active", isEqualTo: true);

    return userQuery.snapshots();
  }

  Future<User> _getUsersByRegistration(String registration) async {
    try {
      var collection = FirebaseFirestore.instance.collection(_userInformationCollection);
      var userQuery = collection.where("registration", isEqualTo: registration).where("active", isEqualTo: true);

      final users = await userQuery.get();
      final dataList = users.docs.map((doc) => doc.data()).toList();

      return User.fromMap(dataList.first);
    } catch (e) {
      return User();
    }
  }

  Future<List<User>> getInstitutionUsers({required String institutionId}) async {
    try {
      var collection = FirebaseFirestore.instance.collection(_userInformationCollection);
      var userQuery = collection.where("institutionId", isEqualTo: institutionId);

      final users = await userQuery.get();
      final dataList = users.docs.map((doc) => doc.data()).toList();

      final List<User> r = [];
      for (var user in dataList) {
        r.add(User.fromMap(user));
      }
      return r;
    } catch (e) {
      return [];
    }
  }

  Future<List<User>> getUsersFromDepartment({required String departmentId, bool onlyActiveUsers = false}) async {
    try {
      var collection = FirebaseFirestore.instance.collection(_userInformationCollection);
      var userQuery = !onlyActiveUsers
          ? collection.where("departmentId", isEqualTo: departmentId)
          : collection.where("departmentId", isEqualTo: departmentId).where('active', isEqualTo: true);

      final users = await userQuery.get();
      final dataList = users.docs.map((doc) => doc.data()).toList();

      final List<User> r = [];
      for (var user in dataList) {
        r.add(User.fromMap(user));
      }
      return r;
    } catch (e) {
      return [];
    }
  }
}
