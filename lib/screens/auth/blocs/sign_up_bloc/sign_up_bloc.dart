import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

// Archivos que contienen la definición de eventos y estados
// asociados a este BLoC
part 'sign_up_event.dart';
part 'sign_up_state.dart';

// BLoC encargado exclusivamente del flujo de registro (Sign Up)
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  // Repositorio que abstrae la fuente de datos (Firebase u otra)
  // y expone operaciones relacionadas con usuarios
  final UserRepository _userRepository;

  // Constructor del BLoC:
  // - recibe el repositorio por inyección de dependencias
  // - define el estado inicial del BLoC
  SignUpBloc(this._userRepository) : super(SignUpInitial()) {
    // Maneja el evento SignUpRequired
    on<SignUpRequired>((event, emit) async {
      // Estado emitido cuando el proceso de registro inicia
      // (útil para mostrar loaders/spinners en la UI)
      emit(SignUpProcess());

      try {
        // Llama al repositorio para registrar al usuario
        // usando los datos recibidos en el evento
        MyUser myUser = await _userRepository.signUp(
          event.user,
          event.password,
        );

        // Guarda información adicional del usuario
        // en la base de datos (por ejemplo Firestore)
        await _userRepository.setUserData(myUser);

        // Estado emitido cuando el registro se completa con éxito
        emit(SignUpSuccess());
      } catch (e) {
        // Estado emitido si ocurre cualquier error
        // durante el proceso de registro
        emit(SignUpFailure());
      }
    });
  }
}
