import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/authentication_bloc/authentication_bloc.dart';
import 'screens/auth/views/welcome_screens.dart';
import 'screens/home/views/home_screen.dart';


class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'App para conectar al peluche',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            background: Colors.grey.shade200, 
            onBackground: Colors.black, 
            primary: Colors.blue,
            onPrimary: Colors.white
          )
        ),
        home: BlocBuilder<AuthenticationBloc, AuthenticationState> (
          builder: ((context, state) {
            if (state.status == AuthenticationStatus.authenticated) {
              return const HomeScreen();
            } else {
              return const WelcomeScreen();
            }
          }),
        ));
  }
}