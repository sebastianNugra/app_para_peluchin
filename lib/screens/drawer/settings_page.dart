import 'package:app_peluche/screens/drawer/EditProfilePage.dart';
import 'package:app_peluche/screens/home/views/home_screen.dart';
import 'package:flutter/material.dart';

/// PANTALLA DE SETTINGS
/// Esta clase representa la pantalla que se abre
/// cuando tocas "Settings" en el Drawer
class SettingsPage extends StatefulWidget {
  final String nombreActual;
  final Function(String, String?) onGuardar;

  const SettingsPage({
    super.key,
    required this.nombreActual,
    required this.onGuardar,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'General',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          /// CONTENIDO
          ListTile(
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );

              //  AQUÍ SÍ EXISTE widget
              if (result != null) {
                widget.onGuardar(result['nombre'], result['imagen']);
              }
            },
          ),
          // ====== SECCIÓN GENERAL ======
          ListTile(
            title: Text('Change Language'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),

          ListTile(
            title: Text('Aspect'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),

          const Divider(),

          // ====== SECCIÓN TÉRMINOS ======
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Terms and supports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          ListTile(
            title: Text('Terms and conditions'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),

          ListTile(
            title: Text('Privacy policy'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),

          ListTile(
            title: Text('Support'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
