// Importa la entidad usada para persistencia de datos
import '../entities/entities.dart';

// Modelo principal de usuario en la aplicación
class MyUser {
  // Datos esenciales del usuario
  String userId;
  String email;
  String name;

  // Constructor obligatorio para crear un usuario válido
  MyUser({required this.userId, required this.email, required this.name});

  // Usuario vacío para estados iniciales o no autenticados
  static final empty = MyUser(userId: '', email: '', name: '');

  // Convierte el modelo a entidad (para guardar en BD o backend)
  MyUserEntity toentity() {
    return MyUserEntity(userId: userId, email: email, name: name);
  }

  // Convierte una entidad a modelo (datos que vienen de BD o backend)
  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      email: entity.email,
      name: entity.name,
    );
  }

  // Representación en texto (útil para debugging)
  @override
  String toString() {
    return 'MyUser: $userId, $email, $name';
  }
}
