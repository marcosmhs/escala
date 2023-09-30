//import 'dart:convert';

import 'package:escala/features/department/department_controller.dart';
import 'package:escala/features/department/visualizations/department_form.dart';
import 'package:escala/features/department/visualizations/department_screen.dart';
import 'package:escala/features/institution/institution_controller.dart';
import 'package:escala/features/institution/visualizations/institution_config_form.dart';
import 'package:escala/features/institution/visualizations/institution_form.dart';
import 'package:escala/features/institution/visualizations/institution_remove_screen.dart';
import 'package:escala/features/main/visualizations/landing_screen.dart';
import 'package:escala/features/main/visualizations/main_screen.dart';
import 'package:escala/features/main/visualizations/screen_not_found.dart';
import 'package:escala/features/schedule/schedule_controller.dart';
import 'package:escala/features/schedule/visualizations/schedule_form.dart';
import 'package:escala/features/schedule/visualizations/schedule_screen.dart';
import 'package:escala/features/user/user_controller.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:escala/features/user/visualization/login_screen.dart';
import 'package:escala/features/user/visualization/user_form.dart';
import 'package:escala/features/user/visualization/user_screen.dart';
import 'package:escala/features/main/routes.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
//import 'package:flutter/services.dart';
//import 'package:json_theme/json_theme.dart';
import 'package:provider/provider.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';

// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //final themeLight = ThemeDecoder.decodeThemeData(jsonDecode(
  //  await rootBundle.loadString('assets/theme_light.json'),
  //))!;
  //final themeDark = ThemeDecoder.decodeThemeData(jsonDecode(
  //  await rootBundle.loadString('assets/theme_dark.json'),
  //))!;

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    //home: Escala(themeLight: themeLight, themeDark: themeDark),
    home: Escala(),
    supportedLocales: [
      Locale('en', ''),
      Locale('pt-br', ''),
    ],
  ));
}

class Escala extends StatefulWidget {
  final ThemeData? themeLight;
  final ThemeData? themeDark;

  const Escala({
    Key? key,
    this.themeLight,
    this.themeDark,
  }) : super(key: key);

  @override
  State<Escala> createState() => _Home();
}

class _Home extends State<Escala> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // UserController
        ChangeNotifierProvider(create: (_) => UserController()),
        // Institution Controller
        ChangeNotifierProxyProvider<UserController, InstitutionController>(
          create: (_) => InstitutionController(User()),
          update: (ctx, userController, previous) {
            return InstitutionController(userController.currentUser);
          },
        ),
        // Schedule Controller
        ChangeNotifierProxyProvider<UserController, ScheduleController>(
          create: (_) => ScheduleController(User()),
          update: (ctx, userController, previous) {
            return ScheduleController(userController.currentUser);
          },
        ),
        // Department Controller
        ChangeNotifierProxyProvider<UserController, DepartmentController>(
          create: (_) => DepartmentController(User()),
          update: (ctx, userController, previous) {
            return DepartmentController(userController.currentUser);
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('pt-br', ''),
        ],
        title: 'Escala',
        //theme: widget.themeLight,
        //darkTheme: widget.themeDark,
        routes: {
          Routes.institutionForm: (ctx) => const InstitutionForm(),
          Routes.institutionConfigForm: (ctx) => const InstitutionConfigForm(),
          Routes.landingScreen: (ctx) => const LandingScreen(),
          Routes.loginScreen: (ctx) => const LoginScreen(),
          Routes.mainScreen: (ctx) => MainScreen(),
          Routes.userForm: (ctx) => const UserForm(),
          Routes.userScreen: (ctx) => const UserScreen(),
          Routes.scheduleForm: (ctx) => const ScheduleForm(),
          Routes.scheduleScreen: (ctx) => const ScheduleScreen(),
          Routes.departmentScreen: (ctx) => const DepartmentScreen(),
          Routes.departmentForm: (ctx) => const DepartmentForm(),
          Routes.removeInstitution: (ctx) => const InstitutionRemoveScreen(),
        },
        initialRoute: Routes.landingScreen,
        // Executado quando uma tela não é encontrada
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (_) {
            return ScreenNotFound(settings.name.toString());
          });
        },
      ),
    );
  }
}
