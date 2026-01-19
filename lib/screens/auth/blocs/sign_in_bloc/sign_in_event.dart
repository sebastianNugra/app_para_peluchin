part of 'sign_in_bloc.dart';

// Clase base sellada para todos los eventos del SignIn
// Define las acciones que el usuario puede disparar en la UI
sealed class SignInEvent extends Equatable {
  const SignInEvent();

  // Permite comparar eventos por valor
  // Útil para evitar ejecuciones innecesarias
  @override
  List<Object> get props => [];
}

// Evento disparado cuando el usuario intenta iniciar sesión
// Contiene las credenciales necesarias para la autenticación
class SignInRequired extends SignInEvent {
  final String email;
  final String password;

  // Se envía desde la UI al presionar el botón "Sign In"
  const SignInRequired(this.email, this.password);

  // Permite identificar el evento como único según sus datos
  @override
  List<Object> get props => [email, password];
}

// Evento disparado cuando el usuario solicita cerrar sesión
// No requiere datos adicionales
class SignOutRequired extends SignInEvent {}
