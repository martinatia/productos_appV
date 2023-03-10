import 'package:flutter/material.dart';
import 'package:productos_app/providers/login_form_provider.dart';
import 'package:provider/provider.dart';
import 'package:productos_app/ui/input_decorations.dart';
import 'package:productos_app/widgets/widgets.dart';

import '../services/services.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
          child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 250),
            CardContainer(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text('Login', style: Theme.of(context).textTheme.headline4),
                  const SizedBox(height: 30),
                  ChangeNotifierProvider(
                    create: (_) => LoginFormProvider(),
                    child: const _LoginForm(),
                  ),
                  // const _LoginForm()
                ],
              ),
            ),
            const SizedBox(height: 50),
            TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, 'register'),
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                        Colors.indigo.withOpacity(0.2)),
                    shape: MaterialStateProperty.all(const StadiumBorder())),
                child: const Text('Crear una nueva cuenta',
                    style: TextStyle(fontSize: 18, color: Colors.black87))),
            const SizedBox(height: 100)
          ],
        ),
      )),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    // ignore: avoid_unnecessary_containers
    return Container(
      child: Form(
        //TODO: mantener la referencia del key
        key: loginForm.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                  hintText: 'ejemplo@servidor.com',
                  labelText: 'Correo electr??nico',
                  prefixIcon: Icons.alternate_email),
              onChanged: (value) => loginForm.email = value,
              validator: (value) {
                String pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regExp = RegExp(pattern);
                return regExp.hasMatch(value ?? '')
                    ? null
                    : 'No es un correo electr??nico valido';
              },
            ),
            const SizedBox(height: 30),
            TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: InputDecorations.authInputDecoration(
                    hintText: 'Ingrese su contrase??a',
                    labelText: 'Contrase??a',
                    prefixIcon: Icons.lock_outline),
                onChanged: (value) => loginForm.password = value,
                validator: (value) {
                  if (value != null && value.length >= 6) return null;
                  return 'La contrase??a debe contener al menos seis caracteres';
                }),
            const SizedBox(height: 30),
            MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                disabledColor: Colors.grey,
                elevation: 0,
                color: Colors.deepPurple,
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 15),
                    child:
                        // const Text('Iniciar Sesi??n',style: TextStyle(color: Colors.white))
                        Text(
                            loginForm.isLoading
                                ? 'Espere...'
                                : 'Iniciar Sesi??n',
                            style: const TextStyle(color: Colors.white))),
                onPressed: loginForm.isLoading
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();
                        final authService =
                            Provider.of<AuthService>(context, listen: false);
                        if (!loginForm.isValidForm()) return;
                        loginForm.isLoading = true;
                        // await Future.delayed(const Duration(seconds: 2));
                        //TODO: validar si el login es correcto
                        final String? errorMessage = await authService.login(
                            loginForm.email, loginForm.email);
                        if (errorMessage == null) {
                          Navigator.pushReplacementNamed(context, 'home');
                        } else {
                          // print(errorMessage);
                          NotificationsService.showSnackbar(errorMessage);
                          loginForm.isLoading = false;
                        }
                      })
          ],
        ),
      ),
    );
  }
}
