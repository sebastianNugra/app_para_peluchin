import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

// Vincula este archivo con los eventos del SignIn
part 'sign_in_event.dart';

// Vincula este archivo con los estados del SignIn
part 'sign_in_state.dart';

// BLoC responsable exclusivamente del flujo de inicio y cierre de sesión
class SignInBloc extends Bloc<SignInEvent, SignInState> {
  // Repositorio que encapsula la lógica real de autenticación
  // (Firebase, API, base de datos, etc.)
  final UserRepository _userRepository;

  // Estado inicial del BLoC: aún no se ha intentado iniciar sesión
  SignInBloc(this._userRepository) : super(SignInInitial()) {
    // Maneja el evento de inicio de sesión
    on<SignInRequired>((event, emit) async {
      // Notifica a la UI que el proceso de login está en curso
      // Se usa normalmente para mostrar un loader
      emit(SignInProcess());

      try {
        // Llamada al repositorio para autenticar al usuario
        // Si falla, lanza una excepción
        await _userRepository.signIn(event.email, event.password);

        // IMPORTANTE:
        // Aquí NO emites SignInSuccess
        // El flujo depende de AuthenticationBloc u otro listener global
      } catch (e) {
        // Si ocurre cualquier error, se notifica a la UI
        emit(SignInFailure());
      }
    });

    // Maneja el evento de cierre de sesión
    // No cambia estado local porque el control global
    // normalmente lo maneja AuthenticationBloc
    on<SignOutRequired>((event, emit) async => await _userRepository.logOut());
  }
}
