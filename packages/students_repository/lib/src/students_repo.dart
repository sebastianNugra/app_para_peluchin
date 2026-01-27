import 'models/models.dart';

abstract class StudentRepository {
  // Stream que expone la lista de estudiantes (se actualiza en tiempo real)
  Stream<List<Student>> getStudentsByCourse(String courseId);

  // Agrega un nuevo estudiante a la base de datos
  Future<void> addStudent(Student student);

  // Actualiza la información de un estudiante existente
  Future<void> updateStudent(Student student);

  // Elimina un estudiante mediante su ID
  Future<void> deleteStudent(String studentId, String courseId);

  // Busca un estudiante específico por su ID
  Future<Student?> getStudentById(String studentId, String courseId);
}
