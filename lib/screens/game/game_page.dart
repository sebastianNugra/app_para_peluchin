import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data_service.dart'; // Comunicación Bluetooth

class GamePage extends StatefulWidget {
  final dynamic category; // Recibe la categoría desde HomeScreen

  const GamePage({Key? key, required this.category}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<Map<String, dynamic>> _students = [];
  bool _isLoadingStudents = false;
  String? _selectedStudentId;
  String? _selectedStudentName;
  StreamSubscription<String>? _uidSubscription;

  // Obtenemos el UID del usuario actual
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Estado del juego
  bool _waitingForCard = false;
  String _expectedValue = "";
  Color _statusColor = Colors.transparent;
  String _statusMessage = "";

  // Mapa de opciones según la categoría
  final Map<String, List<String>> categoryOptions = {
    'NÚMEROS': ['UNO', 'DOS', 'TRES'],
    'ANIMALES': ['OSO', 'PERRO', 'GATO'],
    'COLORES': ['VERDE', 'ROJO', 'AZUL'],
  };

  // Mapa de comandos para cada opción
  final Map<String, String> commandMap = {
    'VERDE': 'S3',
    'ROJO': 'S4',
    'AZUL': 'S5',
    'GATO': 'S6',
    'OSO': 'S7',
    'PERRO': 'S8',
    'UNO': 'S9',
    'DOS': 'S10',
    'TRES': 'S11',
  };

  @override
  void initState() {
    super.initState();
    _loadStudents();
    // Suscribirse al stream de UIDs del Bluetooth
    _uidSubscription = dataService.uidStream.listen(_onUidReceived);
  }

  @override
  void dispose() {
    _uidSubscription?.cancel();
    super.dispose();
  }

  /// Carga los estudiantes vinculados al curso
  Future<void> _loadStudents() async {
    setState(() {
      _isLoadingStudents = true;
    });

    try {
      String courseId = widget.category.courseId;

      final studentsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc(courseId)
          .collection('students')
          .get();

      final students = studentsSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'firstName': doc['firstName'] ?? 'Sin nombre',
          'lastName': doc['lastName'] ?? '',
          'age': doc['age'] ?? 0,
          'aciertos': doc['aciertos'] ?? 0,
          'errores': doc['errores'] ?? 0,
        };
      }).toList();

      setState(() {
        _students = students;
        _isLoadingStudents = false;
      });

      print('✅ Estudiantes cargados: ${_students.length}');
    } catch (e) {
      print('❌ Error cargando estudiantes: $e');
      setState(() {
        _isLoadingStudents = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar estudiantes: $e')),
        );
      }
    }
  }

  /// Muestra el diálogo para seleccionar un estudiante
  void _showStudentSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecciona un estudiante'),
        content: _isLoadingStudents
            ? const Center(child: CircularProgressIndicator())
            : _students.isEmpty
            ? const Text('No hay estudiantes vinculados a este curso')
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_students.length, (index) {
                    final student = _students[index];
                    final studentName =
                        "${student['firstName']} ${student['lastName']}";
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color.fromARGB(255, 7, 76, 133),
                        child: Text(
                          student['firstName'].isNotEmpty
                              ? student['firstName'][0]
                              : "?",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(studentName),
                      subtitle: Text("Edad: ${student['age']} años"),
                      onTap: () {
                        setState(() {
                          _selectedStudentId = student['id'];
                          _selectedStudentName = studentName;
                        });
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Estudiante seleccionado: $studentName',
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  /// Obtiene las opciones para la categoría actual
  List<String> _getOptionsForCategory() {
    for (var key in categoryOptions.keys) {
      if (widget.category.name.toUpperCase().contains(key) ||
          key.contains(widget.category.name.toUpperCase())) {
        return categoryOptions[key] ?? [];
      }
    }
    return [];
  }

  /// Cuando se toca un cuadrito, envía la señal al ESP32
  void _onOptionTapped(String option) {
    // Verificar que hay estudiante seleccionado
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Debes seleccionar un estudiante primero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Verificar que hay conexión Bluetooth
    if (!dataService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ No hay conexión con Peluchín'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Obtener el comando para esta opción
    String? command = commandMap[option];
    if (command == null) {
      print('❌ Comando no encontrado para: $option');
      return;
    }

    // Enviar comando al ESP32
    dataService.sendMessage(command);
    print('📤 Enviando comando: $command para opción: $option');

    // Cambiar estado a esperando tarjeta
    setState(() {
      _waitingForCard = true;
      _expectedValue = option;
      _statusColor = Colors.indigo;
      _statusMessage = 'Esperando tarjeta NFC...';
    });
  }

  /// Cuando se recibe un UID del Bluetooth
  void _onUidReceived(String uid) {
    if (!_waitingForCard) return;

    print('📥 UID recibido: $uid, Esperado para: $_expectedValue');

    // Validar la respuesta
    bool isCorrect = dataService.logGameResult(uid, _expectedValue);

    setState(() {
      _waitingForCard = false;
      if (isCorrect) {
        _statusColor = Colors.green;
        _statusMessage = '✅ ¡Correcto!';
        dataService.sendMessage("OK");
      } else {
        _statusColor = Colors.red;
        _statusMessage = '❌ Incorrecto';
        dataService.sendMessage("ERR");
      }
    });

    // Resetear después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _statusColor = Colors.transparent;
          _statusMessage = '';
          _expectedValue = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final options = _getOptionsForCategory();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: const Color.fromARGB(255, 7, 76, 133),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Título de la categoría
            Text(
              widget.category.name,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Mostrar estudiante seleccionado
            if (_selectedStudentName != null)
              Column(
                children: [
                  const Text(
                    'Estudiante:',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    _selectedStudentName!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 7, 76, 133),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              )
            else
              Column(
                children: [
                  const Text(
                    'Ningún estudiante seleccionado',
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Botón para seleccionar estudiante
            ElevatedButton(
              onPressed: _showStudentSelectionDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 7, 76, 133),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Selecciona un estudiante',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Mostrar estado del juego si está esperando
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Icon(
                      _statusColor == Colors.green
                          ? Icons.check_circle
                          : _statusColor == Colors.red
                          ? Icons.cancel
                          : Icons.nfc,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            // Cuadro "Seleccione una opción"
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color.fromARGB(255, 7, 76, 133),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Seleccione una opción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 7, 76, 133),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Los 3 cuadritos con opciones
                  if (options.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(options.length, (index) {
                        return _buildOptionBox(options[index]);
                      }),
                    )
                  else
                    const Text(
                      'No hay opciones disponibles',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un cuadrito de opción
  Widget _buildOptionBox(String option) {
    return GestureDetector(
      onTap: _waitingForCard ? null : () => _onOptionTapped(option),
      child: Opacity(
        opacity: _waitingForCard ? 0.5 : 1.0,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 245, 245, 245),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color.fromARGB(255, 7, 76, 133),
              width: 2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Text(
                option,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 7, 76, 133),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
