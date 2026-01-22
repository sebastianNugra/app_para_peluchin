import 'package:app_peluche/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:app_peluche/screens/drawer/course_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../drawer/settings_page.dart';

Future<String> obtenerNombreUsuario() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

  if (!doc.exists) {
    return 'Usuario';
  }

  return doc['name'];
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      /// DRAWER (MENÚ LATERAL)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            /// CABECERA
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage('assets/images/pelu.png'),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<String>(
                    future: obtenerNombreUsuario(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(strokeWidth: 2);
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return Text(
                          'Usuario',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        );
                      }

                      return Text(
                        snapshot.data!, // ← AQUÍ APARECE "sebilon1"
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            /// OPCIONES
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Cursos'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => CourseListScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.stacked_line_chart),
              title: const Text('Informes'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),

            const Divider(),

            /// CERRAR SESIÓN
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                context.read<SignInBloc>().add(SignOutRequired());
              },
            ),
          ],
        ),
      ),

      /// APPBAR
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            Image.asset('assets/images/pelu_img.png', scale: 10),
            const SizedBox(width: 8),
            const Text(
              'Peluchin',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
            ),
          ],
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       context.read<SignInBloc>().add(SignOutRequired());
        //     },
        //     icon: const Icon(CupertinoIcons.arrow_right_to_line),
        //   ),
        // ],
      ),

      /// CUERPO (GRID)
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
