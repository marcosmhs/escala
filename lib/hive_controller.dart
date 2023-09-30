import 'package:escala/features/user/models/user.dart';
import 'package:escala/features/user/user_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class HiveController with ChangeNotifier {
  final _userHiveBoxName = 'user';
  late Box<dynamic> _userHiveBox;

  var _user = User();

  User get localUser => User.fromMap(_user.toMap());

  Future<void> _prepareUserHiveBox() async {
    if (!Hive.isBoxOpen(_userHiveBoxName)) {
      _userHiveBox = await Hive.openBox(_userHiveBoxName);
    } else {
      _userHiveBox = Hive.box(_userHiveBoxName);
    }
  }

  Future<void> chechLocalData() async {
    await _prepareUserHiveBox();
    if (_userHiveBox.isNotEmpty) {
      _user = _userHiveBox.get(_userHiveBox.keyAt(0));
    }

    var userController = UserController();

    if (_user.id.isEmpty) return;

    var userData = await userController.getUserData(userId: _user.id);

    if (userData.id.isEmpty) {
      _user = User();
    }
  }

  Future<void> removeBox() async {
    await _prepareUserHiveBox();
    await _userHiveBox.deleteFromDisk();
  }

  void saveUser({required User user}) async {
    await _prepareUserHiveBox();
    await _userHiveBox.put(user.id, user);
  }

  void clearUserHiveBox() async {
    await _prepareUserHiveBox();
    await _userHiveBox.clear();
  }
}
