import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo1/models/usuario_dto.dart';
import 'package:trabajo1/models/ClienteMostrarDTO.dart';
import 'package:trabajo1/models/DetalleCLientePostDTO.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UsuarioService {
  final String baseUrl = "https://apicredito2-8.onrender.com/api";
 final String baseUrl1 = "https://apicredito2-8.onrender.com/api";
 
 final storage = const FlutterSecureStorage();
 ClienteMostrarDTO? _cacheCliente;


  Future<dynamic> iniciarSesion(String correo, String clave) async {
    final url = Uri.parse("$baseUrl/Usuario/IniciarSesion");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"correo": correo, "clave": clave}),
    );

    return jsonDecode(response.body);
  }

  Future<dynamic> guardarUsuario(UsuarioDTO usuario) async {
    final url = Uri.parse("$baseUrl/Usuario/Guardar");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(usuario.toJson()),
    );

    return jsonDecode(response.body);
  }

   Future<UsuarioDTO?> crearUsuario1(UsuarioDTO dto) async {
    final url = Uri.parse("$baseUrl/Usuario/Guardar");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dto.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Devuelve el Usuario creado desde el backend
         final data = jsonDecode(response.body);
          if (data['status'] == true && data['value'] != null) {
        return UsuarioDTO.fromJson(data['value']);
      } else {
        print("Error del backend: ${data['msg']}");
        return null;
      }
      } else {
        print("Error en el servidor: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error en la conexión: $e");
      return null;
    }
  }

  Future<UsuarioDTO?> crearUsuario(UsuarioDTO dto) async {
  final url = Uri.parse("$baseUrl/Usuario/Guardar");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(dto.toJson()),
    );

    final data = jsonDecode(response.body);

    if (data['status'] == true && data['value'] != null) {
      return UsuarioDTO.fromJson(data['value']);
    } else {
      print("Error del backend: ${data['msg']}");
      return null;
    }
  } catch (e) {
    print("Error en la conexión: $e");
    return null;
  }
}


  Future<List<UsuarioDTO>> listarUsuarios() async {
    final url = Uri.parse("$baseUrl/Lista");

    final response = await http.get(url);

    final data = jsonDecode(response.body);

    List<UsuarioDTO> lista = (data["value"] as List)
        .map((e) => UsuarioDTO.fromJson(e))
        .toList();

    return lista;
  }

   Future<String?> getUsuarioId() async {
    // Supongamos que guardaste el usuarioId al iniciar sesión
    return await storage.read(key: 'usuarioId');
  }


  Future<ClienteMostrarDTO> getCliente0() async {
  final token = await storage.read(key: 'jwt_token');
  //final token = await getToken(); // donde guardas el token
  final usuarioId2 = await getUsuarioId(); 
   final usuarioId = await storage.read(key: 'usuario_id'); // donde guardas el usuarioId

  // Depuración rápida
  print('Token enviado: $token');
  print('UsuarioId enviado: $usuarioId');

  if (token == null) {
    throw Exception("Token no encontrado. Usuario no autenticado.");
  }

  final url = Uri.parse('$baseUrl/Cliente/ClienteApp');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print("Respuesta API Cliente: ${response.body}");

  if (response.statusCode == 200) {
    final Map<String, dynamic> decoded = jsonDecode(response.body);
    return ClienteMostrarDTO.fromJson(decoded);
  } else {
    throw Exception("Error al obtener el cliente: ${response.statusCode}");
  }
}





 Future<ClienteMostrarDTO> getCliente({bool forceRefresh = false}) async {

    // 1️⃣ Si hay caché y no forzamos refresh → devolver
    if (_cacheCliente != null && !forceRefresh) {
      print("Cliente desde caché");
      return _cacheCliente!;
    }

    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception("Token no encontrado. Usuario no autenticado.");
    }

    final url = Uri.parse('$baseUrl/Cliente/ClienteApp');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("Cliente desde API");

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);

      _cacheCliente = ClienteMostrarDTO.fromJson(decoded);

      return _cacheCliente!;
    } else {
      throw Exception("Error al obtener el cliente: ${response.statusCode}");
    }
  }

  // 🧹 Limpiar caché
  void clearCache() {
    _cacheCliente = null;
  }



Future<bool> actualizarDetalleClienteFotos(
    DetalleClientePostDTO detalle) async {
  final token = await storage.read(key: 'jwt_token');

  if (token == null) {
    throw Exception("Token no encontrado. Usuario no autenticado.");
  }

  final url = Uri.parse('$baseUrl/DetalleCliente/EditarFotosJWT');

  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(detalle.toJson()),
  );

  print("Respuesta API EditarFotosJWT: ${response.body}");

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);

    if (decoded['status'] == true) {
      // 🔄 Limpia caché del cliente porque cambió su info
      clearCache();
      return true;
    } else {
      throw Exception(decoded['msg']);
    }
  } else {
    throw Exception(
        "Error al actualizar detalle cliente: ${response.statusCode}");
  }
}
}
