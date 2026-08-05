// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriasTable extends Categorias
    with TableInfo<$CategoriasTable, Categoria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 6,
      maxTextLength: 9,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoTransaccion, int> tipo =
      GeneratedColumn<int>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TipoTransaccion>($CategoriasTable.$convertertipo);
  @override
  List<GeneratedColumn> get $columns => [id, nombre, colorHex, tipo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Categoria> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Categoria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Categoria(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      tipo: $CategoriasTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}tipo'],
        )!,
      ),
    );
  }

  @override
  $CategoriasTable createAlias(String alias) {
    return $CategoriasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoTransaccion, int, int> $convertertipo =
      const EnumIndexConverter<TipoTransaccion>(TipoTransaccion.values);
}

class Categoria extends DataClass implements Insertable<Categoria> {
  final int id;
  final String nombre;
  final String colorHex;
  final TipoTransaccion tipo;
  const Categoria({
    required this.id,
    required this.nombre,
    required this.colorHex,
    required this.tipo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['color_hex'] = Variable<String>(colorHex);
    {
      map['tipo'] = Variable<int>($CategoriasTable.$convertertipo.toSql(tipo));
    }
    return map;
  }

  CategoriasCompanion toCompanion(bool nullToAbsent) {
    return CategoriasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      colorHex: Value(colorHex),
      tipo: Value(tipo),
    );
  }

  factory Categoria.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Categoria(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      tipo: $CategoriasTable.$convertertipo.fromJson(
        serializer.fromJson<int>(json['tipo']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'colorHex': serializer.toJson<String>(colorHex),
      'tipo': serializer.toJson<int>(
        $CategoriasTable.$convertertipo.toJson(tipo),
      ),
    };
  }

  Categoria copyWith({
    int? id,
    String? nombre,
    String? colorHex,
    TipoTransaccion? tipo,
  }) => Categoria(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    colorHex: colorHex ?? this.colorHex,
    tipo: tipo ?? this.tipo,
  );
  Categoria copyWithCompanion(CategoriasCompanion data) {
    return Categoria(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Categoria(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('colorHex: $colorHex, ')
          ..write('tipo: $tipo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, colorHex, tipo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Categoria &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.colorHex == this.colorHex &&
          other.tipo == this.tipo);
}

class CategoriasCompanion extends UpdateCompanion<Categoria> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String> colorHex;
  final Value<TipoTransaccion> tipo;
  const CategoriasCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.tipo = const Value.absent(),
  });
  CategoriasCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required String colorHex,
    required TipoTransaccion tipo,
  }) : nombre = Value(nombre),
       colorHex = Value(colorHex),
       tipo = Value(tipo);
  static Insertable<Categoria> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? colorHex,
    Expression<int>? tipo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (colorHex != null) 'color_hex': colorHex,
      if (tipo != null) 'tipo': tipo,
    });
  }

  CategoriasCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String>? colorHex,
    Value<TipoTransaccion>? tipo,
  }) {
    return CategoriasCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      colorHex: colorHex ?? this.colorHex,
      tipo: tipo ?? this.tipo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<int>(
        $CategoriasTable.$convertertipo.toSql(tipo.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriasCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('colorHex: $colorHex, ')
          ..write('tipo: $tipo')
          ..write(')'))
        .toString();
  }
}

class $ConocidosTable extends Conocidos
    with TableInfo<$ConocidosTable, Conocido> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConocidosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _apellidoMeta = const VerificationMeta(
    'apellido',
  );
  @override
  late final GeneratedColumn<String> apellido = GeneratedColumn<String>(
    'apellido',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mpUserIdMeta = const VerificationMeta(
    'mpUserId',
  );
  @override
  late final GeneratedColumn<String> mpUserId = GeneratedColumn<String>(
    'mp_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, nombre, apellido, mpUserId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conocidos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conocido> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('apellido')) {
      context.handle(
        _apellidoMeta,
        apellido.isAcceptableOrUnknown(data['apellido']!, _apellidoMeta),
      );
    } else if (isInserting) {
      context.missing(_apellidoMeta);
    }
    if (data.containsKey('mp_user_id')) {
      context.handle(
        _mpUserIdMeta,
        mpUserId.isAcceptableOrUnknown(data['mp_user_id']!, _mpUserIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conocido map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conocido(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      apellido: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apellido'],
      )!,
      mpUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mp_user_id'],
      ),
    );
  }

  @override
  $ConocidosTable createAlias(String alias) {
    return $ConocidosTable(attachedDatabase, alias);
  }
}

class Conocido extends DataClass implements Insertable<Conocido> {
  final int id;
  final String nombre;
  final String apellido;
  final String? mpUserId;
  const Conocido({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.mpUserId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['apellido'] = Variable<String>(apellido);
    if (!nullToAbsent || mpUserId != null) {
      map['mp_user_id'] = Variable<String>(mpUserId);
    }
    return map;
  }

  ConocidosCompanion toCompanion(bool nullToAbsent) {
    return ConocidosCompanion(
      id: Value(id),
      nombre: Value(nombre),
      apellido: Value(apellido),
      mpUserId: mpUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(mpUserId),
    );
  }

  factory Conocido.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conocido(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      apellido: serializer.fromJson<String>(json['apellido']),
      mpUserId: serializer.fromJson<String?>(json['mpUserId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'apellido': serializer.toJson<String>(apellido),
      'mpUserId': serializer.toJson<String?>(mpUserId),
    };
  }

  Conocido copyWith({
    int? id,
    String? nombre,
    String? apellido,
    Value<String?> mpUserId = const Value.absent(),
  }) => Conocido(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    apellido: apellido ?? this.apellido,
    mpUserId: mpUserId.present ? mpUserId.value : this.mpUserId,
  );
  Conocido copyWithCompanion(ConocidosCompanion data) {
    return Conocido(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      apellido: data.apellido.present ? data.apellido.value : this.apellido,
      mpUserId: data.mpUserId.present ? data.mpUserId.value : this.mpUserId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conocido(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('apellido: $apellido, ')
          ..write('mpUserId: $mpUserId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, apellido, mpUserId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conocido &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.apellido == this.apellido &&
          other.mpUserId == this.mpUserId);
}

class ConocidosCompanion extends UpdateCompanion<Conocido> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String> apellido;
  final Value<String?> mpUserId;
  const ConocidosCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.apellido = const Value.absent(),
    this.mpUserId = const Value.absent(),
  });
  ConocidosCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required String apellido,
    this.mpUserId = const Value.absent(),
  }) : nombre = Value(nombre),
       apellido = Value(apellido);
  static Insertable<Conocido> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? apellido,
    Expression<String>? mpUserId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (apellido != null) 'apellido': apellido,
      if (mpUserId != null) 'mp_user_id': mpUserId,
    });
  }

  ConocidosCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String>? apellido,
    Value<String?>? mpUserId,
  }) {
    return ConocidosCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      mpUserId: mpUserId ?? this.mpUserId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (apellido.present) {
      map['apellido'] = Variable<String>(apellido.value);
    }
    if (mpUserId.present) {
      map['mp_user_id'] = Variable<String>(mpUserId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConocidosCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('apellido: $apellido, ')
          ..write('mpUserId: $mpUserId')
          ..write(')'))
        .toString();
  }
}

class $TransaccionesTable extends Transacciones
    with TableInfo<$TransaccionesTable, Transaccione> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransaccionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 150,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<double> monto = GeneratedColumn<double>(
    'monto',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoTransaccion, int> tipo =
      GeneratedColumn<int>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TipoTransaccion>($TransaccionesTable.$convertertipo);
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
    'categoria_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categorias (id)',
    ),
  );
  static const VerificationMeta _mpPaymentIdMeta = const VerificationMeta(
    'mpPaymentId',
  );
  @override
  late final GeneratedColumn<String> mpPaymentId = GeneratedColumn<String>(
    'mp_payment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proveedorMeta = const VerificationMeta(
    'proveedor',
  );
  @override
  late final GeneratedColumn<String> proveedor = GeneratedColumn<String>(
    'proveedor',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('MANUAL'),
  );
  static const VerificationMeta _conocidoIdMeta = const VerificationMeta(
    'conocidoId',
  );
  @override
  late final GeneratedColumn<int> conocidoId = GeneratedColumn<int>(
    'conocido_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES conocidos (id)',
    ),
  );
  static const VerificationMeta _contraparteMpIdMeta = const VerificationMeta(
    'contraparteMpId',
  );
  @override
  late final GeneratedColumn<String> contraparteMpId = GeneratedColumn<String>(
    'contraparte_mp_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    descripcion,
    monto,
    fecha,
    tipo,
    categoriaId,
    mpPaymentId,
    proveedor,
    conocidoId,
    contraparteMpId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transacciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaccione> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descripcionMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoriaIdMeta);
    }
    if (data.containsKey('mp_payment_id')) {
      context.handle(
        _mpPaymentIdMeta,
        mpPaymentId.isAcceptableOrUnknown(
          data['mp_payment_id']!,
          _mpPaymentIdMeta,
        ),
      );
    }
    if (data.containsKey('proveedor')) {
      context.handle(
        _proveedorMeta,
        proveedor.isAcceptableOrUnknown(data['proveedor']!, _proveedorMeta),
      );
    }
    if (data.containsKey('conocido_id')) {
      context.handle(
        _conocidoIdMeta,
        conocidoId.isAcceptableOrUnknown(data['conocido_id']!, _conocidoIdMeta),
      );
    }
    if (data.containsKey('contraparte_mp_id')) {
      context.handle(
        _contraparteMpIdMeta,
        contraparteMpId.isAcceptableOrUnknown(
          data['contraparte_mp_id']!,
          _contraparteMpIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaccione map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaccione(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      tipo: $TransaccionesTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_id'],
      )!,
      mpPaymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mp_payment_id'],
      ),
      proveedor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proveedor'],
      )!,
      conocidoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conocido_id'],
      ),
      contraparteMpId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contraparte_mp_id'],
      ),
    );
  }

  @override
  $TransaccionesTable createAlias(String alias) {
    return $TransaccionesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoTransaccion, int, int> $convertertipo =
      const EnumIndexConverter<TipoTransaccion>(TipoTransaccion.values);
}

class Transaccione extends DataClass implements Insertable<Transaccione> {
  final int id;
  final String descripcion;
  final double monto;
  final DateTime fecha;
  final TipoTransaccion tipo;
  final int categoriaId;
  final String? mpPaymentId;
  final String proveedor;
  final int? conocidoId;
  final String? contraparteMpId;
  const Transaccione({
    required this.id,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.tipo,
    required this.categoriaId,
    this.mpPaymentId,
    required this.proveedor,
    this.conocidoId,
    this.contraparteMpId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['descripcion'] = Variable<String>(descripcion);
    map['monto'] = Variable<double>(monto);
    map['fecha'] = Variable<DateTime>(fecha);
    {
      map['tipo'] = Variable<int>(
        $TransaccionesTable.$convertertipo.toSql(tipo),
      );
    }
    map['categoria_id'] = Variable<int>(categoriaId);
    if (!nullToAbsent || mpPaymentId != null) {
      map['mp_payment_id'] = Variable<String>(mpPaymentId);
    }
    map['proveedor'] = Variable<String>(proveedor);
    if (!nullToAbsent || conocidoId != null) {
      map['conocido_id'] = Variable<int>(conocidoId);
    }
    if (!nullToAbsent || contraparteMpId != null) {
      map['contraparte_mp_id'] = Variable<String>(contraparteMpId);
    }
    return map;
  }

  TransaccionesCompanion toCompanion(bool nullToAbsent) {
    return TransaccionesCompanion(
      id: Value(id),
      descripcion: Value(descripcion),
      monto: Value(monto),
      fecha: Value(fecha),
      tipo: Value(tipo),
      categoriaId: Value(categoriaId),
      mpPaymentId: mpPaymentId == null && nullToAbsent
          ? const Value.absent()
          : Value(mpPaymentId),
      proveedor: Value(proveedor),
      conocidoId: conocidoId == null && nullToAbsent
          ? const Value.absent()
          : Value(conocidoId),
      contraparteMpId: contraparteMpId == null && nullToAbsent
          ? const Value.absent()
          : Value(contraparteMpId),
    );
  }

  factory Transaccione.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaccione(
      id: serializer.fromJson<int>(json['id']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      monto: serializer.fromJson<double>(json['monto']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      tipo: $TransaccionesTable.$convertertipo.fromJson(
        serializer.fromJson<int>(json['tipo']),
      ),
      categoriaId: serializer.fromJson<int>(json['categoriaId']),
      mpPaymentId: serializer.fromJson<String?>(json['mpPaymentId']),
      proveedor: serializer.fromJson<String>(json['proveedor']),
      conocidoId: serializer.fromJson<int?>(json['conocidoId']),
      contraparteMpId: serializer.fromJson<String?>(json['contraparteMpId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'descripcion': serializer.toJson<String>(descripcion),
      'monto': serializer.toJson<double>(monto),
      'fecha': serializer.toJson<DateTime>(fecha),
      'tipo': serializer.toJson<int>(
        $TransaccionesTable.$convertertipo.toJson(tipo),
      ),
      'categoriaId': serializer.toJson<int>(categoriaId),
      'mpPaymentId': serializer.toJson<String?>(mpPaymentId),
      'proveedor': serializer.toJson<String>(proveedor),
      'conocidoId': serializer.toJson<int?>(conocidoId),
      'contraparteMpId': serializer.toJson<String?>(contraparteMpId),
    };
  }

  Transaccione copyWith({
    int? id,
    String? descripcion,
    double? monto,
    DateTime? fecha,
    TipoTransaccion? tipo,
    int? categoriaId,
    Value<String?> mpPaymentId = const Value.absent(),
    String? proveedor,
    Value<int?> conocidoId = const Value.absent(),
    Value<String?> contraparteMpId = const Value.absent(),
  }) => Transaccione(
    id: id ?? this.id,
    descripcion: descripcion ?? this.descripcion,
    monto: monto ?? this.monto,
    fecha: fecha ?? this.fecha,
    tipo: tipo ?? this.tipo,
    categoriaId: categoriaId ?? this.categoriaId,
    mpPaymentId: mpPaymentId.present ? mpPaymentId.value : this.mpPaymentId,
    proveedor: proveedor ?? this.proveedor,
    conocidoId: conocidoId.present ? conocidoId.value : this.conocidoId,
    contraparteMpId: contraparteMpId.present
        ? contraparteMpId.value
        : this.contraparteMpId,
  );
  Transaccione copyWithCompanion(TransaccionesCompanion data) {
    return Transaccione(
      id: data.id.present ? data.id.value : this.id,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      monto: data.monto.present ? data.monto.value : this.monto,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      mpPaymentId: data.mpPaymentId.present
          ? data.mpPaymentId.value
          : this.mpPaymentId,
      proveedor: data.proveedor.present ? data.proveedor.value : this.proveedor,
      conocidoId: data.conocidoId.present
          ? data.conocidoId.value
          : this.conocidoId,
      contraparteMpId: data.contraparteMpId.present
          ? data.contraparteMpId.value
          : this.contraparteMpId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaccione(')
          ..write('id: $id, ')
          ..write('descripcion: $descripcion, ')
          ..write('monto: $monto, ')
          ..write('fecha: $fecha, ')
          ..write('tipo: $tipo, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('mpPaymentId: $mpPaymentId, ')
          ..write('proveedor: $proveedor, ')
          ..write('conocidoId: $conocidoId, ')
          ..write('contraparteMpId: $contraparteMpId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    descripcion,
    monto,
    fecha,
    tipo,
    categoriaId,
    mpPaymentId,
    proveedor,
    conocidoId,
    contraparteMpId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaccione &&
          other.id == this.id &&
          other.descripcion == this.descripcion &&
          other.monto == this.monto &&
          other.fecha == this.fecha &&
          other.tipo == this.tipo &&
          other.categoriaId == this.categoriaId &&
          other.mpPaymentId == this.mpPaymentId &&
          other.proveedor == this.proveedor &&
          other.conocidoId == this.conocidoId &&
          other.contraparteMpId == this.contraparteMpId);
}

class TransaccionesCompanion extends UpdateCompanion<Transaccione> {
  final Value<int> id;
  final Value<String> descripcion;
  final Value<double> monto;
  final Value<DateTime> fecha;
  final Value<TipoTransaccion> tipo;
  final Value<int> categoriaId;
  final Value<String?> mpPaymentId;
  final Value<String> proveedor;
  final Value<int?> conocidoId;
  final Value<String?> contraparteMpId;
  const TransaccionesCompanion({
    this.id = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.monto = const Value.absent(),
    this.fecha = const Value.absent(),
    this.tipo = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.mpPaymentId = const Value.absent(),
    this.proveedor = const Value.absent(),
    this.conocidoId = const Value.absent(),
    this.contraparteMpId = const Value.absent(),
  });
  TransaccionesCompanion.insert({
    this.id = const Value.absent(),
    required String descripcion,
    required double monto,
    required DateTime fecha,
    required TipoTransaccion tipo,
    required int categoriaId,
    this.mpPaymentId = const Value.absent(),
    this.proveedor = const Value.absent(),
    this.conocidoId = const Value.absent(),
    this.contraparteMpId = const Value.absent(),
  }) : descripcion = Value(descripcion),
       monto = Value(monto),
       fecha = Value(fecha),
       tipo = Value(tipo),
       categoriaId = Value(categoriaId);
  static Insertable<Transaccione> custom({
    Expression<int>? id,
    Expression<String>? descripcion,
    Expression<double>? monto,
    Expression<DateTime>? fecha,
    Expression<int>? tipo,
    Expression<int>? categoriaId,
    Expression<String>? mpPaymentId,
    Expression<String>? proveedor,
    Expression<int>? conocidoId,
    Expression<String>? contraparteMpId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (descripcion != null) 'descripcion': descripcion,
      if (monto != null) 'monto': monto,
      if (fecha != null) 'fecha': fecha,
      if (tipo != null) 'tipo': tipo,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (mpPaymentId != null) 'mp_payment_id': mpPaymentId,
      if (proveedor != null) 'proveedor': proveedor,
      if (conocidoId != null) 'conocido_id': conocidoId,
      if (contraparteMpId != null) 'contraparte_mp_id': contraparteMpId,
    });
  }

  TransaccionesCompanion copyWith({
    Value<int>? id,
    Value<String>? descripcion,
    Value<double>? monto,
    Value<DateTime>? fecha,
    Value<TipoTransaccion>? tipo,
    Value<int>? categoriaId,
    Value<String?>? mpPaymentId,
    Value<String>? proveedor,
    Value<int?>? conocidoId,
    Value<String?>? contraparteMpId,
  }) {
    return TransaccionesCompanion(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      categoriaId: categoriaId ?? this.categoriaId,
      mpPaymentId: mpPaymentId ?? this.mpPaymentId,
      proveedor: proveedor ?? this.proveedor,
      conocidoId: conocidoId ?? this.conocidoId,
      contraparteMpId: contraparteMpId ?? this.contraparteMpId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (monto.present) {
      map['monto'] = Variable<double>(monto.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<int>(
        $TransaccionesTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (mpPaymentId.present) {
      map['mp_payment_id'] = Variable<String>(mpPaymentId.value);
    }
    if (proveedor.present) {
      map['proveedor'] = Variable<String>(proveedor.value);
    }
    if (conocidoId.present) {
      map['conocido_id'] = Variable<int>(conocidoId.value);
    }
    if (contraparteMpId.present) {
      map['contraparte_mp_id'] = Variable<String>(contraparteMpId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransaccionesCompanion(')
          ..write('id: $id, ')
          ..write('descripcion: $descripcion, ')
          ..write('monto: $monto, ')
          ..write('fecha: $fecha, ')
          ..write('tipo: $tipo, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('mpPaymentId: $mpPaymentId, ')
          ..write('proveedor: $proveedor, ')
          ..write('conocidoId: $conocidoId, ')
          ..write('contraparteMpId: $contraparteMpId')
          ..write(')'))
        .toString();
  }
}

class $EventosTable extends Eventos with TableInfo<$EventosTable, Evento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaInicioMeta = const VerificationMeta(
    'fechaInicio',
  );
  @override
  late final GeneratedColumn<DateTime> fechaInicio = GeneratedColumn<DateTime>(
    'fecha_inicio',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaFinMeta = const VerificationMeta(
    'fechaFin',
  );
  @override
  late final GeneratedColumn<DateTime> fechaFin = GeneratedColumn<DateTime>(
    'fecha_fin',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _esRecurrenteMeta = const VerificationMeta(
    'esRecurrente',
  );
  @override
  late final GeneratedColumn<bool> esRecurrente = GeneratedColumn<bool>(
    'es_recurrente',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("es_recurrente" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _patronRecurrenciaMeta = const VerificationMeta(
    'patronRecurrencia',
  );
  @override
  late final GeneratedColumn<String> patronRecurrencia =
      GeneratedColumn<String>(
        'patron_recurrencia',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _transaccionIdMeta = const VerificationMeta(
    'transaccionId',
  );
  @override
  late final GeneratedColumn<int> transaccionId = GeneratedColumn<int>(
    'transaccion_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transacciones (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    titulo,
    descripcion,
    fechaInicio,
    fechaFin,
    esRecurrente,
    patronRecurrencia,
    transaccionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'eventos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Evento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('fecha_inicio')) {
      context.handle(
        _fechaInicioMeta,
        fechaInicio.isAcceptableOrUnknown(
          data['fecha_inicio']!,
          _fechaInicioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaInicioMeta);
    }
    if (data.containsKey('fecha_fin')) {
      context.handle(
        _fechaFinMeta,
        fechaFin.isAcceptableOrUnknown(data['fecha_fin']!, _fechaFinMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaFinMeta);
    }
    if (data.containsKey('es_recurrente')) {
      context.handle(
        _esRecurrenteMeta,
        esRecurrente.isAcceptableOrUnknown(
          data['es_recurrente']!,
          _esRecurrenteMeta,
        ),
      );
    }
    if (data.containsKey('patron_recurrencia')) {
      context.handle(
        _patronRecurrenciaMeta,
        patronRecurrencia.isAcceptableOrUnknown(
          data['patron_recurrencia']!,
          _patronRecurrenciaMeta,
        ),
      );
    }
    if (data.containsKey('transaccion_id')) {
      context.handle(
        _transaccionIdMeta,
        transaccionId.isAcceptableOrUnknown(
          data['transaccion_id']!,
          _transaccionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Evento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Evento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      ),
      fechaInicio: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_inicio'],
      )!,
      fechaFin: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_fin'],
      )!,
      esRecurrente: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}es_recurrente'],
      )!,
      patronRecurrencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patron_recurrencia'],
      ),
      transaccionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaccion_id'],
      ),
    );
  }

  @override
  $EventosTable createAlias(String alias) {
    return $EventosTable(attachedDatabase, alias);
  }
}

class Evento extends DataClass implements Insertable<Evento> {
  final int id;
  final String titulo;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool esRecurrente;
  final String? patronRecurrencia;
  final int? transaccionId;
  const Evento({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.esRecurrente,
    this.patronRecurrencia,
    this.transaccionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['titulo'] = Variable<String>(titulo);
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    map['fecha_inicio'] = Variable<DateTime>(fechaInicio);
    map['fecha_fin'] = Variable<DateTime>(fechaFin);
    map['es_recurrente'] = Variable<bool>(esRecurrente);
    if (!nullToAbsent || patronRecurrencia != null) {
      map['patron_recurrencia'] = Variable<String>(patronRecurrencia);
    }
    if (!nullToAbsent || transaccionId != null) {
      map['transaccion_id'] = Variable<int>(transaccionId);
    }
    return map;
  }

  EventosCompanion toCompanion(bool nullToAbsent) {
    return EventosCompanion(
      id: Value(id),
      titulo: Value(titulo),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      fechaInicio: Value(fechaInicio),
      fechaFin: Value(fechaFin),
      esRecurrente: Value(esRecurrente),
      patronRecurrencia: patronRecurrencia == null && nullToAbsent
          ? const Value.absent()
          : Value(patronRecurrencia),
      transaccionId: transaccionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transaccionId),
    );
  }

  factory Evento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Evento(
      id: serializer.fromJson<int>(json['id']),
      titulo: serializer.fromJson<String>(json['titulo']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      fechaInicio: serializer.fromJson<DateTime>(json['fechaInicio']),
      fechaFin: serializer.fromJson<DateTime>(json['fechaFin']),
      esRecurrente: serializer.fromJson<bool>(json['esRecurrente']),
      patronRecurrencia: serializer.fromJson<String?>(
        json['patronRecurrencia'],
      ),
      transaccionId: serializer.fromJson<int?>(json['transaccionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'titulo': serializer.toJson<String>(titulo),
      'descripcion': serializer.toJson<String?>(descripcion),
      'fechaInicio': serializer.toJson<DateTime>(fechaInicio),
      'fechaFin': serializer.toJson<DateTime>(fechaFin),
      'esRecurrente': serializer.toJson<bool>(esRecurrente),
      'patronRecurrencia': serializer.toJson<String?>(patronRecurrencia),
      'transaccionId': serializer.toJson<int?>(transaccionId),
    };
  }

  Evento copyWith({
    int? id,
    String? titulo,
    Value<String?> descripcion = const Value.absent(),
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool? esRecurrente,
    Value<String?> patronRecurrencia = const Value.absent(),
    Value<int?> transaccionId = const Value.absent(),
  }) => Evento(
    id: id ?? this.id,
    titulo: titulo ?? this.titulo,
    descripcion: descripcion.present ? descripcion.value : this.descripcion,
    fechaInicio: fechaInicio ?? this.fechaInicio,
    fechaFin: fechaFin ?? this.fechaFin,
    esRecurrente: esRecurrente ?? this.esRecurrente,
    patronRecurrencia: patronRecurrencia.present
        ? patronRecurrencia.value
        : this.patronRecurrencia,
    transaccionId: transaccionId.present
        ? transaccionId.value
        : this.transaccionId,
  );
  Evento copyWithCompanion(EventosCompanion data) {
    return Evento(
      id: data.id.present ? data.id.value : this.id,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      fechaInicio: data.fechaInicio.present
          ? data.fechaInicio.value
          : this.fechaInicio,
      fechaFin: data.fechaFin.present ? data.fechaFin.value : this.fechaFin,
      esRecurrente: data.esRecurrente.present
          ? data.esRecurrente.value
          : this.esRecurrente,
      patronRecurrencia: data.patronRecurrencia.present
          ? data.patronRecurrencia.value
          : this.patronRecurrencia,
      transaccionId: data.transaccionId.present
          ? data.transaccionId.value
          : this.transaccionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Evento(')
          ..write('id: $id, ')
          ..write('titulo: $titulo, ')
          ..write('descripcion: $descripcion, ')
          ..write('fechaInicio: $fechaInicio, ')
          ..write('fechaFin: $fechaFin, ')
          ..write('esRecurrente: $esRecurrente, ')
          ..write('patronRecurrencia: $patronRecurrencia, ')
          ..write('transaccionId: $transaccionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    titulo,
    descripcion,
    fechaInicio,
    fechaFin,
    esRecurrente,
    patronRecurrencia,
    transaccionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Evento &&
          other.id == this.id &&
          other.titulo == this.titulo &&
          other.descripcion == this.descripcion &&
          other.fechaInicio == this.fechaInicio &&
          other.fechaFin == this.fechaFin &&
          other.esRecurrente == this.esRecurrente &&
          other.patronRecurrencia == this.patronRecurrencia &&
          other.transaccionId == this.transaccionId);
}

class EventosCompanion extends UpdateCompanion<Evento> {
  final Value<int> id;
  final Value<String> titulo;
  final Value<String?> descripcion;
  final Value<DateTime> fechaInicio;
  final Value<DateTime> fechaFin;
  final Value<bool> esRecurrente;
  final Value<String?> patronRecurrencia;
  final Value<int?> transaccionId;
  const EventosCompanion({
    this.id = const Value.absent(),
    this.titulo = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.fechaInicio = const Value.absent(),
    this.fechaFin = const Value.absent(),
    this.esRecurrente = const Value.absent(),
    this.patronRecurrencia = const Value.absent(),
    this.transaccionId = const Value.absent(),
  });
  EventosCompanion.insert({
    this.id = const Value.absent(),
    required String titulo,
    this.descripcion = const Value.absent(),
    required DateTime fechaInicio,
    required DateTime fechaFin,
    this.esRecurrente = const Value.absent(),
    this.patronRecurrencia = const Value.absent(),
    this.transaccionId = const Value.absent(),
  }) : titulo = Value(titulo),
       fechaInicio = Value(fechaInicio),
       fechaFin = Value(fechaFin);
  static Insertable<Evento> custom({
    Expression<int>? id,
    Expression<String>? titulo,
    Expression<String>? descripcion,
    Expression<DateTime>? fechaInicio,
    Expression<DateTime>? fechaFin,
    Expression<bool>? esRecurrente,
    Expression<String>? patronRecurrencia,
    Expression<int>? transaccionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titulo != null) 'titulo': titulo,
      if (descripcion != null) 'descripcion': descripcion,
      if (fechaInicio != null) 'fecha_inicio': fechaInicio,
      if (fechaFin != null) 'fecha_fin': fechaFin,
      if (esRecurrente != null) 'es_recurrente': esRecurrente,
      if (patronRecurrencia != null) 'patron_recurrencia': patronRecurrencia,
      if (transaccionId != null) 'transaccion_id': transaccionId,
    });
  }

  EventosCompanion copyWith({
    Value<int>? id,
    Value<String>? titulo,
    Value<String?>? descripcion,
    Value<DateTime>? fechaInicio,
    Value<DateTime>? fechaFin,
    Value<bool>? esRecurrente,
    Value<String?>? patronRecurrencia,
    Value<int?>? transaccionId,
  }) {
    return EventosCompanion(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      esRecurrente: esRecurrente ?? this.esRecurrente,
      patronRecurrencia: patronRecurrencia ?? this.patronRecurrencia,
      transaccionId: transaccionId ?? this.transaccionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (fechaInicio.present) {
      map['fecha_inicio'] = Variable<DateTime>(fechaInicio.value);
    }
    if (fechaFin.present) {
      map['fecha_fin'] = Variable<DateTime>(fechaFin.value);
    }
    if (esRecurrente.present) {
      map['es_recurrente'] = Variable<bool>(esRecurrente.value);
    }
    if (patronRecurrencia.present) {
      map['patron_recurrencia'] = Variable<String>(patronRecurrencia.value);
    }
    if (transaccionId.present) {
      map['transaccion_id'] = Variable<int>(transaccionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventosCompanion(')
          ..write('id: $id, ')
          ..write('titulo: $titulo, ')
          ..write('descripcion: $descripcion, ')
          ..write('fechaInicio: $fechaInicio, ')
          ..write('fechaFin: $fechaFin, ')
          ..write('esRecurrente: $esRecurrente, ')
          ..write('patronRecurrencia: $patronRecurrencia, ')
          ..write('transaccionId: $transaccionId')
          ..write(')'))
        .toString();
  }
}

class $TareasTable extends Tareas with TableInfo<$TareasTable, Tarea> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TareasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoTarea, int> tipo =
      GeneratedColumn<int>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TipoTarea>($TareasTable.$convertertipo);
  static const VerificationMeta _completadaMeta = const VerificationMeta(
    'completada',
  );
  @override
  late final GeneratedColumn<bool> completada = GeneratedColumn<bool>(
    'completada',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completada" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _eventoIdMeta = const VerificationMeta(
    'eventoId',
  );
  @override
  late final GeneratedColumn<int> eventoId = GeneratedColumn<int>(
    'evento_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES eventos (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    titulo,
    descripcion,
    fecha,
    tipo,
    completada,
    eventoId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tareas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tarea> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('completada')) {
      context.handle(
        _completadaMeta,
        completada.isAcceptableOrUnknown(data['completada']!, _completadaMeta),
      );
    }
    if (data.containsKey('evento_id')) {
      context.handle(
        _eventoIdMeta,
        eventoId.isAcceptableOrUnknown(data['evento_id']!, _eventoIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tarea map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tarea(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      ),
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      tipo: $TareasTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      completada: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completada'],
      )!,
      eventoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}evento_id'],
      ),
    );
  }

  @override
  $TareasTable createAlias(String alias) {
    return $TareasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoTarea, int, int> $convertertipo =
      const EnumIndexConverter<TipoTarea>(TipoTarea.values);
}

class Tarea extends DataClass implements Insertable<Tarea> {
  final int id;
  final String titulo;
  final String? descripcion;
  final DateTime fecha;
  final TipoTarea tipo;
  final bool completada;
  final int? eventoId;
  const Tarea({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.fecha,
    required this.tipo,
    required this.completada,
    this.eventoId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['titulo'] = Variable<String>(titulo);
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    map['fecha'] = Variable<DateTime>(fecha);
    {
      map['tipo'] = Variable<int>($TareasTable.$convertertipo.toSql(tipo));
    }
    map['completada'] = Variable<bool>(completada);
    if (!nullToAbsent || eventoId != null) {
      map['evento_id'] = Variable<int>(eventoId);
    }
    return map;
  }

  TareasCompanion toCompanion(bool nullToAbsent) {
    return TareasCompanion(
      id: Value(id),
      titulo: Value(titulo),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      fecha: Value(fecha),
      tipo: Value(tipo),
      completada: Value(completada),
      eventoId: eventoId == null && nullToAbsent
          ? const Value.absent()
          : Value(eventoId),
    );
  }

  factory Tarea.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tarea(
      id: serializer.fromJson<int>(json['id']),
      titulo: serializer.fromJson<String>(json['titulo']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      tipo: $TareasTable.$convertertipo.fromJson(
        serializer.fromJson<int>(json['tipo']),
      ),
      completada: serializer.fromJson<bool>(json['completada']),
      eventoId: serializer.fromJson<int?>(json['eventoId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'titulo': serializer.toJson<String>(titulo),
      'descripcion': serializer.toJson<String?>(descripcion),
      'fecha': serializer.toJson<DateTime>(fecha),
      'tipo': serializer.toJson<int>($TareasTable.$convertertipo.toJson(tipo)),
      'completada': serializer.toJson<bool>(completada),
      'eventoId': serializer.toJson<int?>(eventoId),
    };
  }

  Tarea copyWith({
    int? id,
    String? titulo,
    Value<String?> descripcion = const Value.absent(),
    DateTime? fecha,
    TipoTarea? tipo,
    bool? completada,
    Value<int?> eventoId = const Value.absent(),
  }) => Tarea(
    id: id ?? this.id,
    titulo: titulo ?? this.titulo,
    descripcion: descripcion.present ? descripcion.value : this.descripcion,
    fecha: fecha ?? this.fecha,
    tipo: tipo ?? this.tipo,
    completada: completada ?? this.completada,
    eventoId: eventoId.present ? eventoId.value : this.eventoId,
  );
  Tarea copyWithCompanion(TareasCompanion data) {
    return Tarea(
      id: data.id.present ? data.id.value : this.id,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      completada: data.completada.present
          ? data.completada.value
          : this.completada,
      eventoId: data.eventoId.present ? data.eventoId.value : this.eventoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tarea(')
          ..write('id: $id, ')
          ..write('titulo: $titulo, ')
          ..write('descripcion: $descripcion, ')
          ..write('fecha: $fecha, ')
          ..write('tipo: $tipo, ')
          ..write('completada: $completada, ')
          ..write('eventoId: $eventoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, titulo, descripcion, fecha, tipo, completada, eventoId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tarea &&
          other.id == this.id &&
          other.titulo == this.titulo &&
          other.descripcion == this.descripcion &&
          other.fecha == this.fecha &&
          other.tipo == this.tipo &&
          other.completada == this.completada &&
          other.eventoId == this.eventoId);
}

class TareasCompanion extends UpdateCompanion<Tarea> {
  final Value<int> id;
  final Value<String> titulo;
  final Value<String?> descripcion;
  final Value<DateTime> fecha;
  final Value<TipoTarea> tipo;
  final Value<bool> completada;
  final Value<int?> eventoId;
  const TareasCompanion({
    this.id = const Value.absent(),
    this.titulo = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.fecha = const Value.absent(),
    this.tipo = const Value.absent(),
    this.completada = const Value.absent(),
    this.eventoId = const Value.absent(),
  });
  TareasCompanion.insert({
    this.id = const Value.absent(),
    required String titulo,
    this.descripcion = const Value.absent(),
    required DateTime fecha,
    required TipoTarea tipo,
    this.completada = const Value.absent(),
    this.eventoId = const Value.absent(),
  }) : titulo = Value(titulo),
       fecha = Value(fecha),
       tipo = Value(tipo);
  static Insertable<Tarea> custom({
    Expression<int>? id,
    Expression<String>? titulo,
    Expression<String>? descripcion,
    Expression<DateTime>? fecha,
    Expression<int>? tipo,
    Expression<bool>? completada,
    Expression<int>? eventoId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titulo != null) 'titulo': titulo,
      if (descripcion != null) 'descripcion': descripcion,
      if (fecha != null) 'fecha': fecha,
      if (tipo != null) 'tipo': tipo,
      if (completada != null) 'completada': completada,
      if (eventoId != null) 'evento_id': eventoId,
    });
  }

  TareasCompanion copyWith({
    Value<int>? id,
    Value<String>? titulo,
    Value<String?>? descripcion,
    Value<DateTime>? fecha,
    Value<TipoTarea>? tipo,
    Value<bool>? completada,
    Value<int?>? eventoId,
  }) {
    return TareasCompanion(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      completada: completada ?? this.completada,
      eventoId: eventoId ?? this.eventoId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<int>(
        $TareasTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (completada.present) {
      map['completada'] = Variable<bool>(completada.value);
    }
    if (eventoId.present) {
      map['evento_id'] = Variable<int>(eventoId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TareasCompanion(')
          ..write('id: $id, ')
          ..write('titulo: $titulo, ')
          ..write('descripcion: $descripcion, ')
          ..write('fecha: $fecha, ')
          ..write('tipo: $tipo, ')
          ..write('completada: $completada, ')
          ..write('eventoId: $eventoId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriasTable categorias = $CategoriasTable(this);
  late final $ConocidosTable conocidos = $ConocidosTable(this);
  late final $TransaccionesTable transacciones = $TransaccionesTable(this);
  late final $EventosTable eventos = $EventosTable(this);
  late final $TareasTable tareas = $TareasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categorias,
    conocidos,
    transacciones,
    eventos,
    tareas,
  ];
}

typedef $$CategoriasTableCreateCompanionBuilder =
    CategoriasCompanion Function({
      Value<int> id,
      required String nombre,
      required String colorHex,
      required TipoTransaccion tipo,
    });
typedef $$CategoriasTableUpdateCompanionBuilder =
    CategoriasCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<String> colorHex,
      Value<TipoTransaccion> tipo,
    });

final class $$CategoriasTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriasTable, Categoria> {
  $$CategoriasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransaccionesTable, List<Transaccione>>
  _transaccionesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transacciones,
    aliasName: 'categorias__id__transacciones__categoria_id',
  );

  $$TransaccionesTableProcessedTableManager get transaccionesRefs {
    final manager = $$TransaccionesTableTableManager(
      $_db,
      $_db.transacciones,
    ).filter((f) => f.categoriaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transaccionesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriasTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoTransaccion, TipoTransaccion, int>
  get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> transaccionesRefs(
    Expression<bool> Function($$TransaccionesTableFilterComposer f) f,
  ) {
    final $$TransaccionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableFilterComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriasTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoTransaccion, int> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  Expression<T> transaccionesRefs<T extends Object>(
    Expression<T> Function($$TransaccionesTableAnnotationComposer a) f,
  ) {
    final $$TransaccionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableAnnotationComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriasTable,
          Categoria,
          $$CategoriasTableFilterComposer,
          $$CategoriasTableOrderingComposer,
          $$CategoriasTableAnnotationComposer,
          $$CategoriasTableCreateCompanionBuilder,
          $$CategoriasTableUpdateCompanionBuilder,
          (Categoria, $$CategoriasTableReferences),
          Categoria,
          PrefetchHooks Function({bool transaccionesRefs})
        > {
  $$CategoriasTableTableManager(_$AppDatabase db, $CategoriasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<TipoTransaccion> tipo = const Value.absent(),
              }) => CategoriasCompanion(
                id: id,
                nombre: nombre,
                colorHex: colorHex,
                tipo: tipo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                required String colorHex,
                required TipoTransaccion tipo,
              }) => CategoriasCompanion.insert(
                id: id,
                nombre: nombre,
                colorHex: colorHex,
                tipo: tipo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transaccionesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transaccionesRefs) db.transacciones,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transaccionesRefs)
                    await $_getPrefetchedData<
                      Categoria,
                      $CategoriasTable,
                      Transaccione
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriasTableReferences
                          ._transaccionesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriasTableReferences(
                            db,
                            table,
                            p0,
                          ).transaccionesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.categoriaId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriasTable,
      Categoria,
      $$CategoriasTableFilterComposer,
      $$CategoriasTableOrderingComposer,
      $$CategoriasTableAnnotationComposer,
      $$CategoriasTableCreateCompanionBuilder,
      $$CategoriasTableUpdateCompanionBuilder,
      (Categoria, $$CategoriasTableReferences),
      Categoria,
      PrefetchHooks Function({bool transaccionesRefs})
    >;
typedef $$ConocidosTableCreateCompanionBuilder =
    ConocidosCompanion Function({
      Value<int> id,
      required String nombre,
      required String apellido,
      Value<String?> mpUserId,
    });
typedef $$ConocidosTableUpdateCompanionBuilder =
    ConocidosCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<String> apellido,
      Value<String?> mpUserId,
    });

final class $$ConocidosTableReferences
    extends BaseReferences<_$AppDatabase, $ConocidosTable, Conocido> {
  $$ConocidosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransaccionesTable, List<Transaccione>>
  _transaccionesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transacciones,
    aliasName: 'conocidos__id__transacciones__conocido_id',
  );

  $$TransaccionesTableProcessedTableManager get transaccionesRefs {
    final manager = $$TransaccionesTableTableManager(
      $_db,
      $_db.transacciones,
    ).filter((f) => f.conocidoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transaccionesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConocidosTableFilterComposer
    extends Composer<_$AppDatabase, $ConocidosTable> {
  $$ConocidosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apellido => $composableBuilder(
    column: $table.apellido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mpUserId => $composableBuilder(
    column: $table.mpUserId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transaccionesRefs(
    Expression<bool> Function($$TransaccionesTableFilterComposer f) f,
  ) {
    final $$TransaccionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.conocidoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableFilterComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConocidosTableOrderingComposer
    extends Composer<_$AppDatabase, $ConocidosTable> {
  $$ConocidosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apellido => $composableBuilder(
    column: $table.apellido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mpUserId => $composableBuilder(
    column: $table.mpUserId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConocidosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConocidosTable> {
  $$ConocidosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get apellido =>
      $composableBuilder(column: $table.apellido, builder: (column) => column);

  GeneratedColumn<String> get mpUserId =>
      $composableBuilder(column: $table.mpUserId, builder: (column) => column);

  Expression<T> transaccionesRefs<T extends Object>(
    Expression<T> Function($$TransaccionesTableAnnotationComposer a) f,
  ) {
    final $$TransaccionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.conocidoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableAnnotationComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConocidosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConocidosTable,
          Conocido,
          $$ConocidosTableFilterComposer,
          $$ConocidosTableOrderingComposer,
          $$ConocidosTableAnnotationComposer,
          $$ConocidosTableCreateCompanionBuilder,
          $$ConocidosTableUpdateCompanionBuilder,
          (Conocido, $$ConocidosTableReferences),
          Conocido,
          PrefetchHooks Function({bool transaccionesRefs})
        > {
  $$ConocidosTableTableManager(_$AppDatabase db, $ConocidosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConocidosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConocidosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConocidosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> apellido = const Value.absent(),
                Value<String?> mpUserId = const Value.absent(),
              }) => ConocidosCompanion(
                id: id,
                nombre: nombre,
                apellido: apellido,
                mpUserId: mpUserId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                required String apellido,
                Value<String?> mpUserId = const Value.absent(),
              }) => ConocidosCompanion.insert(
                id: id,
                nombre: nombre,
                apellido: apellido,
                mpUserId: mpUserId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConocidosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transaccionesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transaccionesRefs) db.transacciones,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transaccionesRefs)
                    await $_getPrefetchedData<
                      Conocido,
                      $ConocidosTable,
                      Transaccione
                    >(
                      currentTable: table,
                      referencedTable: $$ConocidosTableReferences
                          ._transaccionesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ConocidosTableReferences(
                            db,
                            table,
                            p0,
                          ).transaccionesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.conocidoId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ConocidosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConocidosTable,
      Conocido,
      $$ConocidosTableFilterComposer,
      $$ConocidosTableOrderingComposer,
      $$ConocidosTableAnnotationComposer,
      $$ConocidosTableCreateCompanionBuilder,
      $$ConocidosTableUpdateCompanionBuilder,
      (Conocido, $$ConocidosTableReferences),
      Conocido,
      PrefetchHooks Function({bool transaccionesRefs})
    >;
typedef $$TransaccionesTableCreateCompanionBuilder =
    TransaccionesCompanion Function({
      Value<int> id,
      required String descripcion,
      required double monto,
      required DateTime fecha,
      required TipoTransaccion tipo,
      required int categoriaId,
      Value<String?> mpPaymentId,
      Value<String> proveedor,
      Value<int?> conocidoId,
      Value<String?> contraparteMpId,
    });
typedef $$TransaccionesTableUpdateCompanionBuilder =
    TransaccionesCompanion Function({
      Value<int> id,
      Value<String> descripcion,
      Value<double> monto,
      Value<DateTime> fecha,
      Value<TipoTransaccion> tipo,
      Value<int> categoriaId,
      Value<String?> mpPaymentId,
      Value<String> proveedor,
      Value<int?> conocidoId,
      Value<String?> contraparteMpId,
    });

final class $$TransaccionesTableReferences
    extends BaseReferences<_$AppDatabase, $TransaccionesTable, Transaccione> {
  $$TransaccionesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriasTable _categoriaIdTable(_$AppDatabase db) =>
      db.categorias.createAlias('transacciones__categoria_id__categorias__id');

  $$CategoriasTableProcessedTableManager get categoriaId {
    final $_column = $_itemColumn<int>('categoria_id')!;

    final manager = $$CategoriasTableTableManager(
      $_db,
      $_db.categorias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoriaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ConocidosTable _conocidoIdTable(_$AppDatabase db) =>
      db.conocidos.createAlias('transacciones__conocido_id__conocidos__id');

  $$ConocidosTableProcessedTableManager? get conocidoId {
    final $_column = $_itemColumn<int>('conocido_id');
    if ($_column == null) return null;
    final manager = $$ConocidosTableTableManager(
      $_db,
      $_db.conocidos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conocidoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EventosTable, List<Evento>> _eventosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.eventos,
    aliasName: 'transacciones__id__eventos__transaccion_id',
  );

  $$EventosTableProcessedTableManager get eventosRefs {
    final manager = $$EventosTableTableManager(
      $_db,
      $_db.eventos,
    ).filter((f) => f.transaccionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransaccionesTableFilterComposer
    extends Composer<_$AppDatabase, $TransaccionesTable> {
  $$TransaccionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoTransaccion, TipoTransaccion, int>
  get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get mpPaymentId => $composableBuilder(
    column: $table.mpPaymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proveedor => $composableBuilder(
    column: $table.proveedor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contraparteMpId => $composableBuilder(
    column: $table.contraparteMpId,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriasTableFilterComposer get categoriaId {
    final $$CategoriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableFilterComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConocidosTableFilterComposer get conocidoId {
    final $$ConocidosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conocidoId,
      referencedTable: $db.conocidos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConocidosTableFilterComposer(
            $db: $db,
            $table: $db.conocidos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> eventosRefs(
    Expression<bool> Function($$EventosTableFilterComposer f) f,
  ) {
    final $$EventosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventos,
      getReferencedColumn: (t) => t.transaccionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosTableFilterComposer(
            $db: $db,
            $table: $db.eventos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransaccionesTableOrderingComposer
    extends Composer<_$AppDatabase, $TransaccionesTable> {
  $$TransaccionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mpPaymentId => $composableBuilder(
    column: $table.mpPaymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proveedor => $composableBuilder(
    column: $table.proveedor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contraparteMpId => $composableBuilder(
    column: $table.contraparteMpId,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriasTableOrderingComposer get categoriaId {
    final $$CategoriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableOrderingComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConocidosTableOrderingComposer get conocidoId {
    final $$ConocidosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conocidoId,
      referencedTable: $db.conocidos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConocidosTableOrderingComposer(
            $db: $db,
            $table: $db.conocidos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransaccionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransaccionesTable> {
  $$TransaccionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoTransaccion, int> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get mpPaymentId => $composableBuilder(
    column: $table.mpPaymentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get proveedor =>
      $composableBuilder(column: $table.proveedor, builder: (column) => column);

  GeneratedColumn<String> get contraparteMpId => $composableBuilder(
    column: $table.contraparteMpId,
    builder: (column) => column,
  );

  $$CategoriasTableAnnotationComposer get categoriaId {
    final $$CategoriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableAnnotationComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConocidosTableAnnotationComposer get conocidoId {
    final $$ConocidosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conocidoId,
      referencedTable: $db.conocidos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConocidosTableAnnotationComposer(
            $db: $db,
            $table: $db.conocidos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> eventosRefs<T extends Object>(
    Expression<T> Function($$EventosTableAnnotationComposer a) f,
  ) {
    final $$EventosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventos,
      getReferencedColumn: (t) => t.transaccionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosTableAnnotationComposer(
            $db: $db,
            $table: $db.eventos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransaccionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransaccionesTable,
          Transaccione,
          $$TransaccionesTableFilterComposer,
          $$TransaccionesTableOrderingComposer,
          $$TransaccionesTableAnnotationComposer,
          $$TransaccionesTableCreateCompanionBuilder,
          $$TransaccionesTableUpdateCompanionBuilder,
          (Transaccione, $$TransaccionesTableReferences),
          Transaccione,
          PrefetchHooks Function({
            bool categoriaId,
            bool conocidoId,
            bool eventosRefs,
          })
        > {
  $$TransaccionesTableTableManager(_$AppDatabase db, $TransaccionesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransaccionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransaccionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransaccionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<double> monto = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<TipoTransaccion> tipo = const Value.absent(),
                Value<int> categoriaId = const Value.absent(),
                Value<String?> mpPaymentId = const Value.absent(),
                Value<String> proveedor = const Value.absent(),
                Value<int?> conocidoId = const Value.absent(),
                Value<String?> contraparteMpId = const Value.absent(),
              }) => TransaccionesCompanion(
                id: id,
                descripcion: descripcion,
                monto: monto,
                fecha: fecha,
                tipo: tipo,
                categoriaId: categoriaId,
                mpPaymentId: mpPaymentId,
                proveedor: proveedor,
                conocidoId: conocidoId,
                contraparteMpId: contraparteMpId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String descripcion,
                required double monto,
                required DateTime fecha,
                required TipoTransaccion tipo,
                required int categoriaId,
                Value<String?> mpPaymentId = const Value.absent(),
                Value<String> proveedor = const Value.absent(),
                Value<int?> conocidoId = const Value.absent(),
                Value<String?> contraparteMpId = const Value.absent(),
              }) => TransaccionesCompanion.insert(
                id: id,
                descripcion: descripcion,
                monto: monto,
                fecha: fecha,
                tipo: tipo,
                categoriaId: categoriaId,
                mpPaymentId: mpPaymentId,
                proveedor: proveedor,
                conocidoId: conocidoId,
                contraparteMpId: contraparteMpId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransaccionesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categoriaId = false, conocidoId = false, eventosRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (eventosRefs) db.eventos],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoriaId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoriaId,
                                    referencedTable:
                                        $$TransaccionesTableReferences
                                            ._categoriaIdTable(db),
                                    referencedColumn:
                                        $$TransaccionesTableReferences
                                            ._categoriaIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (conocidoId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.conocidoId,
                                    referencedTable:
                                        $$TransaccionesTableReferences
                                            ._conocidoIdTable(db),
                                    referencedColumn:
                                        $$TransaccionesTableReferences
                                            ._conocidoIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (eventosRefs)
                        await $_getPrefetchedData<
                          Transaccione,
                          $TransaccionesTable,
                          Evento
                        >(
                          currentTable: table,
                          referencedTable: $$TransaccionesTableReferences
                              ._eventosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransaccionesTableReferences(
                                db,
                                table,
                                p0,
                              ).eventosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transaccionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TransaccionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransaccionesTable,
      Transaccione,
      $$TransaccionesTableFilterComposer,
      $$TransaccionesTableOrderingComposer,
      $$TransaccionesTableAnnotationComposer,
      $$TransaccionesTableCreateCompanionBuilder,
      $$TransaccionesTableUpdateCompanionBuilder,
      (Transaccione, $$TransaccionesTableReferences),
      Transaccione,
      PrefetchHooks Function({
        bool categoriaId,
        bool conocidoId,
        bool eventosRefs,
      })
    >;
typedef $$EventosTableCreateCompanionBuilder =
    EventosCompanion Function({
      Value<int> id,
      required String titulo,
      Value<String?> descripcion,
      required DateTime fechaInicio,
      required DateTime fechaFin,
      Value<bool> esRecurrente,
      Value<String?> patronRecurrencia,
      Value<int?> transaccionId,
    });
typedef $$EventosTableUpdateCompanionBuilder =
    EventosCompanion Function({
      Value<int> id,
      Value<String> titulo,
      Value<String?> descripcion,
      Value<DateTime> fechaInicio,
      Value<DateTime> fechaFin,
      Value<bool> esRecurrente,
      Value<String?> patronRecurrencia,
      Value<int?> transaccionId,
    });

final class $$EventosTableReferences
    extends BaseReferences<_$AppDatabase, $EventosTable, Evento> {
  $$EventosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TransaccionesTable _transaccionIdTable(_$AppDatabase db) => db
      .transacciones
      .createAlias('eventos__transaccion_id__transacciones__id');

  $$TransaccionesTableProcessedTableManager? get transaccionId {
    final $_column = $_itemColumn<int>('transaccion_id');
    if ($_column == null) return null;
    final manager = $$TransaccionesTableTableManager(
      $_db,
      $_db.transacciones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transaccionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TareasTable, List<Tarea>> _tareasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tareas,
    aliasName: 'eventos__id__tareas__evento_id',
  );

  $$TareasTableProcessedTableManager get tareasRefs {
    final manager = $$TareasTableTableManager(
      $_db,
      $_db.tareas,
    ).filter((f) => f.eventoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tareasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EventosTableFilterComposer
    extends Composer<_$AppDatabase, $EventosTable> {
  $$EventosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaInicio => $composableBuilder(
    column: $table.fechaInicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaFin => $composableBuilder(
    column: $table.fechaFin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get esRecurrente => $composableBuilder(
    column: $table.esRecurrente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patronRecurrencia => $composableBuilder(
    column: $table.patronRecurrencia,
    builder: (column) => ColumnFilters(column),
  );

  $$TransaccionesTableFilterComposer get transaccionId {
    final $$TransaccionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaccionId,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableFilterComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tareasRefs(
    Expression<bool> Function($$TareasTableFilterComposer f) f,
  ) {
    final $$TareasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.eventoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableFilterComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EventosTableOrderingComposer
    extends Composer<_$AppDatabase, $EventosTable> {
  $$EventosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaInicio => $composableBuilder(
    column: $table.fechaInicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaFin => $composableBuilder(
    column: $table.fechaFin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get esRecurrente => $composableBuilder(
    column: $table.esRecurrente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patronRecurrencia => $composableBuilder(
    column: $table.patronRecurrencia,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransaccionesTableOrderingComposer get transaccionId {
    final $$TransaccionesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaccionId,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableOrderingComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventosTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventosTable> {
  $$EventosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaInicio => $composableBuilder(
    column: $table.fechaInicio,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaFin =>
      $composableBuilder(column: $table.fechaFin, builder: (column) => column);

  GeneratedColumn<bool> get esRecurrente => $composableBuilder(
    column: $table.esRecurrente,
    builder: (column) => column,
  );

  GeneratedColumn<String> get patronRecurrencia => $composableBuilder(
    column: $table.patronRecurrencia,
    builder: (column) => column,
  );

  $$TransaccionesTableAnnotationComposer get transaccionId {
    final $$TransaccionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaccionId,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableAnnotationComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tareasRefs<T extends Object>(
    Expression<T> Function($$TareasTableAnnotationComposer a) f,
  ) {
    final $$TareasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.eventoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableAnnotationComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EventosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventosTable,
          Evento,
          $$EventosTableFilterComposer,
          $$EventosTableOrderingComposer,
          $$EventosTableAnnotationComposer,
          $$EventosTableCreateCompanionBuilder,
          $$EventosTableUpdateCompanionBuilder,
          (Evento, $$EventosTableReferences),
          Evento,
          PrefetchHooks Function({bool transaccionId, bool tareasRefs})
        > {
  $$EventosTableTableManager(_$AppDatabase db, $EventosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<DateTime> fechaInicio = const Value.absent(),
                Value<DateTime> fechaFin = const Value.absent(),
                Value<bool> esRecurrente = const Value.absent(),
                Value<String?> patronRecurrencia = const Value.absent(),
                Value<int?> transaccionId = const Value.absent(),
              }) => EventosCompanion(
                id: id,
                titulo: titulo,
                descripcion: descripcion,
                fechaInicio: fechaInicio,
                fechaFin: fechaFin,
                esRecurrente: esRecurrente,
                patronRecurrencia: patronRecurrencia,
                transaccionId: transaccionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String titulo,
                Value<String?> descripcion = const Value.absent(),
                required DateTime fechaInicio,
                required DateTime fechaFin,
                Value<bool> esRecurrente = const Value.absent(),
                Value<String?> patronRecurrencia = const Value.absent(),
                Value<int?> transaccionId = const Value.absent(),
              }) => EventosCompanion.insert(
                id: id,
                titulo: titulo,
                descripcion: descripcion,
                fechaInicio: fechaInicio,
                fechaFin: fechaFin,
                esRecurrente: esRecurrente,
                patronRecurrencia: patronRecurrencia,
                transaccionId: transaccionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EventosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transaccionId = false, tareasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tareasRefs) db.tareas],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (transaccionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transaccionId,
                                referencedTable: $$EventosTableReferences
                                    ._transaccionIdTable(db),
                                referencedColumn: $$EventosTableReferences
                                    ._transaccionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tareasRefs)
                    await $_getPrefetchedData<Evento, $EventosTable, Tarea>(
                      currentTable: table,
                      referencedTable: $$EventosTableReferences
                          ._tareasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$EventosTableReferences(db, table, p0).tareasRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.eventoId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EventosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventosTable,
      Evento,
      $$EventosTableFilterComposer,
      $$EventosTableOrderingComposer,
      $$EventosTableAnnotationComposer,
      $$EventosTableCreateCompanionBuilder,
      $$EventosTableUpdateCompanionBuilder,
      (Evento, $$EventosTableReferences),
      Evento,
      PrefetchHooks Function({bool transaccionId, bool tareasRefs})
    >;
typedef $$TareasTableCreateCompanionBuilder =
    TareasCompanion Function({
      Value<int> id,
      required String titulo,
      Value<String?> descripcion,
      required DateTime fecha,
      required TipoTarea tipo,
      Value<bool> completada,
      Value<int?> eventoId,
    });
typedef $$TareasTableUpdateCompanionBuilder =
    TareasCompanion Function({
      Value<int> id,
      Value<String> titulo,
      Value<String?> descripcion,
      Value<DateTime> fecha,
      Value<TipoTarea> tipo,
      Value<bool> completada,
      Value<int?> eventoId,
    });

final class $$TareasTableReferences
    extends BaseReferences<_$AppDatabase, $TareasTable, Tarea> {
  $$TareasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EventosTable _eventoIdTable(_$AppDatabase db) =>
      db.eventos.createAlias('tareas__evento_id__eventos__id');

  $$EventosTableProcessedTableManager? get eventoId {
    final $_column = $_itemColumn<int>('evento_id');
    if ($_column == null) return null;
    final manager = $$EventosTableTableManager(
      $_db,
      $_db.eventos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TareasTableFilterComposer
    extends Composer<_$AppDatabase, $TareasTable> {
  $$TareasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoTarea, TipoTarea, int> get tipo =>
      $composableBuilder(
        column: $table.tipo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get completada => $composableBuilder(
    column: $table.completada,
    builder: (column) => ColumnFilters(column),
  );

  $$EventosTableFilterComposer get eventoId {
    final $$EventosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventoId,
      referencedTable: $db.eventos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosTableFilterComposer(
            $db: $db,
            $table: $db.eventos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TareasTableOrderingComposer
    extends Composer<_$AppDatabase, $TareasTable> {
  $$TareasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completada => $composableBuilder(
    column: $table.completada,
    builder: (column) => ColumnOrderings(column),
  );

  $$EventosTableOrderingComposer get eventoId {
    final $$EventosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventoId,
      referencedTable: $db.eventos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosTableOrderingComposer(
            $db: $db,
            $table: $db.eventos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TareasTableAnnotationComposer
    extends Composer<_$AppDatabase, $TareasTable> {
  $$TareasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoTarea, int> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<bool> get completada => $composableBuilder(
    column: $table.completada,
    builder: (column) => column,
  );

  $$EventosTableAnnotationComposer get eventoId {
    final $$EventosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventoId,
      referencedTable: $db.eventos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosTableAnnotationComposer(
            $db: $db,
            $table: $db.eventos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TareasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TareasTable,
          Tarea,
          $$TareasTableFilterComposer,
          $$TareasTableOrderingComposer,
          $$TareasTableAnnotationComposer,
          $$TareasTableCreateCompanionBuilder,
          $$TareasTableUpdateCompanionBuilder,
          (Tarea, $$TareasTableReferences),
          Tarea,
          PrefetchHooks Function({bool eventoId})
        > {
  $$TareasTableTableManager(_$AppDatabase db, $TareasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TareasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TareasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TareasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<TipoTarea> tipo = const Value.absent(),
                Value<bool> completada = const Value.absent(),
                Value<int?> eventoId = const Value.absent(),
              }) => TareasCompanion(
                id: id,
                titulo: titulo,
                descripcion: descripcion,
                fecha: fecha,
                tipo: tipo,
                completada: completada,
                eventoId: eventoId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String titulo,
                Value<String?> descripcion = const Value.absent(),
                required DateTime fecha,
                required TipoTarea tipo,
                Value<bool> completada = const Value.absent(),
                Value<int?> eventoId = const Value.absent(),
              }) => TareasCompanion.insert(
                id: id,
                titulo: titulo,
                descripcion: descripcion,
                fecha: fecha,
                tipo: tipo,
                completada: completada,
                eventoId: eventoId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TareasTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({eventoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (eventoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.eventoId,
                                referencedTable: $$TareasTableReferences
                                    ._eventoIdTable(db),
                                referencedColumn: $$TareasTableReferences
                                    ._eventoIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TareasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TareasTable,
      Tarea,
      $$TareasTableFilterComposer,
      $$TareasTableOrderingComposer,
      $$TareasTableAnnotationComposer,
      $$TareasTableCreateCompanionBuilder,
      $$TareasTableUpdateCompanionBuilder,
      (Tarea, $$TareasTableReferences),
      Tarea,
      PrefetchHooks Function({bool eventoId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db, _db.categorias);
  $$ConocidosTableTableManager get conocidos =>
      $$ConocidosTableTableManager(_db, _db.conocidos);
  $$TransaccionesTableTableManager get transacciones =>
      $$TransaccionesTableTableManager(_db, _db.transacciones);
  $$EventosTableTableManager get eventos =>
      $$EventosTableTableManager(_db, _db.eventos);
  $$TareasTableTableManager get tareas =>
      $$TareasTableTableManager(_db, _db.tareas);
}
