import 'package:escala/components/messaging/custom_message.dart';
import 'package:escala/components/util/custom_return.dart';
import 'package:escala/components/screen_elements/custom_scaffold.dart';
import 'package:escala/components/util/util.dart';
import 'package:escala/components/visual_elements/buttons_line.dart';
import 'package:escala/components/visual_elements/custom_textFormField.dart';
import 'package:escala/features/user/user_controller.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:escala/features/main/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      UserController userController = Provider.of(context, listen: false);
      CustomReturn retorno;
      try {
        User user = User();
        //user.email = _email;
        user.registration = _registration;
        user.password = Util.encrypt(_password);
        retorno = await userController.login(user: user, saveLoginData: true);
        if (retorno.returnType == ReturnType.sucess) {
          // ignore: use_build_context_synchronously
          Navigator.pushNamed(context, Routes.mainScreen);
        }
        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == ReturnType.error) {
          // ignore: use_build_context_synchronously
          CustomMessage(
            context: context,
            messageText: retorno.message,
            messageType: MessageType.error,
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Login',
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
                      CustomTextEdit(
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
                      CustomTextEdit(
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
                          : ButtonsLine(
                              buttons: [
                                Button(
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
