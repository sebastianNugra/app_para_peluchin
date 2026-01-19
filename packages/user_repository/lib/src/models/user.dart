// Importa la entidad usada para persistencia de datos
import '../entities/entities.dart';

// Modelo principal de usuario en la aplicación
class MyUser {

  // Datos esenciales del usuario
  String userId;
  String email;
  String name;
  bool hasActiveCart;

  // Constructor obligatorio para crear un usuario válido
  MyUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.hasActiveCart,
  });

  // Usuario vacío para estados iniciales o no autenticados
  static final empty = MyUser(
    userId: '',
    email: '',
    name: '',
    hasActiveCart: false,
  );

  // Convierte el modelo a entidad (para guardar en BD o backend)
  MyUserEntity toentity() {
    return MyUserEntity(
      userId: userId,
      email: email,
      name: name,
      hasActiveCart: hasActiveCart,
    );
  }

  // Convierte una entidad a modelo (datos que vienen de BD o backend)
  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      email: entity.email,
      name: entity.name,
      hasActiveCart: entity.hasActiveCart,
    );
  }

  // Representación en texto (útil para debugging)
  @override
  String toString() {
    return 'MyUser: $userId, $email, $name, $hasActiveCart';
  }
}
