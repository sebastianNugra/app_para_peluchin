import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _modoOscuro = false;
  bool get modoOscuro => _modoOscuro;

  ThemeProvider() {
    cargarTema();
  }

  Future<void> cargarTema() async {
    final prefs = await SharedPreferences.getInstance();
    _modoOscuro = prefs.getBool('modoOscuro') ?? false;
    notifyListeners(); // Avisa a la app que redibuje
  }

  Future<void> setModoOscuro(bool value) async {
    _modoOscuro = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modoOscuro', value);
    notifyListeners();
  }
}