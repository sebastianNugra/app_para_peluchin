// Widget raíz de la aplicación
import 'package:app_peluche/app.dart';

// Observador global de BLoC (logs de eventos y estados)
import 'package:app_peluche/simple_bloc_observer.dart';

// Núcleo de BLoC
import 'package:bloc/bloc.dart';

// Inicialización de Firebase
import 'package:firebase_core/firebase_core.dart';

// Widgets base de Flutter
import 'package:flutter/material.dart';

// Repositorio de usuarios
import 'package:user_repository/user_repository.dart';

void main() async {
  // Garantiza que Flutter esté listo antes de inicializar servicios
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase (Auth, Firestore, etc.)
  await Firebase.initializeApp();

  // Observador global para depuración de BLoC
  Bloc.observer = SimpleBlocObserver();

  // Inicia la app inyectando el repositorio Firebase
  runApp(MyApp(FirebaseUserRepo()));
}
