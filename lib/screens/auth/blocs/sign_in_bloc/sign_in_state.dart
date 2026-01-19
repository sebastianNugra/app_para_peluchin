part of 'sign_in_bloc.dart';

// Clase base sellada para todos los estados del SignIn
// Al ser sealed, solo los estados definidos aquí pueden extenderla
sealed class SignInState extends Equatable {
  const SignInState();

  // Permite comparar estados por valor y no por referencia
  // Aquí no hay propiedades compartidas entre estados
  @override
  List<Object> get props => [];
}

// Estado inicial del BLoC
// Representa la pantalla en reposo, antes de cualquier acción
final class SignInInitial extends SignInState {}

// Estado emitido cuando ocurre un error en el inicio de sesión
// Por ejemplo: credenciales incorrectas o fallo de red
final class SignInFailure extends SignInState {}

// Estado emitido mientras se está ejecutando el proceso de login
// Se usa normalmente para mostrar un indicador de carga
final class SignInProcess extends SignInState {}

// Estado emitido cuando el inicio de sesión es exitoso
// La UI suele reaccionar navegando a la pantalla principal
final class SignInSuccess extends SignInState {}
