import 'package:app_peluche/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Pantalla inicial de login / bienvenida
class LogPage extends StatelessWidget {
  const LogPage({super.key});

  /// Navega a la pantalla en blanco para crear usuario sin email
  Future<void> _continueToBlankScreen(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BlankScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Color de fondo cálido de bienvenida
      backgroundColor: const Color.fromARGB(255, 248, 241, 220),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ---------- LOGO ----------
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : const Color.fromARGB(255, 247, 233, 190),
                child: Image.asset(
                  // Se mantiene el mismo asset para ambos modos
                  Theme.of(context).brightness == Brightness.dark
                      ? 'assets/images/pelu_img.png'
                      : 'assets/images/pelu_img.png',
                  width: 60,
                ),
              ),

              const SizedBox(height: 30),

              // ---------- TEXTO PRINCIPAL ----------
              Text(
                'Welcome to the App for Peluchin',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // Subtítulo
              Text(
                'Where fun meets learning...',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color.fromARGB(255, 46, 46, 46),
                ),
              ),

              const SizedBox(height: 40),

              // Texto introductorio
              Text(
                "Let's Get Started...",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              // ---------- BOTÓN GOOGLE ----------
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.black, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                // Icono de Google
                icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),

                // Texto del botón
                label: Text(
                  'Continue with Google',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),

                // Navega a la pantalla de Sign In / Sign Up
                onPressed: () {
                  context.read<AuthenticationBloc>().add(const GoToWelcome());
                },
              ),

              const SizedBox(height: 15),

              // ---------- BOTÓN SIN EMAIL ----------
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color.fromARGB(255, 243, 243, 243),
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.black, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                // Navega a la creación de username
                onPressed: () async {
                  await _continueToBlankScreen(context);
                },

                child: Text(
                  'Continue without email',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------- PANTALLA PARA CREAR USERNAME ----------
class BlankScreen extends StatefulWidget {
  const BlankScreen({super.key});

  @override
  State<BlankScreen> createState() => _BlankScreenState();
}

class _BlankScreenState extends State<BlankScreen> {
  // Controlador del campo username
  final usernameController = TextEditingController();

  // Llave para validaciones futuras
  final _formKey = GlobalKey<FormState>();

  // Valor actual del username
  String username = '';

  @override
  void dispose() {
    // Liberación del controlador
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      // AppBar simple
      appBar: AppBar(
        title: Text(
          'Create Username',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título
                Text(
                  'Choose your username',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 30),

                // ---------- CAMPO USERNAME ----------
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TextField(
                    controller: usernameController,

                    // Actualiza el estado en tiempo real
                    onChanged: (val) {
                      setState(() {
                        username = val;
                      });
                    },

                    decoration: InputDecoration(
                      hintText: 'Username',
                      prefixIcon: const Icon(CupertinoIcons.person_fill),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ---------- CONTENEDOR DE REQUISITOS ----------
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título de requisitos
                      Text(
                        'Requisitos:',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 10),

                      // Requisito mínimo
                      _RequirementRow(
                        text: 'Mínimo 3 caracteres',
                        isMet: username.length >= 3,
                      ),

                      const SizedBox(height: 8),

                      // Requisito máximo
                      _RequirementRow(
                        text: 'Máximo 20 caracteres',
                        isMet: username.length <= 20 && username.isNotEmpty,
                      ),

                      const SizedBox(height: 8),

                      // Requisito de caracteres válidos
                      _RequirementRow(
                        text: 'Solo letras, números, _ y -',
                        isMet:
                            username.isEmpty ||
                            RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(username),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ---------- BOTÓN CREAR USUARIO ----------
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: TextButton(
                    // Solo se habilita si cumple todos los requisitos
                    onPressed:
                        username.length >= 3 &&
                            username.length <= 20 &&
                            RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(username)
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Welcome, $username!')),
                              );
                            }
                          }
                        : null,

                    // Estilo dinámico según validez
                    style: TextButton.styleFrom(
                      elevation: 3.0,
                      backgroundColor:
                          username.length >= 3 &&
                              username.length <= 20 &&
                              RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(username)
                          ? const Color.fromARGB(255, 42, 179, 189)
                          : Colors.grey[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),

                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 5,
                      ),
                      child: Text(
                        'Create User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // efecto borroso (placeholder visual)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------- WIDGET DE FILA DE REQUISITO ----------
class _RequirementRow extends StatelessWidget {
  final String text;
  final bool isMet;

  const _RequirementRow({required this.text, required this.isMet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icono cambia según se cumpla o no
        Icon(
          isMet ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
          color: isMet ? const Color.fromARGB(255, 27, 128, 7) : Colors.grey,
          size: 18,
        ),

        const SizedBox(width: 8),

        // Texto del requisito
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isMet ? const Color.fromARGB(255, 27, 128, 7) : Colors.grey,
          ),
        ),
      ],
    );
  }
}
