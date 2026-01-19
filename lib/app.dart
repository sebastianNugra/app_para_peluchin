// Vista principal de la app
import 'package:app_peluche/app_view.dart';

// Widgets base de Flutter
import 'package:flutter/material.dart';

// Manejo de BLoC y dependencias
import 'package:flutter_bloc/flutter_bloc.dart';

// Repositorio de usuarios (lógica de dominio)
import 'package:user_repository/user_repository.dart';

// BLoC de autenticación
import 'blocs/authentication_bloc/authentication_bloc.dart';

// Widget raíz de la aplicación
class MyApp extends StatelessWidget {
  // Repositorio de usuarios inyectado
  final UserRepository userRepository;

  const MyApp(this.userRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    // Inyección del AuthenticationBloc en toda la app
    return RepositoryProvider<AuthenticationBloc>(
      create: (context) => AuthenticationBloc(userRepository: userRepository),

      // Vista principal de la aplicación
      child: const MyAppView(),
    );
  }
}
