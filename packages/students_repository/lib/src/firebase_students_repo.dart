import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:students_repository/students_repository.dart';

class FirebaseStudentRepo implements StudentRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseStudentRepo({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Getter privado para obtener el UID del usuario logueado
  String get _currentUserId {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception("No hay usuario autenticado");
    return user.uid;
  }

  // 1. Obtener estudiantes de un curso específico en tiempo real
  @override
  Stream<List<Student>> getStudentsByCourse(String courseId) {
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('courses')
        .doc(courseId)
        .collection('students')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // Convierte el mapa de Firestore a la Entidad y luego al Modelo Student
            return Student.fromEntity(
              MyStudentsEntity.fromDocument(doc.data()),
            );
          }).toList();
        });
  }

  // 2. Agregar un estudiante (usa el campo 'course' del modelo para saber la ruta)
  @override
  Future<void> addStudent(Student student) async {
    try {
      // Si el estudiante no tiene ID, Firestore creará uno nuevo automáticamente
      final docRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('courses')
          .doc(student.course)
          .collection('students')
          .doc(student.id.isEmpty ? null : student.id);

      // Si era un documento nuevo, guardamos el ID generado de vuelta en el objeto
      if (student.id.isEmpty) student.id = docRef.id;

      await docRef.set(student.toEntity().toDocument());
    } catch (e) {
      log("Error en addStudent: ${e.toString()}");
      rethrow;
    }
  }

  // 3. Actualizar (en Firestore, set con datos nuevos funciona como update)
  @override
  Future<void> updateStudent(Student student) async {
    return addStudent(student);
  }

  // 4. Eliminar un estudiante específico
  @override
  Future<void> deleteStudent(String studentId, String courseId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('courses')
          .doc(courseId)
          .collection('students')
          .doc(studentId)
          .delete();
    } catch (e) {
      log("Error en deleteStudent: ${e.toString()}");
      rethrow;
    }
  }

  // 5. Obtener un solo estudiante por su ID
  @override
  Future<Student?> getStudentById(String studentId, String courseId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('courses')
          .doc(courseId)
          .collection('students')
          .doc(studentId)
          .get();

      if (doc.exists && doc.data() != null) {
        return Student.fromEntity(MyStudentsEntity.fromDocument(doc.data()!));
      }
      return null;
    } catch (e) {
      log("Error en getStudentById: ${e.toString()}");
      return null;
    }
  }
}
