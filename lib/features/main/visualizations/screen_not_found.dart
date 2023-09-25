import 'package:escala/features/main/routes.dart';
import 'package:flutter/material.dart';

class ScreenNotFound extends StatelessWidget {
  final String screenName;

  // ignore: use_key_in_widget_constructors
  const ScreenNotFound(this.screenName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: <Widget>[
            Icon(Icons.error),
            SizedBox(width: 20),
            Text("Erro"),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                "Tela não encontrada",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 15),
              Text('Rota: $screenName'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          // limpa a stak de telas e chama a tela inicial
          Navigator.restorablePushNamedAndRemoveUntil(
            context,
            Routes.mainScreen,
            (route) => false,
          );
        },
        label: const Text('Tela Inicial'),
        icon: const Icon(Icons.home),
      ),
    );
  }
}
