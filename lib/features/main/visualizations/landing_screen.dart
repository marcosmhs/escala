import 'package:escala/features/main/visualizations/main_screen.dart';
import 'package:escala/features/user/visualization/login_screen.dart';
import 'package:escala/hive_controller.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  Widget _errorScreen({required String errorMessage}) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Fatal error!'),
            const SizedBox(height: 20),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var hiveController = HiveController();

    return FutureBuilder(
      future: hiveController.chechLocalData(),
      builder: (ctx, snapshot) {
        // enquanto está carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
          // em caso de erro
        } else {
          if (snapshot.error != null) {
            return _errorScreen(errorMessage: snapshot.error.toString());
            // ao final do processo
          } else {
            // irá avaliar se o usuário possui login ou não
            return hiveController.localUser.id.isEmpty ? const LoginScreen() : MainScreen(user: hiveController.localUser);
          }
        }
      },
    );
  }
}
