// Permite imprimir logs para depuración
import 'dart:developer';

// Firebase Auth: autenticación de usuarios
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// RxDart: operadores avanzados para Streams
import 'package:rxdart/rxdart.dart';

// Entidades y modelos del dominio
import 'package:user_repository/src/entities/entities.dart';
import 'package:user_repository/src/models/user.dart';

// Contrato (interfaz) del repositorio de usuarios
import 'package:user_repository/src/user_repo.dart';

// Implementación del repositorio usando Firebase
class FirebaseUserRepo implements UserRepository {
  // Maneja autenticación con Firebase
  final FirebaseAuth _firebaseAuth;

  // Referencia a la colección "users" en Firestore
  final usersCollection = FirebaseFirestore.instance.collection('users');

  // Inyecta FirebaseAuth o usa la instancia por defecto
  FirebaseUserRepo({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Stream que emite el usuario actual (logueado o vacío)
  @override
  Stream<MyUser?> get user {
    return _firebaseAuth.authStateChanges().flatMap((firebaseUser) async* {
      // Si no hay sesión activa
      if (firebaseUser == null) {
        yield MyUser.empty;

        // Si el usuario está autenticado
      } else {
        yield await usersCollection
            .doc(firebaseUser.uid)
            .get()
            .then(
              (value) =>
                  MyUser.fromEntity(MyUserEntity.fromDocument(value.data()!)),
            );
      }
    });
  }

  // Inicia sesión con email y contraseña
  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // Registra un usuario en Firebase Auth
  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: myUser.email,
        password: password,
      );

      // Asigna el UID generado por Firebase al modelo
      myUser.userId = user.user!.uid;
      return myUser;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // Cierra sesión del usuario
  @override
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  // Guarda los datos del usuario en Firestore
  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      await usersCollection
          .doc(myUser.userId)
          .set(myUser.toentity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
