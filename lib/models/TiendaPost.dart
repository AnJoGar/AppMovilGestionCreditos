class TiendaCreateDTO {
  String nombreTienda;
  String nombreEncargado;
  String telefono;
  String direccion;

  TiendaCreateDTO({
    required this.nombreTienda,
    required this.nombreEncargado,
    required this.telefono,
    required this.direccion,
  });

  Map<String, dynamic> toJson() => {
        'NombreTienda': nombreTienda,
        'NombreEncargado': nombreEncargado,
        'Telefono': telefono,
        'Direccion': direccion,
      };
}
