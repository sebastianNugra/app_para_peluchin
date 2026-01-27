// Define esta carpeta como una librería reutilizable
library user_repository;

// Expone las entidades (persistencia / BD)
export 'src/entities/entities.dart';

// Expone los modelos (lógica de la aplicación)
export 'src/models/models.dart';

// Expone la interfaz del repositorio
export 'src/user_repo.dart';

// Expone la implementación concreta con Firebase
export 'src/firebase_user_repo.dart';

//
