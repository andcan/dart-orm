import 'package:orm/orm.dart';

class Hardware extends Entity {
  int _id;
  String _name;
  String _productor;
  
  Hardware ({int id, String name, String productor})
  : this._id = id,
    this._name = name,
    this._productor = productor;

  Hardware.fromMap (Map<String, dynamic> values)
  : this._id = values['id'],
    this._name = values['name'],
    this._productor = values['productor'];

  Hardware.fromMapSym (Map<Symbol, dynamic> values)
  : this._id = values[HardwareMeta.SYMBOL_ID],
    this._name = values[HardwareMeta.SYMBOL_NAME],
    this._productor = values[HardwareMeta.SYMBOL_PRODUCTOR];
  
  int get id => _id;
  String get name => _name;
  String get productor => _productor;
  HardwareMeta get entityMetadata => _meta;
  
  set id (int id) {
    if (HardwareMeta.PERSISTABLE_ID.validate(id)) {
      _id = id;
      _meta.onChange(this, HardwareMeta.FIELD_ID);
    } else {
      throw new ArgumentError ('id is not valid');
    }
  }
  set name (String name) {
    if (HardwareMeta.PERSISTABLE_NAME.validate(name)) {
      _name = name;
      _meta.onChange(this, HardwareMeta.FIELD_NAME);
    } else {
      throw new ArgumentError ('name is not valid');
    }
  }
  set productor (String productor) {
    if (HardwareMeta.PERSISTABLE_PRODUCTOR.validate(productor)) {
      _productor = productor;
      _meta.onChange(this, HardwareMeta.FIELD_PRODUCTOR);
    } else {
      throw new ArgumentError ('productor is not valid');
    }
  }
  
  static final HardwareMeta _meta = new HardwareMeta();
}

class HardwareMeta extends EntityMeta<Hardware> {

  String get idName => 'id';

  Symbol get idNameSym => SYMBOL_ID;

  String get entityName => ENTITY_NAME;

  Symbol get entityNameSym => ENTITY_NAME_SYM;

  List asList (Hardware hardware) => [
    hardware.id,
    hardware.name,
    hardware.productor
  ];

  Map<String, dynamic> asMap (Hardware hardware) => <String, dynamic> {
    'id': hardware.id,
    'name': hardware.name,
    'productor': hardware.productor
  };
  
  Map<Symbol, dynamic> asMapSym (Hardware hardware) => <Symbol, dynamic> {
    SYMBOL_ID: hardware.id,
    SYMBOL_NAME: hardware.name,
    SYMBOL_PRODUCTOR: hardware.productor
  };
  
  String delete (Hardware hardware) => "DELETE FROM Hardware WHERE Hardware.$idName = '${get(hardware, idName)}';";
  
  dynamic get (Hardware hardware, String field) {
    switch (field) {
      case 'id':
        return hardware.id;
        break;
      case 'name':
        return hardware.name;
        break;
      case 'productor':
        return hardware.productor;
        break;
      default:
        throw new ArgumentError('Invalid field $field');
        break;
    }
  }
  
  String insert (Hardware hardware, {bool ignore: false}) => "INSERT ${ignore ? 'ignore ' : ' '}INTO Hardware (id, name, productor) VALUES ('${hardware.id}', '${hardware.name}', '${hardware.productor}');";
  
  String select (Hardware hardware, [List<String> fields]) {
    if (null == fields) {
      return 'SELECT * FROM Hardware WHERE Hardware.id = ${hardware.id} LIMIT 1';
    } else if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('SELECT ');
    fields.forEach((field) => query.write('$field, '));
    return '${query.toString().substring(0, query.length - 2)} FROM Hardware WHERE Hardware.id = ${hardware.id} LIMIT 1;';
  }
  
  String selectAll (List<Hardware> hardwares, [List<String> fields]) {
    if (null == fields) {
      StringBuffer query = new StringBuffer('SELECT * FROM Hardware WHERE Hardware.id IN (');
      hardwares.forEach((hardware) => query.write("'${hardware.id}', "));
      return '${query.toString().substring(0, query.length - 2)}) LIMIT ${hardwares.length}';
    } else if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('SELECT ');
    fields.forEach((field) => query.write('$field, '));
    query = new StringBuffer('${query.toString().substring(0, query.length - 2)} FROM Hardware WHERE Hardware.id IN (');
    hardwares.forEach((hardware) => query.write("'${hardware.id}', "));
    return '${query.toString().substring(0, query.length - 2)}) LIMIT ${hardwares.length};';
  }
  
  String update (Hardware hardware, List values, [List<String> fields]) {
    if (null == fields) {
      fields = HardwareMeta.FIELDS;
    }
    if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('UPDATE Hardware SET ');
    fields.forEach((f) => query.write("$f = '${get(hardware, f)}', "));
    return "${query.toString().substring(0, query.length - 2)} WHERE Hardware.$idName = '${get(hardware, idName)}';";
  }
  
  static const String ENTITY_NAME = 'Hardware';
  static const Symbol ENTITY_NAME_SYM = const Symbol ('Hardware');
  static const String FIELD_ID = 'id',
    FIELD_NAME = 'name',
    FIELD_PRODUCTOR = 'productor';
  static const List<String> FIELDS = const <String>[
    FIELD_ID,
    FIELD_NAME,
    FIELD_PRODUCTOR
  ];
  static const String SQL_CREATE = 'CREATE TABLE Hardware (id INT NOT NULL, name VARCHAR(256) NOT NULL, productor VARCHAR(256) NOT NULL);';
  static const Persistable PERSISTABLE_ID = const IntPersistable (),
    PERSISTABLE_NAME = const StringPersistable (),
    PERSISTABLE_PRODUCTOR = const StringPersistable (max: 1500);
  static const Symbol SYMBOL_ID = const Symbol('id'),
    SYMBOL_NAME = const Symbol('name'),
    SYMBOL_PRODUCTOR = const Symbol('productor');
}
