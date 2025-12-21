
import 'package:intl/intl.dart';

class CreditoDTO {
  int id;
  double montoTotal;
  double entrada; // <--- Agregado
  int plazoCuotas;
  String frecuenciaPago;
  DateTime diaPago;
  
  
  double? valorPorCuota;
  double? montoPendiente;

  DateTime? proximaCuota;
  String? proximaCuotaStr;
  String? estado;
  //int clienteId;
  DateTime? fechaCreacion;

  CreditoDTO({
    this.id = 0,
    required this.montoTotal,
    this.entrada = 0.0,
    required this.plazoCuotas,
    required this.frecuenciaPago,
    required this.diaPago,
    this.valorPorCuota,
    this.montoPendiente,
    this.proximaCuota,
    this.proximaCuotaStr,
    this.estado,
    //this.clienteId = 0,
    this.fechaCreacion,
  });

 // ------------------- FROM JSON -------------------
  factory CreditoDTO.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is String) return DateTime.parse(date);
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    return CreditoDTO(
      id: json['Id'] ?? 0,
      montoTotal: (json['MontoTotal'] ?? 0).toDouble(),
      entrada: (json['Entrada'] ?? 0).toDouble(),
      plazoCuotas: json['PlazoCuotas'] ?? 0,
      frecuenciaPago: json['FrecuenciaPago'] ?? '',
      diaPago: parseDate(json['DiaPago']),
      valorPorCuota: (json['ValorPorCuota'] ?? 0).toDouble(),
      montoPendiente: (json['MontoPendiente'] ?? 0).toDouble(),
      proximaCuota: parseDate(json['ProximaCuota']),
      proximaCuotaStr: json['ProximaCuotaStr'],
      estado: json['Estado'],
      //clienteId: json['ClienteId'] ?? 0,
      fechaCreacion: parseDate(json['FechaCreacion']),
    );
  }

  // ------------------- TO JSON -------------------
  Map<String, dynamic> toJson() => {
       'Id': id,
      'Entrada': entrada,
      'MontoTotal': montoTotal,
      'MontoPendiente': montoPendiente ?? 0,
      'PlazoCuotas': plazoCuotas,
      'FrecuenciaPago': frecuenciaPago,
      'DiaPago': diaPago.toUtc().toIso8601String(),
      'ValorPorCuota': valorPorCuota ?? 0,
      'ProximaCuota':  proximaCuota?.toUtc().toIso8601String(),
      'ProximaCuotaStr': proximaCuotaStr ?? '',
      'Estado': estado ?? '',
      'FechaCreacion': fechaCreacion?.toUtc().toIso8601String(),
     // 'ClienteId': clienteId,
         
   
      };
}