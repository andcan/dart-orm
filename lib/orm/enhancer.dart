part of orm;

class EnhancerEntity {
  final StringBuffer _buffer = new StringBuffer ();
  final String entityMetaName;
  final String entityName;
  final String entityNamelc;
  final ExtendsClause extendsClause;
  final bool hasParent;
  final bool isAbstract;
  
  final List<ImportDirective> imports = [];
  final List<Member> members = [];
  final List<MethodDeclaration> methods = <MethodDeclaration>[];
  
  Member id;
  EnhancerEntity superclass;
  
  EnhancerEntity(ClassDeclaration cd)
      : entityMetaName = '${cd.name.name}Meta',
      entityName = cd.name.name,
      entityNamelc = cd.name.name.toLowerCase(),
      extendsClause = cd.extendsClause,
      hasParent = null != cd.extendsClause,
      isAbstract = null != cd.abstractKeyword;
      
  Member get identifier => null == id ? 
      (hasParent ? superclass.identifier : null) : id;
  
  List<Member> _allMembs;
  
  List<Member> _allMembers () {
    if (null == _allMembs) {
      _allMembs = <Member>[];
      if (hasParent) {
        _allMembs.addAll(superclass.members);
      }
      _allMembs.addAll(members);
    }
    return _allMembs;
  }
  
  Map<String, String> _annotationArguments (Annotation a) {
    Map<String, String> args = <String, String> {};
    a.arguments.arguments.forEach((arg) {
      String argument = arg.toString();
      int pos = argument.indexOf(':');
      args[argument.substring(0, pos - 1)] = argument.substring(pos + 2);
    });
    return args;
  }
      
  String _asArray () {
    _buffer
        ..clear()
        ..write('List asList ($entityName $entityNamelc) => [');
    _allMembers().forEach((member) => _buffer.write('\n    $entityNamelc.${member.vdname},'));
    return '${_buffer.toString().substring(0, _buffer.length - 1)}\n  ];';
  }
  
  String _asMap () {
    _buffer
        ..clear()
        ..write('Map<String, dynamic> asMap ($entityName $entityNamelc) => <String, dynamic> {');
    _allMembers().forEach((member) {
      String vdname = member.vdname;
      _buffer.write("\n    '${member.vdname}': $entityNamelc.${member.vdname},");
    });
    return '${_buffer.toString().substring(0, _buffer.length - 1)}\n  };';
  }
  
  String _asMapSym () {
    _buffer
        ..clear()
        ..write('Map<Symbol, dynamic> asMapSym ($entityName $entityNamelc) => <Symbol, dynamic> {');
    if (hasParent) {
      superclass.members.forEach((member) => 
          _buffer.write('\n    ${superclass.entityMetaName}.SYMBOL_${member.vdnameuc}: $entityNamelc.${member.vdname},'));
    }
    members.forEach((member) =>
      _buffer.write("\n    SYMBOL_${member.vdnameuc}: $entityNamelc.${member.vdname},")
    );
    return '${_buffer.toString().substring(0, _buffer.length - 1)}\n  };';
  }
  
  String _delete () => 'String delete ($entityName $entityNamelc) => "DELETE FROM $entityName WHERE $entityName.\$idName = \'\${get($entityNamelc, idName)}\';";';
  
  String _fields () {
    _buffer
        ..clear()
        ..write('static const String ');
    members.forEach((member) =>
        _buffer.write("FIELD_${member.vdnameuc} = '${member.vdname}',\n    "));
    return '${_buffer.toString().substring(0, _buffer.length - 6)};';
  }
  
  String _fieldsList () {
    _buffer
        ..clear()
        ..write('static const List<String> FIELDS = const <String>[');
    if (hasParent) {
      superclass.members.forEach((member) =>
          _buffer.write("\n    ${superclass.entityMetaName}.FIELD_${member.vdnameuc},"));
    }
    members.forEach((member) =>
        _buffer.write("\n    FIELD_${member.vdnameuc},"));
    return '${_buffer.toString().substring(0, _buffer.length - 1)}\n  ];';
  }
  
  String _get () {
    _buffer
        ..clear()
        ..write('dynamic get ($entityName $entityNamelc, String field) {\n    switch (field) {\n');
    List<Member> ms = <Member>[];
    if (hasParent) {
      ms.addAll(superclass.members);
    }
    ms.addAll(members);
    ms.forEach((member) => _buffer.write("      case '${member.vdname}':\n        return $entityNamelc.${member.vdname};\n        break;\n"));
    return '''$_buffer      default:
        throw new ArgumentError('Invalid field \$field');
        break;
    }
  }''';
  }
  
  String _getters () {
    _buffer.clear();
    members.forEach((member) => _buffer.write('${member.asGetter()}\n  '));
    return '${_buffer.toString().substring(0, _buffer.length - 3)}';
  }
  
  String _imports () {
    _buffer.clear();
    imports.forEach((i) {
      if (null != superclass) {
        String imp = i.toString();
        String target = '${superclass.entityNamelc}.dart';
        _buffer.write('${imp.contains(target) 
          ? imp.replaceFirst(target, '${superclass.entityNamelc}.e.dart') 
              : imp}\n');
      } else {
        _buffer.write('$i\n');
      }
    });
    return _buffer.toString();
  }
  
  String _insert () {
    _buffer
        ..clear()
        ..write('String insert ($entityName $entityNamelc, {bool ignore: false}) => "INSERT \${ignore ? \'ignore \' : \' \'}INTO $entityName (');
    members.forEach((member) => _buffer.write('${member.vdname}, '));
    String tmp = '${_buffer.toString().substring(0, _buffer.length - 2)}) VALUES (';
    _buffer
        ..clear()
        ..write(tmp);
    members.forEach((member) => _buffer.write("'\${$entityNamelc.${member.vdname}}', "));
    return '${_buffer.toString().substring(0, _buffer.length - 2)});";';
  }
  
  String _persistables () {
    _buffer
        ..clear()
        ..write('static const Persistable ');
    members.forEach((member) {
      Annotation annotation = member.annotation;
      String annPrefix;
      switch (member.typeName) {
        case 'bool':
          annPrefix = 'Bool';
          break;
        case 'int':
          annPrefix = 'Int';
          break;
        case 'num':
          annPrefix = 'Num';
          break;
        case 'String':
          annPrefix = 'String';
          break;
        default:
          annPrefix = '';
          break;
      }
      _buffer.write('PERSISTABLE_${member.vdnameuc} = const ${annPrefix}Persistable ${annotation.arguments.toString()},\n    ');
    });
    return '${_buffer.toString().substring(0, _buffer.length - 6)};';
  }
  
  String _select () => '''String select ($entityName $entityNamelc, [List<String> fields]) {
    if (null == fields) {
      return 'SELECT * FROM $entityName WHERE $entityName.${identifier.vdname} = \${$entityNamelc.${identifier.vdname}} LIMIT 1';
    } else if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('SELECT ');
    fields.forEach((field) => query.write('\$field, '));
    return '\${query.toString().substring(0, query.length - 2)} FROM $entityName WHERE $entityName.${identifier.vdname} = \${$entityNamelc.${identifier.vdname}} LIMIT 1;';
  }''';
  
  String _selectAll() => '''String selectAll (List<$entityName> ${entityNamelc}s, [List<String> fields]) {
    if (null == fields) {
      StringBuffer query = new StringBuffer('SELECT * FROM $entityName WHERE $entityName.${identifier.vdname} IN (');
      ${entityNamelc}s.forEach(($entityNamelc) => query.write("'\${$entityNamelc.${identifier.vdname}}', "));
      return '\${query.toString().substring(0, query.length - 2)}) LIMIT \${${entityNamelc}s.length}';
    } else if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('SELECT ');
    fields.forEach((field) => query.write('\$field, '));
    query = new StringBuffer('\${query.toString().substring(0, query.length - 2)} FROM $entityName WHERE $entityName.${identifier.vdname} IN (');
    ${entityNamelc}s.forEach(($entityNamelc) => query.write("'\${$entityNamelc.${identifier.vdname}}', "));
    return '\${query.toString().substring(0, query.length - 2)}) LIMIT \${${entityNamelc}s.length};';
  }''';
  
  String _setters () {
    _buffer.clear();
    members.forEach((member) => _buffer.write('${member.asSetter()}\n  '));
    return '${_buffer.toString().substring(0, _buffer.length - 3)}'.replaceAll('{{EntityMetaName}}', entityMetaName);
  }
  
  String _symbols() {
    _buffer
        ..clear()
        ..write('static const Symbol ');
    members.forEach((member) => _buffer.write("SYMBOL_${member.vdnameuc} = const Symbol('${member.vdname}'),\n    "));
    return '${_buffer.toString().substring(0, _buffer.length - 6)};';
  }
  
  String _properties () {
    _buffer.clear();
    members.forEach((member) => _buffer.write('${member.asPrivate()}\n  '));
    return '${_buffer.toString().substring(0, _buffer.length - 3)}';
  }
  
  String _sql () {
    _buffer
        ..clear()
        ..write("static const String SQL_CREATE = 'CREATE TABLE $entityName (");
    _allMembers().forEach((member) {
      Map<String, String> args = _annotationArguments(member.annotation);
      String sqlType;
      switch (member.typeName) {
        case 'int':
          sqlType = 'INT';
          break;
        case 'num':
          sqlType = 'DOUBLE';
          break;
        case 'String':
          if (args.containsKey('max')) {
            sqlType = 'VARCHAR(${args['max']})';
          } else {
            sqlType = 'VARCHAR(256)';
          }
          break;
      }
      _buffer.write('${member.vdname} $sqlType ${args.containsKey('nullable') && args['nullable'] ? '': 'NOT'} NULL, ');
    });
    return "${_buffer.toString().substring(0, _buffer.length - 2)});';";
  }
  
  String _update () => '''String update ($entityName $entityNamelc, List values, [List<String> fields]) {
    if (null == fields) {
      fields = ${entityName}Meta.FIELDS;
    }
    if (fields.isEmpty) {
      throw new ArgumentError('fields cannot be empty');
    }
    StringBuffer query = new StringBuffer('UPDATE $entityName SET ');
    fields.forEach((f) => query.write("\$f = '\${get($entityNamelc, f)}', "));
    return "\${query.toString().substring(0, query.length - 2)} WHERE $entityName.\$idName = '\${get($entityNamelc, idName)}';";
  }''';
      
  String toString () => '''${_imports()}
${isAbstract ? 'abstract ' : ''}class $entityName extends ${hasParent ? extendsClause.superclass : 'Entity'} {
  ${_properties()}
  
  ${_getters()}
  $entityMetaName get entityMetadata => _meta;
  
  ${_setters()}
  
  static final $entityMetaName _meta = new $entityMetaName();
}

class $entityMetaName ${hasParent ? 'extends ${extendsClause.superclass}Meta implements' : 'extends'} EntityMeta<$entityName> {

  ${hasParent ? '' : 'String get idName => \'${identifier.vdname}\';\n\n  Symbol get idNameSym => SYMBOL_${identifier.vdnameuc};\n'}
  String get entityName => ENTITY_NAME;

  Symbol get entityNameSym => ENTITY_NAME_SYM;

  ${_asArray()}

  ${_asMap()}
  
  ${_asMapSym()}
  
  ${_delete()}
  
  ${_get()}
  
  ${_insert()}
  
  ${_select()}
  
  ${_selectAll()}
  
  ${_update()}
  
  static const String ENTITY_NAME = '$entityName';
  static const Symbol ENTITY_NAME_SYM = const Symbol ('$entityName');
  ${_fields()}
  ${_fieldsList()}
  ${_sql()}
  ${_persistables()}
  ${_symbols()}
}
''';
}

class EntityEnhancer extends GeneralizingAstVisitor {
  Annotation _annotation;
  EnhancerEntity _current;
  String _currentFileName;
  Map<String, EnhancerEntity> _entities = <String, EnhancerEntity>{};
  Map<String, List<EnhancerEntity>> _groups = <String, List<EnhancerEntity>>{};
  List<ImportDirective> _imports = <ImportDirective>[];
  TypeName _type;
  int _typeCounter = 0;
  
  /**
   * Exepects a [Map]<[String], [String]> keyed by file path of the source 
   * to parse.
   */
  Map<String, List<String>> enhance (Map<String, String> contents, {bool suppressErrors: false}) {
    contents.forEach((name, source) {
      _currentFileName = name;
      parseCompilationUnit(source, name: name, suppressErrors: suppressErrors)
        .accept(this);
    });
    _entities.values.forEach((entity) {
      if (entity.hasParent) {
        ExtendsClause clause = entity.extendsClause;
        String superclass = clause.superclass.name.name;
        if (_entities.containsKey(superclass)) {
          entity.superclass = _entities[superclass];
          
        }
      }
    });
    Map<String, List<String>> es = <String, List<String>>{};
    _groups.forEach((file, entities) {
      List<String> enhanced = <String>[];
      entities.forEach((entity) => enhanced.add(entity.toString()));
      es[file] = enhanced;
    });
    return es;
  }
  
  visitAnnotation(Annotation node) {
    _annotation = node;
    super.visitAnnotation(node);
  }
  
  visitClassDeclaration(ClassDeclaration node) {
    _current = new EnhancerEntity(node);
    _current.imports.addAll(_imports);
    super.visitClassDeclaration(node);
    _entities[_current.entityName] = _current;
    List<EnhancerEntity> es;
    if (_groups.containsKey(_currentFileName)) {
      es = _groups[_currentFileName];
    } else {
      _groups[_currentFileName] = es = <EnhancerEntity>[];
    }
    es.add(_current);
    _current = null;
    _imports.clear();
  }
  
  visitMethodDeclaration(MethodDeclaration node) {
    _current.methods.add(node);
    super.visitMethodDeclaration(node);
  }
  
  visitImportDirective(ImportDirective node) {
    super.visitImportDirective(node);
    _imports.add(node);
  }
  
  visitExtendsClause(ExtendsClause node) {
    super.visitExtendsClause(node);
    _type = null;//Necessary or first property will have this type
  }
  
  visitTypeName(TypeName node) {
    if (0 == _typeCounter) {
      _type = node;
    } else {
      --_typeCounter;
    }
    if (null != node.typeArguments) {
      _typeCounter += node.typeArguments.arguments.length;
    }
    super.visitTypeName(node);
  }
  
  visitVariableDeclaration(VariableDeclaration node) {
    super.visitVariableDeclaration(node);
    if (null != _annotation && _annotation.toString().contains('Id()')) {
      _current.id = new Member(_annotation, _type, node);
    }
    _current.members.add(new Member(_annotation, _type, node));
    
    _annotation = null;
    _type = null;
  }
}

class Member {
  final Annotation annotation;
  final String typeName;
  final String vdname, vdnameuc;
  
  Member (Annotation this.annotation, TypeName tn, VariableDeclaration vd) 
  : typeName = null == tn ? tn : tn.toString(),
    vdname = vd.name.toString(),
    vdnameuc = vd.name.toString().toUpperCase();
  
  String get _type => '${typeName == null ? '' : '$typeName'}';
  
  String asGetter () => '$_type get $vdname => _$vdname;';  
  
  String asSetter () => '''set $vdname ($_type $vdname) {
    if ({{EntityMetaName}}.PERSISTABLE_$vdnameuc.validate($vdname)) {
      _$vdname = $vdname;
      _meta.onChange(this, {{EntityMetaName}}.FIELD_$vdnameuc);
    } else {
      throw new ArgumentError ('$vdname is not valid');
    }
  }''';
  
  String asParameter () => '$_type $vdname';
  
  String asPrivate () => '$_type _$vdname;';
  
  String toString () => '$annotation $_type $vdname;';
}