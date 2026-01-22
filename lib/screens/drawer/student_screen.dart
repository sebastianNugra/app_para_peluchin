import 'package:flutter/material.dart';
import 'models.dart';

class StudentListScreen extends StatefulWidget {
  final Course course;
  StudentListScreen({required this.course});

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  Color? get color => null;

  void _showAddStudentDialog() {
    TextEditingController _nameCtrl = TextEditingController();
    TextEditingController _lastCtrl = TextEditingController();
    TextEditingController _ageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Agregar Estudiante"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: _lastCtrl,
              decoration: InputDecoration(labelText: "Apellido"),
            ),
            TextField(
              controller: _ageCtrl,
              decoration: InputDecoration(labelText: "Edad"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.course.students.add(
                  Student(
                    firstName: _nameCtrl.text,
                    lastName: _lastCtrl.text,
                    age: int.tryParse(_ageCtrl.text) ?? 0,
                  ),
                );
              });
              Navigator.pop(context);
            },
            child: Text("Agregar"),
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
        title: Text(widget.course.name, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: widget.course.students.length,
        itemBuilder: (context, index) {
          final student = widget.course.students[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            // ... dentro del ListView.builder en student_screen.dart
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              leading: CircleAvatar(
                backgroundColor: Color(0xFF7C83FD),
                child: Text(
                  student.firstName[0],
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                "${student.firstName} ${student.lastName}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Edad: ${student.age} años"),
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Divider(),
                      Text(
                        "DATOS EN TIEMPO REAL",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Usamos las nuevas variables: aciertos y errores
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
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: _showAddStudentDialog,
        child: Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    MaterialColor red,
  ) {
    return Column(
      children: [
        Icon(icon, color: color),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
