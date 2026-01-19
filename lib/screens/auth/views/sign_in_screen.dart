import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Campo de texto personalizado reutilizable
import '../../../components/my_textfield.dart';

// Bloc encargado del inicio de sesión
import '../blocs/sign_in_bloc/sign_in_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Controladores para capturar email y contraseña
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  // Llave para manejar validaciones del formulario
  final _formKey = GlobalKey<FormState>();

  // Controla si se muestra el loader durante el login
  bool signInRequired = false;

  // Icono dinámico para mostrar/ocultar contraseña
  IconData iconPassword = CupertinoIcons.eye_fill;

  // Estado de visibilidad de la contraseña
  bool obscurePassword = true;

  // Mensaje de error global para credenciales incorrectas
  String? _errorMsg;

  @override
  Widget build(BuildContext context) {
    // Escucha los estados emitidos por SignInBloc
    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) {
        // Login exitoso → se oculta el loader
        if (state is SignInSuccess) {
          setState(() {
            signInRequired = false;
          });

          // Login en proceso → se muestra el loader
        } else if (state is SignInProcess) {
          setState(() {
            signInRequired = true;
          });

          // Login fallido → se muestra mensaje de error
        } else if (state is SignInFailure) {
          setState(() {
            signInRequired = false;
            _errorMsg = 'Invalid email or password';
          });
        }
      },

      // Formulario de inicio de sesión
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ---------- CAMPO EMAIL ----------
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(CupertinoIcons.mail_solid),

                // Mensaje de error global (credenciales inválidas)
                errorMsg: _errorMsg,

                // Validación de formato de email
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Please fill in this field';
                  } else if (!RegExp(
                    r'^[\w-\.]+@([\w-]+.)+[\w-]{2,4}$',
                  ).hasMatch(val)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                }
              )
            ),

            const SizedBox(height: 10),

            // ---------- CAMPO PASSWORD ----------
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                prefixIcon: const Icon(CupertinoIcons.lock_fill),

                // Se reutiliza el mismo mensaje de error
                errorMsg: _errorMsg,

                // Validación de contraseña
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Please fill in this field';
                  } else if (!RegExp(
                    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^]).{8,}$',
                  ).hasMatch(val)) {
                    return 'Please enter a valid password';
                  }
                  return null;
                },

                // Botón para mostrar/ocultar contraseña
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                      if (obscurePassword) {
                        iconPassword = CupertinoIcons.eye_fill;
                      } else {
                        iconPassword = CupertinoIcons.eye_slash_fill;
                      }
                    });
                  },
                  icon: Icon(iconPassword),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------- BOTÓN O LOADER ----------
            !signInRequired
                ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextButton(
                      // Acción de inicio de sesión
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Se dispara el evento de login al Bloc
                          context.read<SignInBloc>().add(
                            SignInRequired(
                              emailController.text,
                              passwordController.text,
                            ),
                          );
                        }
                      },

                      // Estilos del botón
                      style: TextButton.styleFrom(
                        elevation: 3.0,
                        backgroundColor: const Color.fromARGB(
                          255,
                          42,
                          179,
                          189,
                        ),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),

                      // Texto del botón
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 5,
                        ),
                        child: Text(
                          'Sign In',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                // Loader mientras se autentica
                : const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
