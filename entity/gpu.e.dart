import 'package:orm/orm.dart';
import 'hardware.e.dart';

class Gpu extends Hardware {
  int _memorySize;
  
  Gpu ({int id, String name, String productor, int memorySize})
  : super(id: id,
    name: name,
    productor: productor),
  this._memorySize = memorySize;

  Gpu.fromMap (Map<String, dynamic> values)
  : super(id: values['id'],
    name: values['name'],
    productor: values['productor']),
  this._memorySize = values['memorySize'];

  Gpu.fromMapSym (Map<Symbol, dynamic> values)
  : super(id: values[HardwareMeta.SYMBOL_ID],
    name: values[HardwareMeta.SYMBOL_NAME],
    productor: values[HardwareMeta.SYMBOL_PRODUCTOR]),
  this._memorySize = values[GpuMeta.SYMBOL_MEMORYSIZE];
  
  int get memorySize => _memorySize;
  GpuMeta get entityMetadata => _meta;

  int get hashCode {
    int hash = super.hashCode;
    hash = 31 * hash + memorySize.hashCode;
    return hash;
  }
  
  bool operator == (Gpu gpu) => id == gpu.id &&
    name == gpu.name &&
    productor == gpu.productor &&
    memorySize == gpu.memorySize;
  
  set memorySize (int memorySize) {
    if (GpuMeta.PERSISTABLE_MEMORYSIZE.validate(memorySize)) {
      _memorySize = memorySize;
      if (entityMetadata.syncEnabled(this)) {
        _meta.onChange(this, GpuMeta.FIELD_MEMORYSIZE);
      }
    } else {
      throw new ArgumentError ('memorySize is not valid');
    }
  }
  
  String toString () => '''{
    id: $id,
    name: $name,
    productor: $productor,
    memorySize: $memorySize
  }''';
  
  static final GpuMeta _meta = new GpuMeta();
}

class GpuMeta extends HardwareMeta implements EntityMeta<Gpu> {

  
  String get entityName => ENTITY_NAME;

  Symbol get entityNameSym => ENTITY_NAME_SYM;

  List<String> get fields => FIELDS;

  List<Symbol> get fieldsSym => FIELDS_SYM;

  List asList (Gpu gpu) => [
    gpu.id,
    gpu.name,
    gpu.productor,
    gpu.memorySize
  ];

  Map<String, dynamic> asMap (Gpu gpu) => <String, dynamic> {
    'id': gpu.id,
    'name': gpu.name,
    'productor': gpu.productor,
    'memorySize': gpu.memorySize
  };
  
  Map<Symbol, dynamic> asMapSym (Gpu gpu) => <Symbol, dynamic> {
    HardwareMeta.SYMBOL_ID: gpu.id,
    HardwareMeta.SYMBOL_NAME: gpu.name,
    HardwareMeta.SYMBOL_PRODUCTOR: gpu.productor,
    SYMBOL_MEMORYSIZE: gpu.memorySize
  };
  
  String delete (Gpu gpu) => "DELETE FROM Gpu WHERE Gpu.$idName = '${get(gpu, idName)}';";
  
  dynamic get (Gpu gpu, String field) {
    switch (field) {
      case 'memorySize':
        return gpu.memorySize;
      default:
        return super.get(gpu, field);
    }
  }
  
  String insert (Gpu gpu, {bool ignore: false}) {    
    var memorySize = gpu.memorySize;
    if (memorySize is Entity) {
      memorySize = memorySize.entityMetadata.get(memorySize, memorySize.entityMetadata.idName);
    }
    return "INSERT${ignore ? 'ignore ' : ' '}INTO Gpu (memorySize) VALUES (${memorySize is num ? '${memorySize}' : "'${memorySize}'"});";
  }
  
  String select (Gpu gpu, [List<String> fields]) {
    if (null == fields) {
      return 'SELECT * FROM Gpu WHERE Gpu.id = ${gpu.id} LIMIT 1';
    } else if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('SELECT ');
    fields.forEach((field) => query.write('$field, '));
    return "${query.toString().substring(0, query.length - 2)} FROM Gpu WHERE Gpu.id = ${gpu.id} LIMIT 1;";
  }
  
  String selectAll (List<Gpu> gpus, [List<String> fields]) {
    if (null == fields) {
      StringBuffer query = new StringBuffer('SELECT * FROM Gpu WHERE Gpu.id IN (');
      gpus.forEach((gpu) => query.write("'${gpu.id}', "));
      return '${query.toString().substring(0, query.length - 2)}) LIMIT ${gpus.length}';
    } else if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('SELECT ');
    fields.forEach((field) => query.write('$field, '));
    query = new StringBuffer('${query.toString().substring(0, query.length - 2)} FROM Gpu WHERE Gpu.id IN (');
    gpus.forEach((gpu) => query.write("${gpu.id is num ? gpu.id : "'${gpu.id}'"}, "));
    return '${query.toString().substring(0, query.length - 2)}) LIMIT ${gpus.length};';
  }
  
  void set (Gpu gpu, String field, value) {
    switch (field) {
      case 'memorySize':
        gpu.memorySize = value;
        break;
      default:
        super.set(gpu, field, value);
        break;
    }
  }
  
  String update (Gpu gpu, List values, [List<String> fields]) {
    if (null == fields) {
      fields = GpuMeta.FIELDS;
    }
    if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('UPDATE Gpu SET ');
    fields.forEach((f) {
      var value = get(gpu, f);
      if (value is Entity) {
        value = value.entityMetadata.get(value, value.entityMetadata.idName);
      }
      query.write('$f = ${value is num ? value : "'$value'"}, ');
    });
    var id = get(gpu, idName);
    return "${query.toString().substring(0, query.length - 2)} WHERE Gpu.$idName = ${id is num ? id : "'$id'"};";
  }
  
  static const String ENTITY_NAME = 'Gpu';
  static const Symbol ENTITY_NAME_SYM = const Symbol ('Gpu');
  static const String FIELD_MEMORYSIZE = 'memorySize';
  static const List<String> FIELDS = const <String>[
    HardwareMeta.FIELD_ID,
    HardwareMeta.FIELD_NAME,
    HardwareMeta.FIELD_PRODUCTOR,
    FIELD_MEMORYSIZE
  ];
  static const List<Symbol> FIELDS_SYM = const <Symbol>[
    HardwareMeta.SYMBOL_ID,
    HardwareMeta.SYMBOL_NAME,
    HardwareMeta.SYMBOL_PRODUCTOR,
    SYMBOL_MEMORYSIZE
  ];
  static const String SQL_CREATE = 'CREATE TABLE Gpu (id INT NOT NULL, name VARCHAR(256) NOT NULL, productor VARCHAR(1500) NOT NULL, memorySize INT NOT NULL, PRIMARY KEY(id));';
  static const Persistable PERSISTABLE_MEMORYSIZE = const IntPersistable (max: 100 * 1024 * 1024);
  static const Symbol SYMBOL_MEMORYSIZE = const Symbol('memorySize');
}
