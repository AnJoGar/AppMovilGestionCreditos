import 'package:intl/intl.dart';

class CreditoDTO {
  int id;
  double montoTotal;
  double entrada;
  int plazoCuotas;
  String frecuenciaPago;
  DateTime diaPago;

  double? valorPorCuota;
  double? montoPendiente;

  DateTime? proximaCuota;
  String? proximaCuotaStr;
  String? estado;
  int clienteId;
  DateTime? fechaCreacion;
  String? fechaCreacionStr; // <--- NUEVO CAMPO STRING
  int? tiendaId;

  // --- EVIDENCIAS ---
  String? fotoContratoUrl;
  String? fotoCelularUrl;

  // --- DATOS EQUIPO & ESTADO ---
  String? marca;
  String? modelo;
  double abonadoTotal;
  double abonadoCuota;
  String? estadoCuota;

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
    this.clienteId = 0,
    this.fechaCreacion,
    this.fechaCreacionStr, // Nuevo en constructor
    this.tiendaId,
    this.fotoContratoUrl,
    this.fotoCelularUrl,
    this.marca,
    this.modelo,
    this.abonadoTotal = 0.0,
    this.abonadoCuota = 0.0,
    this.estadoCuota,
  });

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
      clienteId: json['ClienteId'] ?? 0,
      fechaCreacion: parseDate(json['FechaCreacion']),
      fechaCreacionStr: json['fechaCreacionStr'], // Mapeo String
      tiendaId: json['TiendaId'],

      fotoContratoUrl: json['FotoContrato'],
      fotoCelularUrl: json['FotoCelularEntregadoUrl'],

      marca: json['Marca'],
      modelo: json['Modelo'],
      abonadoTotal: (json['AbonadoTotal'] ?? 0).toDouble(),
      abonadoCuota: (json['AbonadoCuota'] ?? 0).toDouble(),
      estadoCuota: json['EstadoCuota'],
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Entrada': entrada,
    'MontoTotal': montoTotal,
    'MontoPendiente': montoPendiente ?? 0,
    'PlazoCuotas': plazoCuotas,
    'FrecuenciaPago': frecuenciaPago,
    'DiaPago': diaPago.toUtc().toIso8601String(),
    'ValorPorCuota': valorPorCuota ?? 0,
    'ProximaCuota': proximaCuota?.toUtc().toIso8601String(),
    'ProximaCuotaStr': proximaCuotaStr ?? '',
    'Estado': estado ?? '',
    'FechaCreacion': fechaCreacion?.toUtc().toIso8601String(),
    'fechaCreacionStr': fechaCreacionStr, // Envío String
    'ClienteId': clienteId,
    'TiendaId': tiendaId,

    'FotoContrato': fotoContratoUrl,
    'FotoCelularEntregadoUrl': fotoCelularUrl,
    'Marca': marca,
    'Modelo': modelo,
    'AbonadoTotal': abonadoTotal,
    'AbonadoCuota': abonadoCuota,
    'EstadoCuota': estadoCuota,
  };
}