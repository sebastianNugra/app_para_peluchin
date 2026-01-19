// Entidad de usuario usada para almacenamiento de datos (BD / Firebase)
class MyUserEntity {
  // Campos que se guardan en la base de datos
  String userId;
  String email;
  String name;
  bool hasActiveCart;

  // Constructor obligatorio para crear la entidad
  MyUserEntity({
    required this.userId,
    required this.email,
    required this.name,
    required this.hasActiveCart,
  });

  // Convierte la entidad a un Map (formato compatible con BD / Firestore)
  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'hasActiveCart': hasActiveCart,
    };
  }

  // Crea la entidad a partir de un Map obtenido de la BD / Firestore
  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
      userId: doc['userId'],
      email: doc['email'],
      name: doc['name'],
      hasActiveCart: doc['hasActiveCart'],
    );
  }
}
