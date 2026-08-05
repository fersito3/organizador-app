class Conocido {
  final int id;
  final String nombre;
  final String apellido;
  final String? mpUserId;

  Conocido({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.mpUserId,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();
}
