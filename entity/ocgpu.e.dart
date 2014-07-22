import 'package:orm/orm.dart';
import 'gpu.e.dart';
import 'hardware.e.dart';
import 'ocgpu.e.dart';

class OcGpu extends Gpu {
  int _offset;
  
  OcGpu ({int id, String name, String productor, int memorySize, int offset})
  : super(id: id,
    name: name,
    productor: productor, memorySize: memorySize),
  this._offset = offset;

  OcGpu.fromMap (Map<String, dynamic> values)
  : super(id: values['id'],
    name: values['name'],
    productor: values['productor'], memorySize: values['memorySize']),
  this._offset = values['offset'];

  OcGpu.fromMapSym (Map<Symbol, dynamic> values)
  : super(id: values[HardwareMeta.SYMBOL_ID],
    name: values[HardwareMeta.SYMBOL_NAME],
    productor: values[HardwareMeta.SYMBOL_PRODUCTOR],
  memorySize: values[GpuMeta.SYMBOL_MEMORYSIZE]),
  this._offset = values[OcGpuMeta.SYMBOL_OFFSET];
  
  int get offset => _offset;
  OcGpuMeta get entityMetadata => _meta;

  int get hashCode {
    int hash = super.hashCode;
    hash = 31 * hash + offset.hashCode;
    return hash;
  }
  
  bool operator == (OcGpu ocgpu) => id == ocgpu.id &&
    name == ocgpu.name &&
    productor == ocgpu.productor &&
    memorySize == ocgpu.memorySize &&
    offset == ocgpu.offset;
  
  set offset (int offset) {
    if (OcGpuMeta.PERSISTABLE_OFFSET.validate(offset)) {
      _offset = offset;
      if (entityMetadata.syncEnabled(this)) {
        _meta.onChange(this, OcGpuMeta.FIELD_OFFSET);
      }
    } else {
      throw new ArgumentError ('offset is not valid');
    }
  }
  
  String toString () => '''{
    id: $id,
    name: $name,
    productor: $productor,
    memorySize: $memorySize,
    offset: $offset
  }''';
  
  static final OcGpuMeta _meta = new OcGpuMeta();
}

class OcGpuMeta extends GpuMeta implements EntityMeta<OcGpu> {

  
  String get entityName => ENTITY_NAME;

  Symbol get entityNameSym => ENTITY_NAME_SYM;

  List<String> get fields => FIELDS;

  List<Symbol> get fieldsSym => FIELDS_SYM;

  List asList (OcGpu ocgpu) => [
    ocgpu.id,
    ocgpu.name,
    ocgpu.productor,
    ocgpu.memorySize,
    ocgpu.offset
  ];

  Map<String, dynamic> asMap (OcGpu ocgpu) => <String, dynamic> {
    'id': ocgpu.id,
    'name': ocgpu.name,
    'productor': ocgpu.productor,
    'memorySize': ocgpu.memorySize,
    'offset': ocgpu.offset
  };
  
  Map<Symbol, dynamic> asMapSym (OcGpu ocgpu) => <Symbol, dynamic> {
    HardwareMeta.SYMBOL_ID: ocgpu.id,
    HardwareMeta.SYMBOL_NAME: ocgpu.name,
    HardwareMeta.SYMBOL_PRODUCTOR: ocgpu.productor,
    GpuMeta.SYMBOL_MEMORYSIZE: ocgpu.memorySize,
    SYMBOL_OFFSET: ocgpu.offset
  };
  
  String delete (OcGpu ocgpu) => "DELETE FROM OcGpu WHERE OcGpu.$idName = '${get(ocgpu, idName)}';";
  
  dynamic get (OcGpu ocgpu, String field) {
    switch (field) {
      case 'offset':
        return ocgpu.offset;
      default:
        return super.get(ocgpu, field);
    }
  }
  
  String insert (OcGpu ocgpu, {bool ignore: false}) {    
    var offset = ocgpu.offset;
    if (offset is Entity) {
      offset = offset.entityMetadata.get(offset, offset.entityMetadata.idName);
    }
    return "INSERT${ignore ? 'ignore ' : ' '}INTO OcGpu (offset) VALUES (${offset is num ? '${offset}' : "'${offset}'"});";
  }
  
  String select (OcGpu ocgpu, [List<String> fields]) {
    if (null == fields) {
      return 'SELECT * FROM OcGpu WHERE OcGpu.id = ${ocgpu.id} LIMIT 1';
    } else if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('SELECT ');
    fields.forEach((field) => query.write('$field, '));
    return "${query.toString().substring(0, query.length - 2)} FROM OcGpu WHERE OcGpu.id = ${ocgpu.id} LIMIT 1;";
  }
  
  String selectAll (List<OcGpu> ocgpus, [List<String> fields]) {
    if (null == fields) {
      StringBuffer query = new StringBuffer('SELECT * FROM OcGpu WHERE OcGpu.id IN (');
      ocgpus.forEach((ocgpu) => query.write("'${ocgpu.id}', "));
      return '${query.toString().substring(0, query.length - 2)}) LIMIT ${ocgpus.length}';
    } else if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('SELECT ');
    fields.forEach((field) => query.write('$field, '));
    query = new StringBuffer('${query.toString().substring(0, query.length - 2)} FROM OcGpu WHERE OcGpu.id IN (');
    ocgpus.forEach((ocgpu) => query.write("${ocgpu.id is num ? ocgpu.id : "'${ocgpu.id}'"}, "));
    return '${query.toString().substring(0, query.length - 2)}) LIMIT ${ocgpus.length};';
  }
  
  void set (OcGpu ocgpu, String field, value) {
    switch (field) {
      case 'offset':
        ocgpu.offset = value;
        break;
      default:
        super.set(ocgpu, field, value);
        break;
    }
  }
  
  String update (OcGpu ocgpu, List values, [List<String> fields]) {
    if (null == fields) {
      fields = OcGpuMeta.FIELDS;
    }
    if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('UPDATE OcGpu SET ');
    fields.forEach((f) {
      var value = get(ocgpu, f);
      if (value is Entity) {
        value = value.entityMetadata.get(value, value.entityMetadata.idName);
      }
      query.write('$f = ${value is num ? value : "'$value'"}, ');
    });
    var id = get(ocgpu, idName);
    return "${query.toString().substring(0, query.length - 2)} WHERE OcGpu.$idName = ${id is num ? id : "'$id'"};";
  }
  
  static const String ENTITY_NAME = 'OcGpu';
  static const Symbol ENTITY_NAME_SYM = const Symbol ('OcGpu');
  static const String FIELD_OFFSET = 'offset';
  static const List<String> FIELDS = const <String>[
    HardwareMeta.FIELD_ID,
    HardwareMeta.FIELD_NAME,
    HardwareMeta.FIELD_PRODUCTOR,
    GpuMeta.FIELD_MEMORYSIZE,
    FIELD_OFFSET
  ];
  static const List<Symbol> FIELDS_SYM = const <Symbol>[
    GpuMeta.SYMBOL_MEMORYSIZE,
    SYMBOL_OFFSET
  ];
  static const String SQL_CREATE = 'CREATE TABLE OcGpu (id INT NOT NULL, name VARCHAR(256) NOT NULL, productor VARCHAR(1500) NOT NULL, memorySize INT NOT NULL, offset INT NOT NULL, PRIMARY KEY(id));';
  static const Persistable PERSISTABLE_OFFSET = const IntPersistable (max: 100 * 1024 * 1024);
  static const Symbol SYMBOL_OFFSET = const Symbol('offset');
}
