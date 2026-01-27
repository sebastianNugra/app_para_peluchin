import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //
import 'package:firebase_auth/firebase_auth.dart'; // [cite: 1, 6]
import 'models.dart';

class StudentListScreen extends StatefulWidget {
  final Course course;
  StudentListScreen({required this.course});

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  // Obtenemos el ID del usuario actual de Firebase [cite: 6]
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Función para guardar automáticamente en la ruta correcta de Firebase
  Future<void> _addStudentToFirebase(String name, String last, int age) async {
    // Obtenemos el usuario de Firebase Auth
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || widget.course.id.isEmpty) return;

    try {
      // Ruta: users/{uid}/courses/{courseId}/students/
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc(widget.course.id) // Usamos el ID automático del curso
          .collection('students')
          .add({
            'firstName': name,
            'lastName': last,
            'age': age,
            'aciertos': 0, // Iniciamos estadísticas automáticas
            'errores': 0,
            'course': widget.course.id,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint("Error al guardar estudiante: $e");
    }
  }

  void _showAddStudentDialog() {
    TextEditingController _nameCtrl = TextEditingController();
    TextEditingController _lastCtrl = TextEditingController();
    TextEditingController _ageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Nuevo Estudiante"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: _lastCtrl,
              decoration: const InputDecoration(labelText: "Apellido"),
            ),
            TextField(
              controller: _ageCtrl,
              decoration: const InputDecoration(labelText: "Edad"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameCtrl.text.isNotEmpty) {
                _addStudentToFirebase(
                  _nameCtrl.text,
                  _lastCtrl.text,
                  int.tryParse(_ageCtrl.text) ?? 0,
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
          widget.course.name,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      // CAMBIO CLAVE: Usamos StreamBuilder para leer de Firebase en tiempo real
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('courses')
            .doc(widget.course.id)
            .collection('students')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text("Error al cargar datos"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No hay estudiantes en este curso."),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              // Convertimos el documento de Firebase a nuestro modelo Student
              final student = Student(
                firstName: doc['firstName'] ?? '',
                lastName: doc['lastName'] ?? '',
                age: doc['age'] ?? 0,
                id: doc.id,
                aciertos: doc['aciertos'] ?? 0,
                errores: doc['errores'] ?? 0,
              );
              return _buildStudentCard(student);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: _showAddStudentDialog,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF7C83FD),
          child: Text(
            student.firstName.isNotEmpty ? student.firstName[0] : "?",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          "${student.firstName} ${student.lastName}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Edad: ${student.age} años"),
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  "Aciertos",
                  "${student.aciertos}",
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatItem(
                  "Errores",
                  "${student.errores}",
                  Icons.cancel,
                  Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
