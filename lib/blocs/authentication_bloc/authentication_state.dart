part of 'authentication_bloc.dart';

// Estados globales posibles de autenticación de la app
// authenticated    -> usuario logueado correctamente
// unauthenticated  -> usuario no logueado
// unknown          -> estado inicial (splash / verificación)
enum AuthenticationStatus { initial, authenticated, unauthenticated, unknown }

// Estado principal del AuthenticationBloc
// Maneja el estado global de sesión de la aplicación
class AuthenticationState extends Equatable {
  // Constructor privado base
  // Evita crear estados inconsistentes desde fuera
  const AuthenticationState._({
    this.status = AuthenticationStatus.unknown,
    this.user,
  });

  // Estado actual de autenticación
  final AuthenticationStatus status;

  // Usuario autenticado (null si no hay sesión)
  final MyUser? user;

  const AuthenticationState.unknown() : this._();
  
  // Estado inicial de la app
  // Se usa normalmente al arrancar (splash / bootstrap)
  const AuthenticationState.initial()
    : this._(status: AuthenticationStatus.initial);

  // Estado cuando el usuario está autenticado
  // Guarda el usuario en memoria global
  const AuthenticationState.authenticated(MyUser myUser)
    : this._(status: AuthenticationStatus.authenticated, user: myUser);

  // Estado cuando el usuario NO está autenticado
  // Elimina cualquier referencia a usuario
  const AuthenticationState.unauthenticated()
    : this._(status: AuthenticationStatus.unauthenticated);

  // Permite comparar estados correctamente en Bloc
  // Evita rebuilds innecesarios
  @override
  List<Object?> get props => [status, user];
}
