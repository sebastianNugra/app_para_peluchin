import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

// Bloc responsable del ESTADO GLOBAL de autenticación de la app
// Decide si el usuario está autenticado, no autenticado o en estado desconocido
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  // Repositorio que abstrae Firebase/Auth u otra fuente de autenticación
  final UserRepository userRepository;

  // Suscripción al stream de usuario
  // Permite reaccionar automáticamente a login / logout
  late final StreamSubscription<MyUser?> _userSubscription;

  AuthenticationBloc({required this.userRepository})
    // Estado inicial: desconocido (app recién iniciada)
    : super(AuthenticationState.unknown()) {
    // Escucha continua al stream de usuario del repositorio
    // Cada cambio de sesión genera un evento interno del bloc
    _userSubscription = userRepository.user.listen((user) {
      add(AuthenticationUserChanged(user));
    });

    // Manejo del evento que notifica cambios de usuario
    on<AuthenticationUserChanged>((event, emit) {
      // Si el usuario NO es el usuario vacío,
      // se considera sesión válida y autenticada
      if (event.user != MyUser.empty) {
        emit(AuthenticationState.authenticated(event.user!));
      } else {
        // Usuario vacío => no hay sesión activa
        emit(const AuthenticationState.unauthenticated());
      }
    });
  }

  // Se ejecuta cuando el bloc se destruye
  // MUY IMPORTANTE: evita fugas de memoria
  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
