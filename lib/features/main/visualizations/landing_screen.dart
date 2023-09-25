import 'package:escala/features/main/visualizations/main_screen.dart';
import 'package:escala/features/user/user_controller.dart';
import 'package:escala/features/user/visualization/login_screen.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  //Widget _autoLogin() {
  //  return const AuthScreen(screenMode: ScreenMode.signIn);
  //}

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
    UserController userController = Provider.of(context);

    return FutureBuilder(
      future: userController.tryAutoLogin(),
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
            var currentUser = userController.currentUser;
            return currentUser.id.isEmpty ? const LoginScreen() : const MainScreen();
          }
        }
      },
    );
  }
}
