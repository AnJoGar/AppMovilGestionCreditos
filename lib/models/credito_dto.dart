import 'package:intl/intl.dart';

/*
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
  int? tiendaId; 
  DateTime? fechaCreacion;

  // --- NUEVOS CAMPOS ---
  String? fotoContratoUrl;
  String? fotoCelularUrl;


  String marca;
 String modelo;
   double? abonadoTotal;
 double? abonadoCuota; // Cuánto ha pagado de la cuota actual
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
    this.tiendaId = 0,
    this.fechaCreacion,
    this.fotoContratoUrl, // Nuevo
    this.fotoCelularUrl,
    required this.marca,
    required this.modelo,
    this.abonadoTotal,
    this.abonadoCuota,
    this.estadoCuota,

  });

  // ------------------- FROM JSON -------------------
  factory CreditoDTO.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is String) return DateTime.parse(date);
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    return CreditoDTO(
    id: json['id'] ?? 0,
    montoTotal: (json['montoTotal'] ?? 0).toDouble(),
    entrada: (json['entrada'] ?? 0).toDouble(),
    plazoCuotas: json['plazoCuotas'] ?? 0,
    frecuenciaPago: json['frecuenciaPago'] ?? '',
    diaPago: parseDate(json['diaPago']),
    valorPorCuota: (json['valorPorCuota'] ?? 0).toDouble(),
    montoPendiente: (json['montoPendiente'] ?? 0).toDouble(),
    proximaCuota: parseDate(json['proximaCuota']),
    proximaCuotaStr: json['proximaCuotaStr'] ?? '',
    estado: json['estado'] ?? '',
    clienteId: json['clienteId'] ?? 0,
    tiendaId: json['tiendaId'] ?? 0,
    fechaCreacion: parseDate(json['fechaCreacion']),
    fotoContratoUrl: json['fotoContrato'] ?? '',
    fotoCelularUrl: json['fotoCelularEntregadoUrl'] ?? '',
    marca: json['marca'] ?? '',
    modelo: json['modelo'] ?? '',
    abonadoTotal: (json['abonadoTotal'] ?? 0).toDouble(),
    abonadoCuota: (json['abonadoCuota'] ?? 0).toDouble(),
    estadoCuota: json['estadoCuota'] ?? '',
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
      'ClienteId': clienteId,
      'TiendaId': tiendaId,
    'FotoContrato': fotoContratoUrl,
    'FotoCelularEntregadoUrl': fotoCelularUrl,
    'Marca': marca,
    'Modelo': modelo,

    'AbonadoTotal': abonadoTotal ?? 0,
    'AbonadoCuota': abonadoCuota ?? 0,
    'EstadoCuota': estadoCuota,
      };
}
 */

class CreditoDTO {
  int id;
  bool? esVentaContado;
  String? metodoPago;
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
  int? tiendaAppId;
  DateTime? fechaCreacion;

  // --- NUEVOS CAMPOS ---
  String? fotoContratoUrl;
  String? fotoCelularUrl;

  String marca;
  String modelo;
  double? abonadoTotal;
  double? abonadoCuota; // Cuánto ha pagado de la cuota actual
  String? estadoCuota;

  // --- CAMPOS AGREGADOS
  String tipoProducto;
  String nombrePropietario;
  String? imei;
  int? capacidad;

  CreditoDTO({
    this.id = 0,
    this.esVentaContado = false, // 🔥 Por defecto es crédito
    this.metodoPago,
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
    this.tiendaAppId = 0,
    this.fechaCreacion,
    this.fotoContratoUrl,
    this.fotoCelularUrl,
    required this.marca,
    required this.modelo,
    this.abonadoTotal,
    this.abonadoCuota,
    this.estadoCuota,
    // Inicializamos los nuevos campos
    this.tipoProducto = 'Teléfono',
    this.imei,
    required this.nombrePropietario,
    this.capacidad,
  });

  // ------------------- FROM JSON -------------------
  factory CreditoDTO.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is String) return DateTime.parse(date);
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    return CreditoDTO(
      id: json['id'] ?? 0,
      esVentaContado: json['esVentaContado'] ?? false,
      metodoPago: json['metodoPago'],
      montoTotal: (json['montoTotal'] ?? 0).toDouble(),
      entrada: (json['entrada'] ?? 0).toDouble(),
      plazoCuotas: json['plazoCuotas'] ?? 0,
      frecuenciaPago: json['frecuenciaPago'] ?? '',
      diaPago: parseDate(json['diaPago']),
      valorPorCuota: (json['valorPorCuota'] ?? 0).toDouble(),
      montoPendiente: (json['montoPendiente'] ?? 0).toDouble(),
      proximaCuota: parseDate(json['proximaCuota']),
      proximaCuotaStr: json['proximaCuotaStr'] ?? '',
      estado: json['estado'] ?? '',
      clienteId: json['clienteId'] ?? 0,
      tiendaAppId: json['tiendaAppId'] ?? 0,
      fechaCreacion: parseDate(json['fechaCreacion']),
      fotoContratoUrl: json['fotoContrato'] ?? '',
      fotoCelularUrl: json['fotoCelularEntregadoUrl'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      abonadoTotal: (json['abonadoTotal'] ?? 0).toDouble(),
      abonadoCuota: (json['abonadoCuota'] ?? 0).toDouble(),
      estadoCuota: json['estadoCuota'] ?? '',

      // Mapeo nuevos campos
      tipoProducto: json['tipoProducto'] ?? 'Teléfono',
      imei: json['imei'],
      nombrePropietario: json['nombrePropietario'] ?? '',
      capacidad: json['Capacidad'],
    );
  }

  // ------------------- TO JSON -------------------
  Map<String, dynamic> toJson() => {
    'Id': id,
    'EsVentaContado': esVentaContado, // 🔥 Enviamos el booleano al servidor
    'MetodoPago': metodoPago,
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
    'ClienteId': clienteId,
    'TiendaAppId': tiendaAppId,
    'FotoContrato': fotoContratoUrl,
    'FotoCelularEntregadoUrl': fotoCelularUrl,
    'Marca': marca,
    'Modelo': modelo,
    'AbonadoTotal': abonadoTotal ?? 0,
    'AbonadoCuota': abonadoCuota ?? 0,
    'EstadoCuota': estadoCuota,

    // Serialización nuevos campos
    'TipoProducto': tipoProducto,
    'Imei': imei,
    'nombrePropietario': nombrePropietario,
    'Capacidad': capacidad,
  };
}