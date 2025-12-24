/*
import '../models/tiendaMostrar_dto.dart';

class CreditoMostrarDTO {
  final int id;
  final  double montoTotal;
  final double montoPendiente;
  final String proximaCuotaStr;
  final int plazoCuotas;
  final double valorPorCuota;
  final String estado;
  final int clienteId;
  final int? tiendaId;
   final tiendaMostrar_dto? tienda;

  CreditoMostrarDTO({
    required this.id,
    required this.montoTotal,
    required this.montoPendiente,
    required this.proximaCuotaStr,
    required this.plazoCuotas,
    required this.valorPorCuota,
    required this.estado,
    required this.clienteId,
    this.tiendaId,
    this.tienda,
  });

  factory CreditoMostrarDTO.fromJson(Map<String, dynamic> json) {
  return CreditoMostrarDTO(
    id: json["id"] ?? 0,
    montoTotal: (json['MontoTotal'] ?? 0).toDouble(),
    montoPendiente: (json["montoPendiente"] ?? 0).toDouble(),
    proximaCuotaStr: json["proximaCuotaStr"] ?? "",
    plazoCuotas: (json["plazoCuotas"] ?? 0).toInt(),
    valorPorCuota: (json["valorPorCuota"] ?? 0).toDouble(),
    estado: json["estado"] ?? "",
    clienteId: (json["clienteId"] ?? 0).toInt(),
    tiendaId: (json["tiendaId"]?? 0).toInt(),
      // 🔥 AQUÍ está la clave
      tienda: json['tienda'] != null
          ? tiendaMostrar_dto.fromJson(json['tienda'])
          : null,
  );
}


  // 🔑 Método copyWith para actualizaciones parciales
  CreditoMostrarDTO copyWith({
    double? montoPendiente,
    String? proximaCuotaStr,
    String? estado,
    tiendaMostrar_dto? tienda,
  }) {
    return CreditoMostrarDTO(
      id: this.id,
      montoTotal: this.montoTotal,
      montoPendiente: montoPendiente ?? this.montoPendiente,
      proximaCuotaStr: proximaCuotaStr ?? this.proximaCuotaStr,
      plazoCuotas: this.plazoCuotas,
      valorPorCuota: this.valorPorCuota,
      estado: estado ?? this.estado,
      clienteId: this.clienteId,
       tiendaId: tiendaId ?? this.tiendaId, 
      tienda: tienda ?? this.tienda,
      
    );
  }

}


 */


/*
class CreditoMostrarDTO {
  final int id;
  final double montoPendiente;
  final String proximaCuotaStr;
  final int plazoCuotas;
  final double valorPorCuota;
  final String estado;
  final int clienteId;
  final DateTime? proximaCuota; // Importante para la alerta de días

  // Nuevos campos visuales
  final String marca;
  final String modelo;
  final double abonadoTotal;
  final double abonadoCuota;
  final String estadoCuota;

  CreditoMostrarDTO({
    required this.id,
    required this.montoPendiente,
    required this.proximaCuotaStr,
    required this.plazoCuotas,
    required this.valorPorCuota,
    required this.estado,
    required this.clienteId,
    this.proximaCuota,
    this.marca = '',
    this.modelo = '',
    this.abonadoTotal = 0.0,
    this.abonadoCuota = 0.0,
    this.estadoCuota = '',
  });

  factory CreditoMostrarDTO.fromJson(Map<String, dynamic> json) {
    return CreditoMostrarDTO(
      id: json["id"] ?? 0,
      montoPendiente: (json["montoPendiente"] ?? 0).toDouble(),
      proximaCuotaStr: json["proximaCuotaStr"] ?? "",
      proximaCuota: json["proximaCuota"] != null ? DateTime.parse(json["proximaCuota"]) : null,
      plazoCuotas: (json["plazoCuotas"] ?? 0).toInt(),
      valorPorCuota: (json["valorPorCuota"] ?? 0).toDouble(),
      estado: json["estado"] ?? "",
      clienteId: (json["clienteId"] ?? 0).toInt(),

      // Nuevos mapeos (asegúrate que tu API GET los devuelva)
      marca: json["marca"] ?? "Sin Marca",
      modelo: json["modelo"] ?? "Sin Modelo",
      abonadoTotal: (json["abonadoTotal"] ?? 0).toDouble(),
      abonadoCuota: (json["abonadoCuota"] ?? 0).toDouble(),
      estadoCuota: json["estadoCuota"] ?? "Pendiente",
    );
  }
}

 */

class CreditoMostrarDTO {
  final int id;
  final double montoPendiente;
  final String proximaCuotaStr;
  final int plazoCuotas;
  final double valorPorCuota;
  final String estado;
  final int clienteId;
  final int? tiendaId; // Para vincular con la tienda
  final DateTime? proximaCuota; // Útil para cálculos de días

  // --- NUEVOS CAMPOS VISUALES ---
  final String marca;
  final String modelo;
  final double abonadoTotal;
  final double abonadoCuota; // Cuánto ha pagado de la cuota actual
  final String estadoCuota;  // "Al día", "Vencida", "Parcial"

  CreditoMostrarDTO({
    required this.id,
    required this.montoPendiente,
    required this.proximaCuotaStr,
    required this.plazoCuotas,
    required this.valorPorCuota,
    required this.estado,
    required this.clienteId,
    this.tiendaId,
    this.proximaCuota,
    // Valores por defecto para evitar nulls
    this.marca = 'Dispositivo',
    this.modelo = '',
    this.abonadoTotal = 0.0,
    this.abonadoCuota = 0.0,
    this.estadoCuota = 'Pendiente',
  });

  factory CreditoMostrarDTO.fromJson(Map<String, dynamic> json) {
    return CreditoMostrarDTO(
      id: json["id"] ?? 0,
      montoPendiente: (json["montoPendiente"] ?? 0).toDouble(),
      proximaCuotaStr: json["proximaCuotaStr"] ?? "Pendiente",
      proximaCuota: json["proximaCuota"] != null ? DateTime.tryParse(json["proximaCuota"]) : null,
      plazoCuotas: (json["plazoCuotas"] ?? 0).toInt(),
      valorPorCuota: (json["valorPorCuota"] ?? 0).toDouble(),
      estado: json["estado"] ?? "Desconocido",
      clienteId: (json["clienteId"] ?? 0).toInt(),
      tiendaId: json["tiendaId"],

      // --- MAPEO DE NUEVOS CAMPOS ---
      // Asegúrate que el backend envíe estos nombres o ajústalos aquí
      marca: json["marca"] ?? "Equipo",
      modelo: json["modelo"] ?? "",
      abonadoTotal: (json["abonadoTotal"] ?? 0).toDouble(),
      abonadoCuota: (json["abonadoCuota"] ?? 0).toDouble(),
      estadoCuota: json["estadoCuota"] ?? "Al día",
    );
  }
}