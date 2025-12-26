import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
class LocationService {
  // Usamos la misma base URL que tus otros servicios
  final String baseUrl = "https://apicredito2-8.onrender.com/api";
  final storage = const FlutterSecureStorage();

  /// 1. Método principal: Obtiene la ubicación y la envía al backend
  Future<void> sendCurrentLocation() async {
    try {
      final position = await _determinePosition();
      if (position != null) {
       // await _sendToApi(position);
        await _sendToApiPost(position);
      }
    } catch (e) {
      print("⚠️ Error en servicio de ubicación: $e");
      // Aquí podrías manejar lógica si el usuario niega permisos (ej. cerrar sesión)
    }
  }

  /// 2. Lógica estándar de Geolocator para pedir permisos
  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el GPS está prendido
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('El GPS está desactivado.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permisos de ubicación denegados.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Permisos de ubicación denegados permanentemente.');
      return null;
    }

    // Obtener posición actual (alta precisión)
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// 3. Enviar al Backend (Método GET con Query Parameters)
  Future<void> _sendToApi(Position position) async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) return;

    // Endpoint: Asumimos una estructura como /Ubicacion/Registrar?lat=xxx&lng=yyy
    // Ajusta la ruta 'Ubicacion/Registrar' según como lo hayas creado en .NET
    final url = Uri.parse(
        '$baseUrl/Ubicacion/Registrar?latitud=${position.latitude}&longitud=${position.longitude}'
    );

    try {
      print("📍 Enviando ubicación: ${position.latitude}, ${position.longitude}");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("✅ Ubicación registrada exitosamente en el servidor.");
      } else {
        print("❌ Error al registrar ubicación: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error de conexión al enviar ubicación: $e");
    }
  }


    /// Enviar ubicación al API (POST)
  Future<void> _sendToApiPost(Position position) async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      print("❌ Token no encontrado");
      return;
    }

    final url = Uri.parse('$baseUrl/Ubicacion/Registrar');

    final body = {
      "Latitud": position.latitude,
      "Longitud": position.longitude,
    };

    try {
      print("📍 Enviando ubicación: ${position.latitude}, ${position.longitude}");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("✅ Ubicación guardada correctamente");
      } else {
        print("❌ Error al guardar ubicación: ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print("❌ Error de conexión: $e");
    }
  }
}