
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/forgot_password_dto.dart';
import '../models/verificar_dto.dart';
import '../models/reset_password_dto.dart';



class Verificacion {

final String baseUrl = "https://apicredito2-ximx.onrender.com/api";
// =============== FORGOT PASSWORD ===============
Future<ForgotPasswordDTO?> forgotPassword(ForgotPasswordDTO dto) async {
  final url = Uri.parse('$baseUrl/Password/forgot-password');
  print('--- FORGOT PASSWORD ---');
  print('URL: $url');
  print('Datos enviados: ${dto.toJson()}');

  try {
    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(dto.toJson()),
        )
        .timeout(const Duration(seconds: 20));

    print('Código de respuesta: ${response.statusCode}');
    print('Cuerpo de respuesta: ${response.body}');

    if (response.statusCode == 200) {
      // Respuesta exitosa como string
      print('✅ Solicitud de recuperación exitosa: ${response.body}');
      return dto; // simplemente retornamos el DTO enviado
    } else {
      print('❌ Error al enviar correo: ${response.body}');
      return null;
    }
  } catch (e) {
    print('⚠️ Excepción en forgotPassword: $e');
    return null;
  }
}

  // =============== RESET PASSWORD ===============

  Future<String?> resetPassword(ResetPasswordDTO dto) async {
  final url = Uri.parse('https://apicredito2-ximx.onrender.com/api/Password/reset-password');
  print('--- RESET PASSWORD ---');
  print('URL: $url');
  print('Datos enviados: ${dto.toJson()}');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    ).timeout(const Duration(seconds: 10));

    print('Código de respuesta: ${response.statusCode}');
    print('Cuerpo de respuesta: ${response.body}');

    if (response.statusCode == 200) {
      // Retornamos el texto plano directamente
      return response.body; 
    } else {
      print('Error en resetPassword: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Excepción en resetPassword: $e');
    return null;
  }
}
}