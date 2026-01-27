// Pantalla de login
import 'package:app_peluche/screens/auth/views/welcome_screens.dart';
import 'package:app_peluche/screens/home/views/ThemeProvider.dart';

// Widgets base de Flutter
import 'package:flutter/material.dart';

// BLoC para manejar estados
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// BLoC de autenticación
import 'blocs/authentication_bloc/authentication_bloc.dart';

// Pantalla principal
import 'screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'screens/auth/views/log_page.dart';
import 'screens/home/views/home_screen.dart';

// Vista principal de la aplicación
class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    // Configuración global de la app
    return MaterialApp(
      title: 'App para conectar al peluche',
      debugShowCheckedModeBanner: false,

      // Tema global de colores
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: Colors.grey.shade200,
          onSurface: Colors.black,
          primary: Colors.blue,
          onPrimary: Colors.white,
          onBackground: Colors.black,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
      ),

      // Tema oscuro global de colores
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          surface: Colors.grey.shade900,
          onSurface: Colors.white,
          primary: Colors.blue,
          onPrimary: Colors.white,
          onBackground: Colors.white,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      themeMode: themeProvider.modoOscuro ? ThemeMode.dark : ThemeMode.light,

      // Decide qué pantalla mostrar según el estado de autenticación
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          print('AUTH STATUS = ${state.status}');

          // Usuario autenticado → Home
          switch (state.status) {
            case AuthenticationStatus.initial:
              return const LogPage();

            case AuthenticationStatus.unauthenticated:
              return const WelcomeScreen();

            case AuthenticationStatus.authenticated:
              return BlocProvider(
                create: (context) => SignInBloc(
                  context.read<AuthenticationBloc>().userRepository,
                ),
                child: MyHomePage(title: 'App Peluchín'),
              );

            case AuthenticationStatus.unknown:
              return const SizedBox(); // o loader técnico
          }
        },
      ),
    );
  }
}
