import 'package:flutter/material.dart';

// Componente reutilizable de campo de texto
// Centraliza estilo, validación y comportamiento para toda la app
class MyTextField extends StatelessWidget {
  // Controlador que permite leer y modificar el texto desde fuera
  final TextEditingController controller;

  // Texto guía mostrado cuando el campo está vacío
  final String hintText;

  // Define si el texto se oculta (password)
  final bool obscureText;

  // Tipo de teclado (email, texto, número, password, etc.)
  final TextInputType keyboardType;

  // Icono opcional al final (ej: mostrar/ocultar contraseña)
  final Widget? suffixIcon;

  // Callback opcional cuando el campo recibe tap
  final VoidCallback? onTap;

  // Icono opcional al inicio (email, lock, user, etc.)
  final Widget? prefixIcon;

  // Función de validación usada por Form
  final String? Function(String?)? validator;

  // Permite controlar el foco desde fuera (UX avanzada)
  final FocusNode? focusNode;

  // Mensaje de error externo (por ejemplo, error del backend)
  final String? errorMsg;

  // Callback cuando el texto cambia (no validación)
  final String? Function(String?)? onChanged;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.keyboardType,
    this.suffixIcon,
    this.onTap,
    this.prefixIcon,
    this.validator,
    this.focusNode,
    this.errorMsg,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // Validación del formulario (frontend)
      validator: validator,

      // Controlador del texto
      controller: controller,

      // Oculta el texto si es necesario
      obscureText: obscureText,

      // Tipo de teclado adecuado al input
      keyboardType: keyboardType,

      // Control manual del foco
      focusNode: focusNode,

      // Acción al tocar el campo
      onTap: onTap,

      // Al presionar "enter", pasa al siguiente campo
      textInputAction: TextInputAction.next,

      // Listener de cambios de texto
      onChanged: onChanged,

      // Configuración visual del input
      decoration: InputDecoration(
        // Icono final (ej: ojo de contraseña)
        suffixIcon: suffixIcon,

        // Icono inicial
        prefixIcon: prefixIcon,

        // Borde cuando NO está enfocado
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.transparent),
        ),

        // Borde cuando SÍ está enfocado
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),

        // Color de fondo del campo
        fillColor: Colors.grey.shade200,
        filled: true,

        // Texto placeholder
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),

        // Error externo (por ejemplo login fallido)
        errorText: errorMsg,
      ),
    );
  }
}
