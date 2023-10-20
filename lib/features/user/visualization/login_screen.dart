// ignore_for_file: use_build_context_synchronously
import 'package:escala/features/user/user_controller.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:escala/features/main/routes.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_util.dart';
import 'package:teb_package/visual_elements/teb_buttons_line.dart';
import 'package:teb_package/visual_elements/teb_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //final TextEditingController _emailController = TextEditingController();
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  //late String _email = '';
  late String _registration = '';
  late String _password = '';

  // utilizado para o controle de foco
  final _passwordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    setState(() => _isLoading = true);
    if (!(_formKey.currentState?.validate() ?? true)) {
      setState(() => _isLoading = false);
    } else {
      // salva os dados
      _formKey.currentState?.save();
      var userController = UserController();
      TebCustomReturn retorno;
      try {
        User user = User();
        user.registration = _registration;
        user.password = TebUtil.encrypt(_password);
        retorno = await userController.login(user: user, saveLoginData: true);
        if (retorno.returnType == TebReturnType.sucess) {
          Navigator.of(context).pushNamed(Routes.mainScreen, arguments: {'user': userController.currentUser});
        }
        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == TebReturnType.error) {
          TebCustomMessage(
            context: context,
            messageText: retorno.message,
            messageType: TebMessageType.error,
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TebCustomScaffold(
      responsive: true,
      title: const Text('Login'),
      body: Column(
        children: [
          Expanded(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text('Escala', style: Theme.of(context).textTheme.displayMedium),
                      TebTextEdit(
                          context: context,
                          controller: _registrationController,
                          labelText: 'Matrícula',
                          hintText: 'Informe sua matrícula',
                          onSave: (value) => _registration = value ?? '',
                          prefixIcon: Icons.account_box,
                          keyboardType: TextInputType.number,
                          nextFocusNode: _passwordFocus,
                          validator: (value) {
                            final finalValue = value ?? '';
                            if (finalValue.trim().isEmpty) return 'Informe a matrícula';
                            return null;
                          }),
                      TebTextEdit(
                        context: context,
                        controller: _passwordController,
                        labelText: 'Senha',
                        hintText: 'Informe sua senha',
                        isPassword: true,
                        onSave: (value) => _password = value ?? '',
                        prefixIcon: Icons.lock,
                        textInputAction: TextInputAction.done,
                        focusNode: _passwordFocus,
                        validator: (value) {
                          final finalValue = value ?? '';
                          if (finalValue.trim().isEmpty) return 'Informe a senha';
                          if (finalValue.trim().length < 6) return 'Senha deve possuir 6 ou mais caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _isLoading
                          ? const CircularProgressIndicator.adaptive()
                          : TebButtonsLine(
                              buttons: [
                                TebButton(
                                    label: 'Entrar',
                                    onPressed: _login,
                                    textStyle: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge!.fontSize)),
                              ],
                            ),
                      const SizedBox(height: 30),
                      OutlinedButton(
                        onPressed: () => Navigator.pushNamed(context, Routes.institutionForm, arguments: {'firstAccess': true}),
                        child: Text(
                          'Primeiro acesso? Clique aqui!',
                          style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge!.fontSize),
                        ),
                      ),
                    ],
                  ),
                )),
          )
        ],
      ),
    );
  }
}
