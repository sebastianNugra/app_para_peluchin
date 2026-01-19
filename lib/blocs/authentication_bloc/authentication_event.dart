part of 'authentication_bloc.dart';

// Evento base del AuthenticationBloc
// Define todos los eventos relacionados con el estado global de autenticación
sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  // Permite comparación eficiente entre eventos
  @override
  List<Object> get props => [];
}

// Evento disparado cuando cambia el usuario autenticado
// Normalmente proviene de un stream (FirebaseAuth, UserRepository, etc.)
class AuthenticationUserChanged extends AuthenticationEvent {
  // Usuario actual
  // - null  -> usuario cerró sesión o no existe sesión
  // - MyUser -> usuario autenticado
  final MyUser? user;

  // Se emite cada vez que el repositorio detecta un cambio de sesión
  const AuthenticationUserChanged(this.user);
}
