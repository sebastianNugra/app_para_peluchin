part of 'sign_up_bloc.dart';

// Clase base sellada (sealed) para representar todos los posibles estados
// del proceso de registro (Sign Up) dentro del BLoC.
sealed class SignUpState extends Equatable {
  const SignUpState();

  // Lista de propiedades usadas por Equatable para comparar estados.
  // Al estar vacía, los estados se comparan solo por tipo.
  @override
  List<Object> get props => [];
}

// Estado inicial del BLoC antes de que ocurra cualquier acción
final class SignUpInitial extends SignUpState {}

// Estado que representa que el registro fue exitoso
final class SignUpSuccess extends SignUpState {}

// Estado que indica que ocurrió un error durante el registro
final class SignUpFailure extends SignUpState {}

// Estado intermedio que indica que el proceso de registro
// está en ejecución (loading / processing)
final class SignUpProcess extends SignUpState {}
