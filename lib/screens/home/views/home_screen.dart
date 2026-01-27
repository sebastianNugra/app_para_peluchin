import 'package:app_peluche/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:app_peluche/screens/drawer/course_screen.dart';
import 'package:app_peluche/screens/home/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:app_peluche/screens/home/views/details_screen.dart';
import 'package:flutter/cupertino.dart';
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
      backgroundColor: const Color.fromARGB(255, 255, 254, 249),

      /// DRAWER (MENÚ LATERAL)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            /// CABECERA
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 197, 183, 112),
              ),
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
        backgroundColor: const Color.fromARGB(255, 245, 245, 245),
        title: Row(
          children: [
            Image.asset('assets/images/pelu_img.png', scale: 10),
            const SizedBox(width: 8),
            const Text(
              'Bienvenido',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
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
        child: BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
          builder: (context, state) {
            if (state is GetCategoriesSuccess) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 9 / 12.6,
                ),
                itemCount: state.category.length,
                itemBuilder: (context, int i) {
                  return Material(
                    elevation: 3,
                    color: const Color.fromARGB(255, 245, 245, 245),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        //Aqui van los detalles
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const DetailsScreen(),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: AspectRatio(
                              aspectRatio:
                                  16 / 14, // MISMA proporción para todas
                              child: Image.network(
                                state.category[i].picture,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Row(
                              children: [
                                // Container(
                                //   decoration: BoxDecoration(
                                //     color: Colors.amber,
                                //     borderRadius: BorderRadius.circular(30),
                                //   ),
                                //   child: const Padding(
                                //     padding: EdgeInsets.symmetric(
                                //       vertical: 4,
                                //       horizontal: 8,
                                //     ),
                                //     child: Text(
                                //       "BOTON UNO",
                                //       style: TextStyle(
                                //         color: Colors.white,
                                //         fontWeight: FontWeight.bold,
                                //         fontSize: 10,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                // SizedBox(width: 8,),
                                // //segundo container
                                // Container(
                                //   decoration: BoxDecoration(
                                //     color: const Color.fromARGB(255, 12, 122, 45),
                                //     borderRadius: BorderRadius.circular(30),
                                //   ),
                                //   child: const Padding(
                                //     padding: EdgeInsets.symmetric(
                                //       vertical: 4,
                                //       horizontal: 8,
                                //     ),
                                //     child: Text(
                                //       "BOTON DOS",
                                //       style: TextStyle(
                                //         color: Colors.white,
                                //         fontWeight: FontWeight.bold,
                                //         fontSize: 10,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 12.0
                            ),
                            child: Text(
                              state.category[i].name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              state.category[i].description,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                          //boton get saterted
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22.0,
                              vertical: 4,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 35,
                              child: ElevatedButton(
                                onPressed: () {
                                  // acción aquí
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    7,
                                    76,
                                    133,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'Comenzar',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is GetCategoriesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GetCategoriesFailure) {
              return Center(
                child: Text(
                  state.error,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
