import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trabajo1/models/notificacion_dto.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:signalr_core/signalr_core.dart';
class NotificacionService {
  final String baseUrl ="https://apicredito2-8.onrender.com/api";
  final String baseUrl1= "http://192.168.100.13:7166/api";
   final String baseUrl11="http://192.168.100.13:7166";
 final storage = const FlutterSecureStorage();

  late HubConnection _connection;
  final isLoadingNotifier = ValueNotifier<bool>(false);
  // 🟢 CACHÉ EN MEMORIA

  // 🟢 Notificador para UI
 // final creditosNotifier = ValueNotifier<List<NotificacionDTO>>([]);
  final mensajeNotifier = ValueNotifier<String>("");
  final notificacionesNotifier = ValueNotifier<List<NotificacionDTO>?>(null);
  final cargandoNotifier = ValueNotifier<bool>(false);
  // 🟢 CACHÉ EN MEMORIA
  List<NotificacionDTO>? _cacheNotificaciones;


  NotificacionService._internal() {
    debugPrint("🟣 [NotificacionService] instancia creada → hash: $hashCode");
  }

  static final NotificacionService _instance = NotificacionService._internal();
  factory NotificacionService() {
    return _instance;
  }
 Future<void> connectSignalR() async {
    debugPrint("🟡 Iniciando conexión SignalR");

    final token = await storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      debugPrint("❌ TOKEN NULL O VACÍO");
      return;
    }

    final hubUrl = '$baseUrl11/adminhub';

    _connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          HttpConnectionOptions(accessTokenFactory: () async => token),
        )
        .build();

    // 📡 Evento notificación actualizada/creada
    _connection.on('NotificacionActualizado', (args) {
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("🔔🔔🔔 EVENTO SIGNALR RECIBIDO EN FLUTTER");
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("📩 Timestamp: ${DateTime.now().toString()}");
      debugPrint("📦 Args recibidos: $args");

      if (args == null || args.isEmpty) {
        debugPrint("⚠️ Args vacíos o null");
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        return;
      }

      try {
        final data = Map<String, dynamic>.from(args.first);
        debugPrint("✅ Data parseada correctamente");
        debugPrint("   Keys: ${data.keys}");
        
        final notificacion = NotificacionDTO.fromJson(data);
        debugPrint("✅ NotificacionDTO creado:");
        debugPrint("   ID: ${notificacion.id}");
        debugPrint("   Mensaje: ${notificacion.mensaje}");
        debugPrint("   Tipo: ${notificacion.tipo}");
        debugPrint("   Leída: ${notificacion.leida}");

        _cacheNotificaciones ??= [];
        debugPrint("   Cache size antes: ${_cacheNotificaciones!.length}");

        _actualizarNotificacionDesdeEvento(notificacion);

        debugPrint("   Cache size después: ${_cacheNotificaciones!.length}");
        mensajeNotifier.value = "Notificación recibida";
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
      } catch (e, s) {
        debugPrint("❌ Error procesando evento: $e");
        debugPrint("📛 Stack: $s");
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      }
    });

    // 🔌 Ciclo de vida de conexión
    _connection.onclose((e) => debugPrint("⚡ SignalR cerrado | $e"));
    _connection.onreconnecting(
      (e) => debugPrint("🔄 SignalR reconectando | $e"),
    );
    _connection.onreconnected(
      (id) => debugPrint("✅ SignalR reconectado - ConnectionId: $id"),
    );

    try {
      debugPrint("🚀 Intentando conectar SignalR...");
      await _connection.start();
      debugPrint(
        "✅ SignalR CONECTADO | ConnectionId: ${_connection.connectionId}",
      );
    } catch (e, s) {
      debugPrint("❌ ERROR AL CONECTAR SIGNALR | $e");
      debugPrint("📛 Stack: $s");
    }
  }

 /*Future<List<NotificacionDTO>> getNotificaciones({bool forceRefresh = false}) async {

    // 1️⃣ Si hay caché y no forzamos refresh → devolver
    if (_cacheNotificaciones != null && !forceRefresh) {
      print("⚡ Notificacion desde caché");
      return _cacheNotificaciones!;
    }

    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception("Token no encontrado. Usuario no autenticado.");
    }

    final url = Uri.parse('$baseUrl/Notificacion/pendientesNotApp');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("🌐 Notificacion desde API");

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);

      _cacheNotificaciones = decoded
          .map((item) => NotificacionDTO.fromJson(item))
          .toList();

      return _cacheNotificaciones!;
    } else {
      throw Exception("Error al obtener las notificaciones:  ${response.statusCode} - ${response.body}");
    }
  }*/
  Future<List<NotificacionDTO>> getNotificaciones({bool forceRefresh = false}) async {

  // 1️⃣ Si hay caché y no forzamos refresh → devolver
  if (_cacheNotificaciones != null && !forceRefresh) {
    debugPrint("⚡ Notificacion desde caché");
    return _cacheNotificaciones!;
  }

  final token = await storage.read(key: 'jwt_token');
  if (token == null) {
    throw Exception("Token no encontrado. Usuario no autenticado.");
  }

  final url = Uri.parse('$baseUrl/Notificacion/pendientesNotApp');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  debugPrint("🌐 Notificacion desde API");

  if (response.statusCode == 200) {
    final List decoded = jsonDecode(response.body);

    _cacheNotificaciones = decoded
        .map((item) => NotificacionDTO.fromJson(item))
        .toList();

    // 🔥🔥🔥 ESTA LÍNEA FALTABA
    notificacionesNotifier.value = List.from(_cacheNotificaciones!);

    return _cacheNotificaciones!;
  } else {
    throw Exception(
      "Error al obtener las notificaciones: ${response.statusCode} - ${response.body}"
    );
  }
}


  // 🧹 Limpiar caché
  void clearCache() {
    _cacheNotificaciones = null;
  }
   


   void _actualizarNotificacionDesdeEvento(NotificacionDTO nueva) {
  debugPrint("🔄 [NotifService] _actualizarNotificacionDesdeEvento llamado");
  debugPrint("   Notificación ID: ${nueva.id}");
  debugPrint("   Cache actual es null? ${_cacheNotificaciones == null}");
  
  if (_cacheNotificaciones == null) {
    debugPrint("⚠️ [NotifService] Cache null, inicializando...");
    _cacheNotificaciones = [nueva];
    notificacionesNotifier.value = List.from(_cacheNotificaciones!);
    debugPrint("✅ [NotifService] Cache inicializado con 1 notificación");
    return;
  }

  final index = _cacheNotificaciones!.indexWhere((n) => n.id == nueva.id);
  debugPrint("   Index encontrado: $index");
  
  if (index == -1) {
    // ✅ NUEVA NOTIFICACIÓN
    debugPrint("➕ [NotifService] Nueva notificación agregada | ID: ${nueva.id}");
    _cacheNotificaciones!.insert(0, nueva);
  } else {
    // ✅ ACTUALIZACIÓN
    debugPrint("🔄 [NotifService] Notificación actualizada | ID: ${nueva.id}");
    _cacheNotificaciones![index] = nueva;
  }

  // 🔔 FORZAR ACTUALIZACIÓN DEL NOTIFIER
  debugPrint("🔔 [NotifService] Actualizando notifier...");
  final nuevaLista = List<NotificacionDTO>.from(_cacheNotificaciones!);
  notificacionesNotifier.value = nuevaLista;
  
  debugPrint("✅ [NotifService] Notifier actualizado");
  debugPrint("   Total notificaciones: ${nuevaLista.length}");
  debugPrint("   No leídas: ${nuevaLista.where((n) => !n.leida).length}");
  debugPrint("   Valor actual del notifier: ${notificacionesNotifier.value?.length}");
}

  /// 📬 Marcar notificación como leída
Future<void> marcarComoLeida(int notificacionId) async {
  try {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception("Token no encontrado. Usuario no autenticado.");
    }

    final url = Uri.parse('$baseUrl/Notificacion/marcar-leida/$notificacionId');

    debugPrint("📤 Marcando notificación como leída | ID: $notificacionId");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      debugPrint("✅ Notificación marcada como leída | ID: $notificacionId");
      
      // 🔄 Actualizar caché local
      if (_cacheNotificaciones != null) {
        final index = _cacheNotificaciones!.indexWhere((n) => n.id == notificacionId);
        if (index != -1) {
          _cacheNotificaciones![index].leida = true;
          notificacionesNotifier.value = List.from(_cacheNotificaciones!);
          debugPrint("🔄 Caché actualizado localmente");
        }
      }
    } else {
      throw Exception(
        "Error al marcar como leída: ${response.statusCode} - ${response.body}"
      );
    }
  } catch (e) {
    debugPrint("❌ Error en marcarComoLeida: $e");
    rethrow;
  }
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
    _cacheNotificaciones = null;

    // 3️⃣ Limpiar notifiers
    notificacionesNotifier.value = null;
    mensajeNotifier.value = "";
    cargandoNotifier.value = false;
    isLoadingNotifier.value = false;
  }

}