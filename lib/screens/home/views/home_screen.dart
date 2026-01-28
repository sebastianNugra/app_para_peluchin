import 'package:app_peluche/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:app_peluche/screens/drawer/course_screen.dart';
import 'package:app_peluche/screens/game/game_page.dart';
import 'package:app_peluche/screens/home/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:app_peluche/screens/home/views/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../drawer/settings_page.dart';

class Course {
  final String id;
  final String name;

  Course({required this.id, required this.name});
}

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCourseId; // Guarda el ID del curso seleccionado

  void _showCoursesFilter() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Filtrar por curso',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('courses')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error al cargar cursos"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No hay cursos guardados"));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var courseId = doc.id;
                      var courseName = doc['name'];

                      return ListTile(
                        title: Text(courseName),
                        trailing: Icon(Icons.check_circle_outline),
                        onTap: () {
                          // Guardar el ID del curso seleccionado
                          setState(() {
                            selectedCourseId = courseId;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                color: const Color.fromARGB(255, 233, 219, 151),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
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
                            color: const Color.fromARGB(255, 27, 27, 27),
                          ),
                        );
                      }

                      return Text(
                        snapshot.data!, // ← AQUÍ APARECE "sebilon1"
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 27, 27, 27),
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
                Navigator.push(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsPage()),
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
        backgroundColor: const Color.fromARGB(255, 255, 254, 249),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            /// TEXTO
            FutureBuilder<String>(
              future: obtenerNombreUsuario(),
              builder: (context, snapshot) {
                final nombre = snapshot.data ?? 'Usuario';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Bienvenido',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 73, 77, 82),
                      ),
                    ),
                  ],
                );
              },
            ),

            /// AVATAR A LA DERECHA
            const SizedBox(width: 12),
            const CircleAvatar(
              radius: 26,
              backgroundImage: AssetImage('assets/images/pelu.png'),
            ),
          ],
        ),
      ),

      /// CUERPO (GRID)
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            /// BOTONES FILTRAR CURSO Y MOSTRAR TODOS
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 12.0,
                bottom: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// BOTÓN FILTRAR CURSO
                  ElevatedButton(
                    onPressed: () {
                      _showCoursesFilter();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 7, 76, 133),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Filtrar Curso',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  /// BOTÓN MOSTRAR TODOS
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCourseId = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
                      side: BorderSide(
                        color: const Color.fromARGB(255, 7, 76, 133),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Mostrar todos',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 7, 76, 133),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// GRID DE CATEGORÍAS
            Expanded(
              child: BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
                builder: (context, state) {
                  if (state is GetCategoriesSuccess) {
                    // Filtrar categorías por curso si hay uno seleccionado
                    var categoriasAMostrar = state.category;

                    if (selectedCourseId != null) {
                      categoriasAMostrar = state.category
                          .where((cat) => cat.courseId == selectedCourseId)
                          .toList();

                      if (categoriasAMostrar.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'No hay categorías para este curso',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedCourseId = null;
                                  });
                                },
                                child: const Text('Limpiar filtro'),
                              ),
                            ],
                          ),
                        );
                      }
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 9 / 12.6,
                          ),
                      itemCount: categoriasAMostrar.length,
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
                                      DetailsScreen(categoriasAMostrar[i]),
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
                                      categoriasAMostrar[i].picture,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: Row(children: [
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 12.0,
                                  ),
                                  child: Text(
                                    categoriasAMostrar[i].name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: Text(
                                    categoriasAMostrar[i].description,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ),
                                //boton get sateted
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                GamePage(
                                                  category:
                                                      categoriasAMostrar[i], // ← Pasa la categoría aquí
                                                ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          7,
                                          76,
                                          133,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
          ],
        ),
      ),
    );
  }
}
