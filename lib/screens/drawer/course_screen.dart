import 'package:app_peluche/screens/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // [cite: 4]
import 'package:firebase_auth/firebase_auth.dart'; // [cite: 6]
import 'models.dart';
import 'student_screen.dart';

class CourseListScreen extends StatefulWidget {
  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  // Ya no necesitamos la lista local 'courses' porque usaremos StreamBuilder

  // Obtenemos el ID del usuario actual de Firebase
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? ''; // [cite: 6]

  // Función para guardar el curso en Firebase
  Future<void> _addCourseToFirebase(String name) async {
    //
    try {
      await FirebaseFirestore
          .instance // [cite: 4]
          .collection('users')
          .doc(uid)
          .collection('courses')
          .add({'name': name, 'createdAt': DateTime.now()});
    } catch (e) {
      print("Error al guardar: $e");
    }
  }

  void _showAddCourseDialog() {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Nuevo Curso/Grado"),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: "Ej: terapia de lenguaje"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                _addCourseToFirebase(_controller.text); // Llamamos a Firebase
                Navigator.pop(context);
              }
            },
            child: Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
        title: Text(
          "Mis Cursos",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      // CAMBIO PRINCIPAL: Usamos StreamBuilder para leer de Firebase
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore
            .instance // [cite: 4]
            .collection('users')
            .doc(uid)
            .collection('courses')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error al cargar"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No hay cursos. Agrega uno abajo."));
          }

          return ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var course = Course(
                id: doc.id, // Es importante pasar el ID de Firebase
                name: doc['name'],
              );
              return _buildCourseCard(course);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF7C83FD),
        onPressed: _showAddCourseDialog,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentListScreen(course: course),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFE0E7FF),
              child: Icon(Icons.class_, color: Color(0xFF7C83FD)),
            ),
            SizedBox(width: 20),
            Text(
              course.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
