import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? imagen;
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  /// CARGA DATOS GUARDADOS
  Future<void> cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final path = prefs.getString('imagenPerfil');
      if (path != null) imagen = File(path);
      nombreController.text = prefs.getString('nombre') ?? '';
      correoController.text = prefs.getString('correo') ?? '';
    });
  }

  /// SELECCIONAR IMAGEN DE GALERÍA
  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imagen = File(picked.path);
      });
    }
  }

  /// GUARDAR DATOS
  Future<void> guardar() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    // 1. ACTUALIZAR EN FIREBASE (Para que el FutureBuilder lo vea)
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'name': nombreController.text,
      // 'email': correoController.text,
    });

    // 2. ACTUALIZAR EN LOCAL (Opcional, pero bueno para consistencia)
    final prefs = await SharedPreferences.getInstance();
    if (imagen != null) {
      await prefs.setString('imagenPerfil', imagen!.path);
    }
    await prefs.setString('nombre', nombreController.text);

    Navigator.pop(context); // Regresa al Drawer
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar en la nube: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: seleccionarImagen,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: imagen != null ? FileImage(imagen!) : null,
                child: imagen == null
                    ? const Icon(Icons.camera_alt, size: 30)
                    : null,
              ),
            ),
            const SizedBox(height: 12), // espacio entre imagen y texto

            Text(
              'Cambiar foto de perfil',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),

            TextField(
              controller: correoController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: guardar,
              child: const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
