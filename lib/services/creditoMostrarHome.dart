import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo1/models/credito_dto.dart';
import 'package:trabajo1/models/CreditoMostrarDTO.dart';
import 'package:signalr_core/signalr_core.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/material.dart';

class creditoMostrarHome {

   final String baseUrl = "https://apicredito2-8.onrender.com/api";
  final String baseUrl3 = "https://apicredito2-8.onrender.com/api";
  final String baseUrl2 = "https://apicredito2-8.onrender.com/api";
  final String baseUrl1 = "https://apicredito2-8.onrender.com";
  final storage = const FlutterSecureStorage();
  // WebSocket
  late HubConnection _connection;
  final isLoadingNotifier = ValueNotifier<bool>(false);
  // 🟢 CACHÉ EN MEMORIA
  List<CreditoMostrarDTO>? _cacheCreditos;
  // 🟢 Notificador para UI
 // final creditosNotifier = ValueNotifier<List<CreditoMostrarDTO>>([]);
  final mensajeNotifier = ValueNotifier<String>("");
final creditosNotifier = ValueNotifier<List<CreditoMostrarDTO>?>(null);
final cargandoNotifier = ValueNotifier<bool>(false);
 creditoMostrarHome._internal() {
    debugPrint("🟣 [creditoMostrarHome] instancia creada → hash: $hashCode");
  }

  static final creditoMostrarHome _instance = creditoMostrarHome._internal();

  factory creditoMostrarHome() {
    
    return _instance;
    
  }Future<void> connectSignalR() async {
  debugPrint("🟡 Iniciando conexión SignalR");

  final token = await storage.read(key: 'jwt_token');

  if (token == null || token.isEmpty) {
    debugPrint("❌ TOKEN NULL O VACÍO");
    return;
  }

  final hubUrl = '$baseUrl1/adminhub';

  _connection = HubConnectionBuilder()
      .withUrl(
        hubUrl,
        HttpConnectionOptions(
          accessTokenFactory: () async => token,
        ),
      )
      .build();

  // 📡 Evento crédito actualizado
  _connection.on('CreditoActualizado', (args) {
    debugPrint("📩 Evento CreditoActualizado recibido: $args");

    if (args == null || args.isEmpty) return;

    try {
      final data = Map<String, dynamic>.from(args.first);
      final credito = CreditoMostrarDTO.fromJson(data);

      // Inicializar caché si es null
      _cacheCreditos ??= [];

      // ✅ Aquí llamamos al método que creamos
      _actualizarCreditoDesdeEvento(credito);

      mensajeNotifier.value = "Crédito actualizado";
      debugPrint("✅ Evento procesado | cache size: ${_cacheCreditos!.length}");
    } catch (e, s) {
      debugPrint("❌ Error procesando evento: $e");
      debugPrint("📛 Stack: $s");
    }
  });

  // 🔌 Ciclo de vida de conexión
  _connection.onclose((e) => debugPrint("⚡ SignalR cerrado | $e"));
  _connection.onreconnecting((e) => debugPrint("🔄 SignalR reconectando | $e"));
  _connection.onreconnected((id) =>
      debugPrint("✅ SignalR reconectado - ConnectionId: $id"));

  try {
    debugPrint("🚀 Intentando conectar SignalR...");
    await _connection.start();
    debugPrint("✅ SignalR CONECTADO | ConnectionId: ${_connection.connectionId}");
  } catch (e, s) {
    debugPrint("❌ ERROR AL CONECTAR SIGNALR | $e");
    debugPrint("📛 Stack: $s");
  }
}



Future<void> connectSignalR1() async {
  debugPrint("🟡 Iniciando conexión SignalR");

  final token = await storage.read(key: 'jwt_token');

  // 🔐 Verificar token
  if (token == null || token.isEmpty) {
    debugPrint("❌ TOKEN NULL O VACÍO");
    return;
  }
  debugPrint("🔐 Token OK: ${token.substring(0, 15)}...");

  final hubUrl = '$baseUrl1/adminhub';
  debugPrint("🌐 URL SignalR: $hubUrl");

  _connection = HubConnectionBuilder()
      .withUrl(
        hubUrl,
        HttpConnectionOptions(
          accessTokenFactory: () async {
            debugPrint("🔁 SignalR solicitó token");
            return token;
          },
        ),
      )
      .build();

  // 📡 Evento crédito actualizado
  _connection.on('CreditoActualizado', (args) {
    debugPrint("📩 Evento CreditoActualizado recibido");
    debugPrint("📦 Args: $args");

    if (args == null || args.isEmpty) {
      debugPrint("⚠️ Args vacíos");
      return;
    }

    try {
      final data = Map<String, dynamic>.from(args.first);
      debugPrint("📄 Data parseada: $data");

      final credito = CreditoMostrarDTO.fromJson(data);

      final cache = _cacheCreditos ??= [];

      final index = cache.indexWhere((c) => c.id == credito.id);
      debugPrint("🔎 Índice encontrado: $index");

      if (index >= 0) {
        cache[index] = credito;
        debugPrint("✏️ Crédito actualizado en caché");
      } else {
        cache.add(credito);
        debugPrint("➕ Crédito agregado a caché");
      }

      creditosNotifier.value = List.unmodifiable(cache);
      mensajeNotifier.value = "Crédito actualizado";

      debugPrint("✅ Notificadores actualizados");
    } catch (e, s) {
      debugPrint("❌ Error procesando evento: $e");
      debugPrint("📛 Stack: $s");
    }
  });

  // 🔌 Ciclo de vida de conexión
  _connection.onclose((e) {
    debugPrint("⚡ SignalR cerrado");
    debugPrint("📛 Error: $e");
  });

  _connection.onreconnecting((e) {
    debugPrint("🔄 SignalR reconectando");
    debugPrint("📛 Error: $e");
  });

  _connection.onreconnected((id) {
    debugPrint("✅ SignalR reconectado - ConnectionId: $id");
  });

  try {
    debugPrint("🚀 Intentando conectar SignalR...");
    await _connection.start();
    debugPrint("✅ SignalR CONECTADO CORRECTAMENTE");
    debugPrint("🆔 ConnectionId: ${_connection.connectionId}");
  } catch (e, s) {
    debugPrint("❌ ERROR AL CONECTAR SIGNALR");
    debugPrint("📛 Error: $e");
    debugPrint("📛 Stack: $s");
  }
}

  /// 🔌 Desconectar
  Future<void> disconnectSignalR() async {
    await _connection.stop();
  }

  Future<List<CreditoMostrarDTO>> getCreditos1({
    bool forceRefresh = false,
  }) async {
    debugPrint("🟡 getCreditos() llamado | forceRefresh: $forceRefresh");
    isLoadingNotifier.value = true;

    try {
      // 1️⃣ Usar caché si existe
      if (_cacheCreditos != null && !forceRefresh) {
        creditosNotifier.value = List.from(_cacheCreditos!);
        return _cacheCreditos!;
      }

      // 2️⃣ Leer token
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception("Token no encontrado.");
      }
      // 3️⃣ Llamada HTTP
      final url = Uri.parse('$baseUrl/Credito/pendientesApp');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      // 4️⃣ Procesar respuesta
      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);

        _cacheCreditos = decoded
            .map((e) => CreditoMostrarDTO.fromJson(e))
            .toList();
        // Notificar UI
        creditosNotifier.value = List.from(_cacheCreditos!);
        return _cacheCreditos!;
      } else {
        throw Exception("Error API");
      }
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  Future<void> getCreditos3({bool forceRefresh = false}) async {
  cargandoNotifier.value = true;

  try {
    if (_cacheCreditos != null && !forceRefresh) {
      creditosNotifier.value = List.unmodifiable(_cacheCreditos!);
      return;
    }

    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception("Token no encontrado");

    final response = await http.get(
      Uri.parse('$baseUrl/Credito/pendientesApp'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      _cacheCreditos = decoded.map((e) => CreditoMostrarDTO.fromJson(e)).toList();
      creditosNotifier.value = List.unmodifiable(_cacheCreditos!);
    } else {
      throw Exception("Error API: ${response.statusCode}");
    }
  } finally {
    cargandoNotifier.value = false;
  }
}

Future<void> getCreditos({bool forceRefresh = false}) async {

   debugPrint("🔵 [getCreditos] llamado | forceRefresh=$forceRefresh");
  debugPrint("🔵 [getCreditos] cache actual: ${_cacheCreditos?.length}");
  cargandoNotifier.value = true;

  try {
    // 1️⃣ Usar cache si no se fuerza refresh
    if (_cacheCreditos != null && !forceRefresh) {
      creditosNotifier.value = List.unmodifiable(_cacheCreditos!);
      return;
    }

    // 2️⃣ Leer token guardado
    String? token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception("Token no encontrado. Por favor inicia sesión.");

    // 3️⃣ Hacer petición
    final response = await http.get(
      Uri.parse('$baseUrl/Credito/pendientesApp'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // 4️⃣ Manejar respuesta
    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      _cacheCreditos = decoded.map((e) => CreditoMostrarDTO.fromJson(e)).toList();
      creditosNotifier.value = List.unmodifiable(_cacheCreditos!);

    } else if (response.statusCode == 401) {
      // 5️⃣ Token expirado o inválido
      print('⚠️ Token expirado. Redirigiendo a login...');
      // Limpiar token guardado
      await storage.delete(key: 'jwt_token');
      // Notificar al usuario o forzar login de nuevo
      throw Exception("Sesión expirada. Por favor inicia sesión nuevamente.");

    } else {
      throw Exception("Error API: ${response.statusCode}");
    }

  } catch (e) {
    print('Error getCreditos: $e');
    rethrow; // opcional, para manejar en UI
  } finally {
    cargandoNotifier.value = false;
    debugPrint("🟢 [getCreditos] créditos cargados: ${creditosNotifier.value?.length}");
  }
}

  // 🧹 Limpiar caché
  void clearCache() {
    _cacheCreditos = null;
  }


  
Future<CreditoDTO> guardarCredito(CreditoDTO tienda) async {
  final token = await storage.read(key: 'jwt_token');

  if (token == null) {
    throw Exception("Token no encontrado. Usuario no autenticado.");
  }

  final url = Uri.parse('$baseUrl/Credito/GuardarJWT');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(tienda.toJson()),
  );

  print("Respuesta API Guardar Tienda: ${response.body}");

  if (response.statusCode == 200) {
    
    final decoded = jsonDecode(response.body);
 print("DEBUG: JSON value = ${decoded['value']}");
    if (decoded['status'] == true) {
      // 🔄 Limpiamos caché para que al listar se refresque
      clearCache();

      return CreditoDTO.fromJson(decoded['value']);
    } else {
      throw Exception(decoded['msg']);
    }
  } else {
    throw Exception("Error al guardar tienda: ${response.statusCode}");
  }
}
Future<void> cargarCreditos() async {
  await getCreditos(forceRefresh: true);
  
}

void _actualizarCreditoDesdeEvento(CreditoMostrarDTO nuevo) {
  if (_cacheCreditos == null) return;

  final index = _cacheCreditos!.indexWhere((c) => c.id == nuevo.id);
  if (index == -1) return;

  //final actual = _cacheCreditos![index];
_cacheCreditos![index] = nuevo;

  creditosNotifier.value = List.from(_cacheCreditos!);
   debugPrint("✅ Crédito actualizado | id: ${nuevo.id} | montoPendiente: ${nuevo.montoPendiente} | proximaCuotaStr: ${_cacheCreditos![index].proximaCuotaStr}");
}
/// 🧹 LIMPIAR ESTADO AL CAMBIAR DE USUARIO
Future<void> limpiar() async {
  debugPrint("🧹 [creditoMostrarHome] limpiando estado");

  // 1️⃣ Detener SignalR
  try {
    if (_connection.state == HubConnectionState.connected) {
      await _connection.stop();
      debugPrint("🔌 SignalR detenido");
    }
  } catch (_) {}

  // 2️⃣ Limpiar cache
  _cacheCreditos = null;

  // 3️⃣ Limpiar notifiers
  creditosNotifier.value = null;
  mensajeNotifier.value = "";
  cargandoNotifier.value = false;
  isLoadingNotifier.value = false;
}

// ✅ INSTANCIA GLOBAL ÚNICA
//final creditoMostrarHome creditoHomeService = creditoMostrarHome();
}
