import 'package:escala/features/user/models/user.dart';
import 'package:escala/features/user/user_controller.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:escala/features/main/routes.dart';

import 'package:package_info_plus/package_info_plus.dart';

class CustomDrawer extends StatefulWidget {
  final User currentUser;
  const CustomDrawer({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  PackageInfo _packageInfo = PackageInfo(
    appName: '',
    packageName: '',
    version: '',
    buildNumber: '',
    buildSignature: '',
    installerStore: '',
  );

  Column _option({
    required BuildContext context,
    required Icon icon,
    required String text,
    String route = '',
    Object? args,
    Function()? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: icon,
          title: Text(text),
          onTap: route == ''
              ? onTap
              : () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, route, arguments: args);
                },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('Menu'),
            // remove o botão do drawer quando ele está aberto
            automaticallyImplyLeading: true,
          ),
          if (widget.currentUser.manager) const Divider(),
          if (widget.currentUser.manager)
            _option(
              context: context,
              icon: const Icon(Icons.account_balance_rounded),
              text: 'Instituição',
              route: Routes.institutionForm,
              args: {'user': widget.currentUser},
            ),
          if (widget.currentUser.manager)
            _option(
              context: context,
              icon: const Icon(Icons.door_sliding_outlined),
              text: 'Área/Setor',
              route: Routes.departmentScreen,
              args: {'user': widget.currentUser},
            ),
          if (widget.currentUser.manager)
            _option(
              context: context,
              icon: const Icon(Icons.people_alt),
              text: 'Usuários',
              route: Routes.userScreen,
              args: {'user': widget.currentUser},
            ),
          if (widget.currentUser.manager)
            _option(
              context: context,
              icon: const Icon(Icons.schedule),
              text: 'Escalas',
              route: Routes.scheduleScreen,
              args: {'user': widget.currentUser},
            ),
          if (widget.currentUser.manager) const Divider(),
          _option(
            context: context,
            icon: const Icon(Icons.person_sharp),
            text: 'Alterar meus dados',
            route: Routes.userForm,
            args: {'user': widget.currentUser},
          ),
          const Spacer(),
          _option(
            context: context,
            icon: const Icon(Icons.settings),
            text: 'Configurações',
            route: Routes.institutionConfigForm,
            args: {'user': widget.currentUser},
          ),
          _option(
            context: context,
            icon: const Icon(Icons.exit_to_app_sharp),
            text: 'Sair',
            onTap: () {
              UserController().logout();
              Navigator.of(context).restorablePushNamedAndRemoveUntil(
                Routes.landingScreen,
                (route) => false,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Versão: ${_packageInfo.version}.${_packageInfo.buildNumber}'),
          )
        ],
      ),
    );
  }
}
