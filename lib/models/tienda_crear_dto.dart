class TiendaCrearDTO {
  int id;
  String nombreTienda;
  String nombreEncargado;
  String telefono;
  String direccion;
  DateTime? fechaRegistro;


  TiendaCrearDTO({
    this.id = 0,
    required this.nombreTienda,
    required this.nombreEncargado,
    required this.telefono,
    required this.direccion,
    this.fechaRegistro
  });

// ------------------- FROM JSON -------------------
  factory TiendaCrearDTO.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is String) return DateTime.parse(date);
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    return TiendaCrearDTO(
      id: json['Id'] ?? 0,
      nombreTienda: json['NombreTienda'] ?? '',
      nombreEncargado: json['NombreEncargado'] ?? '',
      telefono: json['Telefono'] ?? '',
      direccion: json['Direccion'] ?? '',
      fechaRegistro: parseDate(json['FechaRegistro']),
    );
  }

  // ------------------- TO JSON -------------------
  Map<String, dynamic> toJson() => {
    'Id': id,
    'NombreTienda': nombreTienda,
    'NombreEncargado': nombreEncargado,
    'Telefono': telefono,
    'Direccion': direccion,
    //       'FechaRegistro': fechaRegistro.toIso8601String(),

  };
}