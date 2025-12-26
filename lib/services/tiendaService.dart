import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:trabajo1/models/tiendaMostrar_dto.dart';
import 'package:trabajo1/models/tienda_dto.dart';
import 'package:trabajo1/models/tienda_crear_dto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class TiendaService {
  final String baseUrl1= "https://apicredito2-8.onrender.com/api";
   final String baseUrl = "https://apicredito2-8.onrender.com/api";
 final storage = const FlutterSecureStorage();
  List<tiendaMostrar_dto>? _cacheTiendas;
final cargandoNotifier = ValueNotifier<bool>(false);
final tiendasNotifier = ValueNotifier<List<tiendaMostrar_dto>?>(null);



 TiendaService._internal() {
    debugPrint("🟣 [TiendaService] instancia creada → hash: $hashCode");
  }

  static final TiendaService _instance = TiendaService._internal();
  factory TiendaService() {

    return _instance;
    
  }


 Future<List<tiendaMostrar_dto>> getTienda0() async {
  final token = await storage.read(key: 'jwt_token');

  if (token == null) {
    throw Exception("Token no encontrado. Usuario no autenticado.");
  }

  final url = Uri.parse('$baseUrl/Tienda/tiendasApp');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print("Respuesta API Tiendas: ${response.body}");

  if (response.statusCode == 200) {
   final List decoded = jsonDecode(response.body);
  // final decoded = jsonDecode(response.body);



    return decoded
        .map((item) => tiendaMostrar_dto.fromJson(item))
        .toList();
  } else {
    throw Exception("Error al obtener las tiendas: ${response.statusCode}");
  }
}


  
Future<List<tiendaMostrar_dto>> getTienda({bool forceRefresh = false}) async {
  debugPrint("🔵 [getTienda] llamado | forceRefresh=$forceRefresh");
  debugPrint("🔵 [getTienda] cache actual: ${_cacheTiendas?.length}");
  cargandoNotifier.value = true;

  try {
    // 1️⃣ Usar cache si no se fuerza refresh
    if (_cacheTiendas != null && !forceRefresh) {
      tiendasNotifier.value = List.unmodifiable(_cacheTiendas!);
      return tiendasNotifier.value!; // ✅ RETORNA LISTA
    }

    // 2️⃣ Leer token
    String? token = await storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception("Token no encontrado. Por favor inicia sesión.");
    }

    // 3️⃣ Petición HTTP
    final response = await http.get(
      Uri.parse('$baseUrl/Tienda/tiendasApp'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // 4️⃣ Respuesta
    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      _cacheTiendas = decoded
          .map((e) => tiendaMostrar_dto.fromJson(e))
          .toList();

      tiendasNotifier.value = List.unmodifiable(_cacheTiendas!);
      return tiendasNotifier.value!; // ✅ RETORNA LISTA
    }

    if (response.statusCode == 401) {
      await storage.delete(key: 'jwt_token');
      throw Exception("Sesión expirada. Inicia sesión nuevamente.");
    }

    throw Exception("Error API: ${response.statusCode}");

  } catch (e) {
    debugPrint('❌ Error getTienda: $e');
    rethrow;
  } finally {
    cargandoNotifier.value = false;
    debugPrint("🟢 [getTienda] tiendas cargadas: ${tiendasNotifier.value?.length}");
  }
}


  // 🧹 Limpiar caché
  void clearCache() {
    _cacheTiendas = null;
  }


Future<tiendaMostrar_dto> GuardarTienda(TiendaCrearDTO tienda) async {
  final token = await storage.read(key: 'jwt_token');

  if (token == null) {
    throw Exception("Token no encontrado. Usuario no autenticado.");
  }

  final url = Uri.parse('$baseUrl1/Tienda/GuardarTiendaJWT');

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

    if (decoded['status'] == true) {
      // 🔄 Limpiamos caché para que al listar se refresque
      clearCache();

      return tiendaMostrar_dto.fromJson(decoded['value']);
    } else {
      throw Exception(decoded['msg']);
    }
  } else {
    throw Exception("Error al guardar tienda: ${response.statusCode}");
  }
}


Future<void> cargarTienda() async {
  await getTienda(forceRefresh: true);
  
}

void _actualizarTiendaDesdeEvento(tiendaMostrar_dto nuevaTienda) {
  if (_cacheTiendas == null) return;

  final index = _cacheTiendas!.indexWhere((t) => t.id == nuevaTienda.id);
  if (index == -1) return;

  //final actual = _cacheCreditos![index];
_cacheTiendas![index] = nuevaTienda;
  tiendasNotifier.value = List.from(_cacheTiendas!);
   debugPrint("✅ Tienda actualizada | id: ${nuevaTienda.id} | nombre: ${nuevaTienda.nombreEncargado}");
}

/// 🧹 LIMPIAR ESTADO AL CAMBIAR DE USUARIO
Future<void> limpiar() async {
  debugPrint("🧹 [creditoMostrarHome] limpiando estado");



  // 2️⃣ Limpiar cache
  _cacheTiendas = null;

  // 3️⃣ Limpiar notifiers
  tiendasNotifier.value = null;

  cargandoNotifier.value = false;

}

 
}