import 'dart:io';
import 'package:app_peluche/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:app_peluche/screens/drawer/EditProfilePage.dart';
import 'package:app_peluche/screens/drawer/course_screen.dart';
import 'package:app_peluche/screens/home/views/ThemeProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // <--- NUEVO IMPORT
import '../../drawer/settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ... (ThemeProvider clase aquí arriba)

Future<String> obtenerNombreUsuario() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();
  return doc.exists ? doc['name'] : 'Usuario';
}

void main() async {
  // Añadido async
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    // Envolvemos la app con el proveedor de tema
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // Ahora puede ser Stateless
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el cambio de tema aquí
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.modoOscuro ? ThemeMode.dark : ThemeMode.light,
      home: const MyHomePage(
        title: 'App Peluchín',
      ), // Ya no pasamos parámetros de tema
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  // Eliminamos modoOscuro y onThemeChanged del constructor
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String nombreUsuario = 'Usuario';
  String? imagenPerfil;

  @override
  void initState() {
    super.initState();
    cargarPerfil();
  }

  Future<void> cargarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nombreUsuario = prefs.getString('nombre') ?? 'Usuario';
      imagenPerfil = prefs.getString('imagenPerfil');
    });
  }

  void actualizarPerfil(String nuevoNombre, String? nuevaImagen) {
    setState(() {
      nombreUsuario = nuevoNombre;
      imagenPerfil = nuevaImagen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Accedemos al tema desde cualquier parte del build

    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().modoOscuro ? Colors.black : const Color(0xFFF5F5F0),
      appBar: AppBar(
        title: Text(
          'Inicio',
          style: TextStyle(color: context.watch<ThemeProvider>().modoOscuro ? Colors.white : Colors.black),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: context.watch<ThemeProvider>().modoOscuro ? Colors.grey[900] : const Color(0xFFE3F2FD),
              ),
              
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 41,
                    backgroundImage: imagenPerfil != null
                        ? FileImage(File(imagenPerfil!))
                        : const AssetImage('assets/images/pelu.png')
                              as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: obtenerNombreUsuario(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(strokeWidth: 2);
                      }
                      return Text(
                        snapshot.data ?? 'Usuario',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Menu Principal'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Cursos'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.stacked_line_chart),
              title: const Text('Informes estadisticos'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
                setState(() {
                  // Esto dispara el build y el FutureBuilder vuelve a consultar Firebase
                  cargarPerfil();
                });
              },
            ),

            // EL SWITCH AHORA ES MUCHO MÁS LIMPIO
            SwitchListTile(
              secondary: Icon(context.watch<ThemeProvider>().modoOscuro ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Modo oscuro'),
              value: context.watch<ThemeProvider>().modoOscuro,
              onChanged: (value) {
                // Llamamos al método del proveedor directamente
                context.read<ThemeProvider>().setModoOscuro(value);
              },
            ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesion'),
              onTap: () {
                Navigator.pop(context);
                context.read<SignInBloc>().add(SignOutRequired());
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 9 / 12,
          ),
          itemCount: 4,
          itemBuilder: (context, int i) {
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 4,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
