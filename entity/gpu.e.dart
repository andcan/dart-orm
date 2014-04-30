import 'package:orm/orm.dart';
import 'hardware.e.dart';

class Gpu extends Hardware {
  int _memorySize;
  
  int get memorySize => _memorySize;
  GpuMeta get entityMetadata => _meta;
  
  set memorySize (int memorySize) {
    if (GpuMeta.PERSISTABLE_MEMORYSIZE.validate(memorySize)) {
      _memorySize = memorySize;
      _meta.onChange(this, GpuMeta.FIELD_MEMORYSIZE);
    } else {
      throw new ArgumentError ('memorySize is not valid');
    }
  }
  
  static final GpuMeta _meta = new GpuMeta();
}

class GpuMeta extends HardwareMeta implements EntityMeta<Gpu> {

  
  String get entityName => ENTITY_NAME;

  Symbol get entityNameSym => ENTITY_NAME_SYM;

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
      case 'id':
        return gpu.id;
        break;
      case 'name':
        return gpu.name;
        break;
      case 'productor':
        return gpu.productor;
        break;
      case 'memorySize':
        return gpu.memorySize;
        break;
      default:
        throw new ArgumentError('Invalid field $field');
        break;
    }
  }
  
  String insert (Gpu gpu, {bool ignore: false}) => "INSERT ${ignore ? 'ignore ' : ' '}INTO Gpu (memorySize) VALUES ('${gpu.memorySize}');";
  
  String select (Gpu gpu, [List<String> fields]) {
    if (null == fields) {
      return 'SELECT * FROM Gpu WHERE Gpu.id = ${gpu.id} LIMIT 1';
    } else if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('SELECT ');
    fields.forEach((field) => query.write('$field, '));
    return '${query.toString().substring(0, query.length - 2)} FROM Gpu WHERE Gpu.id = ${gpu.id} LIMIT 1;';
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
    gpus.forEach((gpu) => query.write("'${gpu.id}', "));
    return '${query.toString().substring(0, query.length - 2)}) LIMIT ${gpus.length};';
  }
  
  String update (Gpu gpu, List values, [List<String> fields]) {
    if (null == fields) {
      fields = GpuMeta.FIELDS;
    }
    if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('UPDATE Gpu SET ');
    fields.forEach((f) => query.write("$f = '${get(gpu, f)}', "));
    return "${query.toString().substring(0, query.length - 2)} WHERE Gpu.$idName = '${get(gpu, idName)}';";
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
  static const String SQL_CREATE = 'CREATE TABLE Gpu (id INT NOT NULL, name VARCHAR(256) NOT NULL, productor VARCHAR(256) NOT NULL, memorySize INT NOT NULL);';
  static const Persistable PERSISTABLE_MEMORYSIZE = const IntPersistable (max: 100 * 1024 * 1024);
  static const Symbol SYMBOL_MEMORYSIZE = const Symbol('memorySize');
}
