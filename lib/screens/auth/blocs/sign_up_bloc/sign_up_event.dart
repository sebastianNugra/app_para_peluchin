part of 'sign_up_bloc.dart';

// Clase base sellada para todos los eventos relacionados
// con el proceso de registro (Sign Up) en el BLoC.
sealed class SignUpEvent extends Equatable {
  const SignUpEvent();

  // Propiedades usadas por Equatable para comparar eventos.
  // Por defecto está vacía y se sobrescribe en eventos concretos.
  @override
  List<Object> get props => [];
}

// Evento que se dispara cuando el usuario solicita registrarse
// proporcionando la información necesaria.
class SignUpRequired extends SignUpEvent {
  // Objeto de dominio que contiene los datos del usuario
  final MyUser user;

  // Contraseña ingresada durante el registro
  final String password;

  // Constructor que recibe los datos requeridos para el registro
  const SignUpRequired(this.user, this.password);

  // Se incluyen user y password para que Equatable
  // pueda distinguir correctamente instancias de este evento
  @override
  List<Object> get props => [user, password];
}
