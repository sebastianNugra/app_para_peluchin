// Importa el modelo de usuario
import 'models/models.dart';

// Contrato (interfaz) del repositorio de usuarios
abstract class UserRepository {
  // Stream que expone el usuario actual (logueado o no)
  Stream<MyUser?> get user;

  // Registra un nuevo usuario
  Future<MyUser> signUp(MyUser myUser, String password);

  // Guarda o actualiza los datos del usuario en la BD
  Future<void> setUserData(MyUser user);

  // Inicia sesión con email y contraseña
  Future<void> signIn(String email, String password);

  // Cierra la sesión del usuario
  Future<void> logOut();
}
