import 'package:flutter/material.dart';

// este apartado mostramos las categorias de aprendizaje que son:
// 1. Numeros de 1 al 20
// 2. Letras del abecedario y vocales
// 3. Colores
// 4. Figuras geometricas
// 5. Frutas
// 6. Animales

class DividerScreen extends StatelessWidget {
  const DividerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorSchemeSeed: const Color(0xFF7C83FD)),
      home: Scaffold(
        appBar: AppBar(title: const Text('Categorias de Aprendizaje')),
        body: const Divider(),
      ),
    );
  }
}

class Dividers extends StatelessWidget {
  const Dividers({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Card(
                child: SizedBox.expand(child: Text('Numeros de 1 al 20')),
              ),
            ),
            Divider(),
            Expanded(
              child: Card(
                child: SizedBox.expand(
                  child: Text('Letras del abecedario y vocales'),
                ),
              ),
            ),
            Divider(),
            Expanded(
              child: Card(child: SizedBox.expand(child: Text('Colores'))),
            ),
            Divider(),
            Expanded(
              child: Card(
                child: SizedBox.expand(child: Text('Figuras geometricas')),
              ),
            ),
            Divider(),
            Expanded(
              child: Card(child: SizedBox.expand(child: Text('Frutas'))),
            ),
            Divider(),
            Expanded(
              child: Card(child: SizedBox.expand(child: Text('Animales'))),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
