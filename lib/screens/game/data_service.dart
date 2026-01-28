import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Clases de Estadísticas y Cerebro ---
class UserStats {
  final Map<String, Map<String, int>> correctCounts = {};
  final Map<String, Map<String, int>> incorrectCounts = {};

  UserStats({List<String>? categories}) {
    if (categories != null) {
      for (var cat in categories) {
        correctCounts[cat] = {};
        incorrectCounts[cat] = {};
      }
    }
  }
}

/// Modelo para representar un item del juego
class GameItem {
  final String id;
  final String categoryId;
  final String categoryName;
  final String value;
  final String? soundCommand;
  final String? imageUrl;

  GameItem({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.value,
    this.soundCommand,
    this.imageUrl,
  });

  Map<String, String> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'value': value,
      if (soundCommand != null) 'soundCommand': soundCommand!,
      if (imageUrl != null) 'imageUrl': imageUrl!,
    };
  }
}

/// Modelo para representar una tarjeta NFC
class NFCCard {
  final String uid;
  final Map<String, String> itemValues; // {'categoryId': 'value', ...}

  NFCCard({required this.uid, required this.itemValues});
}

class DataService with ChangeNotifier {
  BluetoothConnection? _connection;
  bool isConnected = false;
  String _messageBuffer = "";
  final _uidStreamController = StreamController<String>.broadcast();
  Stream<String> get uidStream => _uidStreamController.stream;

  final Map<String, UserStats> _userData = {};
  String? _activeUser;

  // --- Base de Datos Dinámicas ---
  final Map<String, GameItem> _gameItems = {}; // Todos los items del juego
  final Map<String, NFCCard> _nfcCards = {}; // Tarjetas NFC y sus valores
  final Map<String, Map<String, List<GameItem>>> _itemsByCategory =
      {}; // Items organizados por categoría

  bool _isLoadingData = false;

  // --- Getters ---
  String? get activeUser => _activeUser;
  List<String> get allUsers => _userData.keys.toList();
  UserStats? get activeUserStats => _userData[_activeUser];
  bool get isLoadingData => _isLoadingData;

  DataService() {
    _loadDataFromFirestore();
  }

  // --- CARGAR DATOS DESDE FIRESTORE ---
  Future<void> _loadDataFromFirestore() async {
    try {
      _isLoadingData = true;
      notifyListeners();

      // Cargar items del juego
      await _loadGameItemsFromFirestore();

      // Cargar tarjetas NFC
      await _loadNFCCardsFromFirestore();

      _isLoadingData = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error cargando datos: $e');
      _isLoadingData = false;
      notifyListeners();
    }
  }

  Future<void> _loadGameItemsFromFirestore() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('game_items')
          .get();

      _gameItems.clear();
      _itemsByCategory.clear();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final item = GameItem(
          id: doc.id,
          categoryId: data['categoryId'] ?? '',
          categoryName: data['categoryName'] ?? '',
          value: data['value'] ?? '',
          soundCommand: data['soundCommand'],
          imageUrl: data['imageUrl'],
        );

        _gameItems[item.id] = item;

        // Organizar por categoría
        if (!_itemsByCategory.containsKey(item.categoryId)) {
          _itemsByCategory[item.categoryId] = {};
        }
        if (!_itemsByCategory[item.categoryId]!.containsKey(
          item.categoryName,
        )) {
          _itemsByCategory[item.categoryId]![item.categoryName] = [];
        }
        _itemsByCategory[item.categoryId]![item.categoryName]!.add(item);
      }

      print('✅ Items del juego cargados: ${_gameItems.length}');
    } catch (e) {
      print('❌ Error cargando items: $e');
    }
  }

  Future<void> _loadNFCCardsFromFirestore() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('nfc_cards')
          .get();

      _nfcCards.clear();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final itemValues = Map<String, String>.from(data['itemValues'] ?? {});

        _nfcCards[data['uid']] = NFCCard(
          uid: data['uid'],
          itemValues: itemValues,
        );
      }

      print('✅ Tarjetas NFC cargadas: ${_nfcCards.length}');
    } catch (e) {
      print('❌ Error cargando tarjetas NFC: $e');
    }
  }

  // --- MÉTODOS DE USUARIOS ---
  void addUser(String name) {
    if (name.isNotEmpty && !_userData.containsKey(name)) {
      _userData[name] = UserStats(categories: _itemsByCategory.keys.toList());
      notifyListeners();
    }
  }

  void setActiveUser(String? userName) {
    if (userName != null && _userData.containsKey(userName)) {
      _activeUser = userName;
      notifyListeners();
    }
  }

  // --- OBTENER ITEMS DEL JUEGO ---
  /// Obtiene todos los items
  List<Map<String, String>> getAllGameItems() {
    return _gameItems.values.map((item) => item.toMap()).toList();
  }

  /// Obtiene items filtrados por categoryId
  List<Map<String, String>> getGameItemsByCategory(String categoryId) {
    if (_itemsByCategory.containsKey(categoryId)) {
      final items = <GameItem>[];
      _itemsByCategory[categoryId]!.forEach((_, itemList) {
        items.addAll(itemList);
      });
      return items.map((item) => item.toMap()).toList();
    }
    return [];
  }

  /// Obtiene items por categoryId y categoryName específicos
  List<Map<String, String>> getGameItemsByCategoryAndName(
    String categoryId,
    String categoryName,
  ) {
    if (_itemsByCategory.containsKey(categoryId) &&
        _itemsByCategory[categoryId]!.containsKey(categoryName)) {
      return _itemsByCategory[categoryId]![categoryName]!
          .map((item) => item.toMap())
          .toList();
    }
    return [];
  }

  // --- OBTENER COMANDO DE SONIDO ---
  /// Obtiene el comando de sonido para un valor específico
  String getSoundCommand(String value, String categoryId) {
    for (var item in _gameItems.values) {
      if (item.value == value && item.categoryId == categoryId) {
        return item.soundCommand ?? 'S0';
      }
    }
    return 'S0'; // Sonido por defecto
  }

  // --- MAPEO: VALOR → UID DE TARJETA ---
  String? _getUidForValue(String value, String categoryId) {
    for (var card in _nfcCards.values) {
      if (card.itemValues.containsValue(value)) {
        // Verificar que el valor pertenece a la categoría correcta
        for (var item in _gameItems.values) {
          if (item.value == value &&
              item.categoryId == categoryId &&
              card.itemValues[categoryId] == value) {
            return card.uid;
          }
        }
      }
    }
    return null;
  }

  // --- OBTENER CATEGORÍA ---
  String? _getCategoryForValue(String value) {
    for (var item in _gameItems.values) {
      if (item.value == value) {
        return item.categoryId;
      }
    }
    return null;
  }

  // --- REGISTRAR RESULTADO DEL JUEGO ---
  bool logGameResult(String scannedUid, String expectedValue) {
    if (_activeUser == null) return false;

    final stats = _userData[_activeUser]!;
    final category = _getCategoryForValue(expectedValue);

    if (category == null) {
      print('❌ Categoría no encontrada para: $expectedValue');
      return false;
    }

    final expectedUid = _getUidForValue(expectedValue, category);
    bool isCorrect = (scannedUid == expectedUid);

    // Inicializar si no existe
    if (!stats.correctCounts[category]!.containsKey(expectedValue)) {
      stats.correctCounts[category]![expectedValue] = 0;
    }
    if (!stats.incorrectCounts[category]!.containsKey(expectedValue)) {
      stats.incorrectCounts[category]![expectedValue] = 0;
    }

    if (isCorrect) {
      stats.correctCounts[category]![expectedValue] =
          (stats.correctCounts[category]![expectedValue] ?? 0) + 1;
      print('✅ Respuesta correcta: $expectedValue (UID: $scannedUid)');
    } else {
      stats.incorrectCounts[category]![expectedValue] =
          (stats.incorrectCounts[category]![expectedValue] ?? 0) + 1;
      print(
        '❌ Respuesta incorrecta: Esperado UID $expectedUid, Escaneado $scannedUid',
      );
    }

    notifyListeners();
    return isCorrect;
  }

  // --- GUARDAR ESTADÍSTICAS EN FIRESTORE ---
  Future<void> saveUserStats(String userId) async {
    if (_activeUser == null) return;

    try {
      final stats = _userData[_activeUser]!;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('game_stats')
          .doc(_activeUser)
          .set({
            'correctCounts': stats.correctCounts,
            'incorrectCounts': stats.incorrectCounts,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      print('✅ Estadísticas guardadas para $_activeUser');
    } catch (e) {
      print('❌ Error guardando estadísticas: $e');
    }
  }

  // --- MÉTODOS DE CONEXIÓN BLUETOOTH ---
  Future<bool> connect(BluetoothDevice device) async {
    try {
      if (_connection != null && _connection!.isConnected) {
        await _connection!.close();
      }

      _connection = await BluetoothConnection.toAddress(device.address);
      isConnected = true;
      notifyListeners();
      print('✅ Conectado a ${device.name}');

      // Lector de datos
      _connection!.input!
          .listen((Uint8List data) {
            try {
              // 🔹 Filtra bytes válidos (evita errores 252, 254, 255)
              final filtered = data
                  .where((b) => (b >= 32 && b <= 126) || b == 10 || b == 13)
                  .toList();
              if (filtered.isEmpty) return;

              _messageBuffer += ascii.decode(filtered);

              while (_messageBuffer.contains('\n')) {
                int newlineIndex = _messageBuffer.indexOf('\n');
                String completeMessage = _messageBuffer
                    .substring(0, newlineIndex)
                    .trim();
                _messageBuffer = _messageBuffer.substring(newlineIndex + 1);

                if (completeMessage.toUpperCase().contains("UID:")) {
                  String uid = completeMessage
                      .substring(completeMessage.indexOf(':') + 1)
                      .trim();
                  if (uid.isNotEmpty) {
                    _uidStreamController.add(uid);
                  }
                }
              }
            } catch (e) {
              print('⚠️ Error parseando datos BT: $e');
              _messageBuffer = "";
            }
          })
          .onDone(() {
            isConnected = false;
            notifyListeners();
            print('❌ Conexión terminada.');
          });

      return true;
    } catch (e) {
      print('🚫 Error al conectar: $e');
      isConnected = false;
      notifyListeners();
      return false;
    }
  }

  // --- ENVIAR COMANDO ---
  void sendMessage(String message) {
    if (_connection != null && _connection!.isConnected) {
      try {
        _connection!.output.add(ascii.encode("$message\n"));
        _connection!.output.allSent;
        print("📤 Enviado: $message");
      } catch (e) {
        print("⚠️ Error enviando mensaje: $e");
      }
    } else {
      print("🚫 No hay conexión Bluetooth activa.");
    }
  }

  Future<void> disconnect() async {
    if (_connection != null && _connection!.isConnected) {
      await _connection!.close();
    }
    isConnected = false;
    notifyListeners();
  }

  // --- RECARGAR DATOS ---
  Future<void> refreshData() async {
    await _loadDataFromFirestore();
  }
}

// --- Instancia global ---
final DataService dataService = DataService();
