// Permite escribir logs en consola
import 'dart:developer';

// Base del patrón BLoC
import 'package:bloc/bloc.dart';

// Observador global de todos los BLoC de la app
class SimpleBlocObserver extends BlocObserver {
  // Se ejecuta cuando un BLoC es creado
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    log('onCreate -- bloc: ${bloc.runtimeType}');
  }

  // Se ejecuta cuando un BLoC recibe un evento
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    log('onEvent -- bloc: ${bloc.runtimeType}, event: $event');
  }

  // Se ejecuta cuando cambia el estado de un Cubit o Bloc
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log('onChange -- bloc: ${bloc.runtimeType}, change: $change');
  }

  // Se ejecuta cuando ocurre una transición (evento → estado)
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log('onTransition -- bloc: ${bloc.runtimeType}, transition: $transition');
  }

  // Se ejecuta cuando ocurre un error en cualquier BLoC
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log('onError -- bloc: ${bloc.runtimeType}, error: $error');
    super.onError(bloc, error, stackTrace);
  }

  // Se ejecuta cuando un BLoC se destruye
  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    log('onClose -- bloc: ${bloc.runtimeType}');
  }
}
