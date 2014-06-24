import 'package:orm/orm.dart';

class Coin extends Entity {
  int _marketId;
  String _name;
  
  Coin ({int marketId, String name})
  : this._marketId = marketId,
    this._name = name;

  Coin.fromMap (Map<String, dynamic> values)
  : this._marketId = values['marketId'],
    this._name = values['name'];

  Coin.fromMapSym (Map<Symbol, dynamic> values)
  : this._marketId = values[CoinMeta.SYMBOL_MARKETID],
    this._name = values[CoinMeta.SYMBOL_NAME];
  
  int get marketId => _marketId;
  String get name => _name;
  CoinMeta get entityMetadata => _meta;

  int get hashCode {
    int hash = 1;
    hash = 31 * hash + marketId.hashCode;
    hash = 31 * hash + name.hashCode;
  return hash;
  }
  
  set marketId (int marketId) {
    if (CoinMeta.PERSISTABLE_MARKETID.validate(marketId)) {
      _marketId = marketId;
      if (!entityMetadata.syncDisabled(this)) {
        _meta.onChange(this, CoinMeta.FIELD_MARKETID);
      }
    } else {
      throw new ArgumentError ('marketId is not valid');
    }
  }
  set name (String name) {
    if (CoinMeta.PERSISTABLE_NAME.validate(name)) {
      _name = name;
      if (!entityMetadata.syncDisabled(this)) {
        _meta.onChange(this, CoinMeta.FIELD_NAME);
      }
    } else {
      throw new ArgumentError ('name is not valid');
    }
  }
  
  static final CoinMeta _meta = new CoinMeta();
}

class CoinMeta extends EntityMeta<Coin> {

  String get idName => 'marketId';

  Symbol get idNameSym => SYMBOL_MARKETID;

  String get entityName => ENTITY_NAME;

  Symbol get entityNameSym => ENTITY_NAME_SYM;

  List asList (Coin coin) => [
    coin.marketId,
    coin.name
  ];

  Map<String, dynamic> asMap (Coin coin) => <String, dynamic> {
    'marketId': coin.marketId,
    'name': coin.name
  };
  
  Map<Symbol, dynamic> asMapSym (Coin coin) => <Symbol, dynamic> {
    SYMBOL_MARKETID: coin.marketId,
    SYMBOL_NAME: coin.name
  };
  
  String delete (Coin coin) => "DELETE FROM Coin WHERE Coin.$idName = '${get(coin, idName)}';";
  
  dynamic get (Coin coin, String field) {
    switch (field) {
      case 'marketId':
        return coin.marketId;
      case 'name':
        return coin.name;
      default:
        throw new ArgumentError('Invalid field $field');
        break;
    }
  }
  
  String insert (Coin coin, {bool ignore: false}) {    
    var marketId = coin.marketId;
    if (marketId is Entity) {
      marketId = marketId.entityMetadata.get(marketId, marketId.entityMetadata.idName);
    }    
    var name = coin.name;
    if (name is Entity) {
      name = name.entityMetadata.get(name, name.entityMetadata.idName);
    }
    return "INSERT${ignore ? 'ignore ' : ' '}INTO Coin (marketId, name) VALUES (${marketId is num ? '${marketId}' : "'${marketId}'"}, ${name is num ? '${name}' : "'${name}'"});";
  }
  
  String select (Coin coin, [List<String> fields]) {
    if (null == fields) {
      return 'SELECT * FROM Coin WHERE Coin.marketId = ${coin.marketId} LIMIT 1';
    } else if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('SELECT ');
    fields.forEach((field) => query.write('$field, '));
    return "${query.toString().substring(0, query.length - 2)} FROM Coin WHERE Coin.marketId = ${coin.marketId} LIMIT 1;";
  }
  
  String selectAll (List<Coin> coins, [List<String> fields]) {
    if (null == fields) {
      StringBuffer query = new StringBuffer('SELECT * FROM Coin WHERE Coin.marketId IN (');
      coins.forEach((coin) => query.write("'${coin.marketId}', "));
      return '${query.toString().substring(0, query.length - 2)}) LIMIT ${coins.length}';
    } else if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('SELECT ');
    fields.forEach((field) => query.write('$field, '));
    query = new StringBuffer('${query.toString().substring(0, query.length - 2)} FROM Coin WHERE Coin.marketId IN (');
    coins.forEach((coin) => query.write("${coin.marketId is num ? coin.marketId : "'${coin.marketId}'"}, "));
    return '${query.toString().substring(0, query.length - 2)}) LIMIT ${coins.length};';
  }
  
  void set (Coin coin, String field, value) {
    switch (field) {
      case 'marketId':
        coin.marketId = value;
        break;
      case 'name':
        coin.name = value;
        break;
      default:
        throw new ArgumentError('Invalid field $field');
        break;
    }
  }
  
  String update (Coin coin, List values, [List<String> fields]) {
    if (null == fields) {
      fields = CoinMeta.FIELDS;
    }
    if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('UPDATE Coin SET ');
    fields.forEach((f) {
      var value = get(coin, f);
      if (value is Entity) {
        value = value.entityMetadata.get(value, value.entityMetadata.idName);
      }
      query.write('$f = ${value is num ? value : "'$value'"}, ');
    });
    var id = get(coin, idName);
    return "${query.toString().substring(0, query.length - 2)} WHERE Coin.$idName = ${id is num ? id : "'$id'"};";
  }
  
  static const String ENTITY_NAME = 'Coin';
  static const Symbol ENTITY_NAME_SYM = const Symbol ('Coin');
  static const String FIELD_MARKETID = 'marketId',
    FIELD_NAME = 'name';
  static const List<String> FIELDS = const <String>[
    FIELD_MARKETID,
    FIELD_NAME
  ];
  static const String SQL_CREATE = 'CREATE TABLE Coin (marketId INT NOT NULL, name VARCHAR(25) NOT NULL, PRIMARY KEY(marketId));';
  static const Persistable PERSISTABLE_MARKETID = const IntPersistable (max: 206),
    PERSISTABLE_NAME = const StringPersistable (length: 25);
  static const Symbol SYMBOL_MARKETID = const Symbol('marketId'),
    SYMBOL_NAME = const Symbol('name');
}
