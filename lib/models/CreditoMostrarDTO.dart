import '../models/tiendaMostrar_dto.dart';

class CreditoMostrarDTO {
  final int id;
  final double montoPendiente;
  final String proximaCuotaStr;
  final int plazoCuotas;
  final double valorPorCuota;
  final String estado;
  final int clienteId;
  final tiendaMostrar_dto? tienda;

  CreditoMostrarDTO({
    required this.id,
    required this.montoPendiente,
    required this.proximaCuotaStr,
    required this.plazoCuotas,
    required this.valorPorCuota,
    required this.estado,
    required this.clienteId,
    this.tienda,
  });

  factory CreditoMostrarDTO.fromJson(Map<String, dynamic> json) {
    return CreditoMostrarDTO(
      id: json["id"] ?? 0,
      montoPendiente: (json["montoPendiente"] ?? 0).toDouble(),
      proximaCuotaStr: json["proximaCuotaStr"] ?? "",
      plazoCuotas: (json["plazoCuotas"] ?? 0).toInt(),
      valorPorCuota: (json["valorPorCuota"] ?? 0).toDouble(),
      estado: json["estado"] ?? "",
      clienteId: (json["clienteId"] ?? 0).toInt(),
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
      montoPendiente: montoPendiente ?? this.montoPendiente,
      proximaCuotaStr: proximaCuotaStr ?? this.proximaCuotaStr,
      plazoCuotas: this.plazoCuotas,
      valorPorCuota: this.valorPorCuota,
      estado: estado ?? this.estado,
      clienteId: this.clienteId,
      tienda: tienda ?? this.tienda,
    );
  }

}