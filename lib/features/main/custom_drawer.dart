import 'package:escala/features/user/user_controller.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:escala/features/main/routes.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

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
        //const Divider(height: 0),
        ListTile(
          leading: icon,
          title: Text(text),
          onTap: route == ''
              ? onTap
              : () {
                  // fecha o drawer
                  Navigator.of(context).pop();
                  // abre a nova tela
                  Navigator.pushNamed(context, route, arguments: args);
                },
        ),
      ],
    );
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
          if (Provider.of<UserController>(context, listen: false).currentUser.manager) const Divider(),
          if (Provider.of<UserController>(context, listen: false).currentUser.manager)
            _option(
              context: context,
              icon: const Icon(Icons.account_balance_rounded),
              text: 'Instituição',
              route: Routes.institutionForm,
            ),
          if (Provider.of<UserController>(context, listen: false).currentUser.manager)
            _option(
              context: context,
              icon: const Icon(Icons.door_sliding_outlined),
              text: 'Área/Setor',
              route: Routes.departmentScreen,
            ),
          if (Provider.of<UserController>(context, listen: false).currentUser.manager)
            _option(
              context: context,
              icon: const Icon(Icons.people_alt),
              text: 'Usuários',
              route: Routes.userScreen,
            ),
          if (Provider.of<UserController>(context, listen: false).currentUser.manager)
            _option(
              context: context,
              icon: const Icon(Icons.schedule),
              text: 'Escalas',
              route: Routes.scheduleScreen,
              args: {'user': Provider.of<UserController>(context, listen: false).currentUser},
            ),
          if (Provider.of<UserController>(context, listen: false).currentUser.manager) const Divider(),
          _option(
            context: context,
            icon: const Icon(Icons.person_sharp),
            text: 'Alterar meus dados',
            route: Routes.userForm,
            args: {'user': Provider.of<UserController>(context, listen: false).currentUser},
          ),
          const Spacer(),
          _option(
            context: context,
            icon: const Icon(Icons.settings),
            text: 'Configurações',
            route: Routes.institutionConfigForm,
          ),
          _option(
            context: context,
            icon: const Icon(Icons.exit_to_app_sharp),
            text: 'Sair',
            onTap: () {
              Provider.of<UserController>(context, listen: false).logout();
              Navigator.restorablePushNamedAndRemoveUntil(
                context,
                Routes.landingScreen,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
