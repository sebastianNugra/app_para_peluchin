import 'package:app_peluche/screens/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'student_screen.dart';

class CourseListScreen extends StatefulWidget {
  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  List<Course> courses = [];

  void _addCourse(String name) {
    setState(() {
      courses.add(Course(name: name));
    });
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
                _addCourse(_controller.text);
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
        backgroundColor: Colors.transparent, // Mantiene el fondo limpio
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MyHomePage(
                  title: 'App Peluchín',
           
                ),),
            );
          },
        ),
        title: Text(
          "Mis Cursos",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: courses.isEmpty
          ? Center(child: Text("No hay cursos. Agrega uno abajo."))
          : ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: courses.length,
              itemBuilder: (context, index) => _buildCourseCard(courses[index]),
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
              color: Colors.black.withAlpha(128),
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
