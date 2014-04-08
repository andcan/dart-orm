/**
 * Copyright (C) 2014  Andrea Cantafio kk4r.1m@gmail.com
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
part of orm;

abstract class Enhancer<I, O> {
  O enhance (I input);
}

class EnhancerEntity {
  ClassDeclaration cd;
  final List<Member> members = [];
  final List<MethodDeclaration> methods = <MethodDeclaration>[];
  String ormpath;
  
  EnhancerEntity (this.cd);
  
  String toString () {
    String name = cd.name.name;
    StringBuffer arr = new StringBuffer ('['),
        cs = new StringBuffer ('$name.empty ();\n  $name ({'), cs1 = new StringBuffer (), 
        cs2 = new StringBuffer ('factory $name.fromMap (Map<String, dynamic> map) {\n    return new $name('),
        eq = new StringBuffer (), fs = new StringBuffer (), gs = new StringBuffer (),
        hc = new StringBuffer (), ps = new StringBuffer ('const Persistable '),
        map = new StringBuffer ('{'), ms = new StringBuffer (),
        sql = new StringBuffer ("const String _SQL = 'CREATE TABLE $name ("),
        serialize = new StringBuffer (), setters = new StringBuffer (),
        symbols = new StringBuffer ('const Symbol ');
    Member id;
    
    members.forEach((member) {
      String name = member.vdname, nameuc = '_${member.vdnameuc}';
      if (member.a.name.toString() == 'Id') {
        id = member;
      }
      arr.write('_$name, ');
      cs.write('${member.asParameter()}, ');
      cs1.write('_$name = $name, ');
      cs2.write("$name: map['$name'], ");
      eq.write('e.$name == _$name && ');
      fs.write('\n  ${member.asPrivate()}');
      gs.write('\n  ${member.asGetter()}');
      hc.write('hash = p * hash + _$name.hashCode;\n    ');
      map.write("'$name': _$name, ");
      setters.write('\n  ${member.asSetter()}');
      symbols.write("_SYMBOL$nameuc = const Symbol ('$name'), ");
      
      String ann;
      Annotation annotation = member.a;
      Map<String, String> args = new Map<String, String> ();
      annotation.arguments.arguments.forEach((arg) {
        var s = arg.toString().split(': ');
        args[s[0]] = s[1];
      });
      String sqlType;
      switch (member.typeName) {
        case 'int':
          ann = 'Int';
          sqlType = 'INT';
          break;
        case 'num':
          ann = 'Num';
          sqlType = 'DOUBLE';
          break;
        case 'String':
          ann = 'String';
          if (args.containsKey('max')) {
            sqlType = 'VARCHAR(${args['max']})';
          } else {
            sqlType = 'VARCHAR(256)';
          }
          break;
        default:
          ann = '';
          break;
      }
      sql.write('$name $sqlType ${args.containsKey('nullable') && args['nullable'] ? ' ': 'NOT '}NULL, ');
      ps.write('_PERSISTABLE$nameuc = const ${ann}Persistable ${annotation.arguments.toString()}, ');
    });
    
    methods.forEach((method) {
      ms.write('${method.toSource()}\n\t');
    });
    
    String _arr = '${arr.toString().substring(0, arr.length - 2)}]';
    String _map = '${map.toString().substring(0, map.length - 2)}}';
    String _eq = '${eq.toString().substring(0, eq.length - 4)}';
    String _hc = '${hc.toString().substring(0, hc.length - 5)}';
    String _cs = '''${cs.toString().substring(0, cs.length - 2)}}) :    
    ${cs1.toString().substring(0, cs1.length - 2)};
  ${cs2.toString().substring(0, cs2.length - 2)});
  }''';
    String _ms = '';
    if (ms.isNotEmpty) {
      _ms = '${ms.toString().substring(0, ms.length - 2)}';
    }
    String _sql = "${sql.toString().substring(0, sql.length - 2)}, PRIMARY KEY(${id.vdname}));';";
    String _symbols = '${symbols.toString().substring(0, symbols.length - 2)};';
    String _ps = '${ps.toString().substring(0, ps.length - 2)};';
    
    return '''import '$ormpath/orm.dart';

$_sql
$_symbols
$_ps

class ${cd.name}Meta extends EntityMeta {
  Symbol get idFieldName => _SYMBOL_${id.vdnameuc};
}

class ${cd.abstractKeyword == null ? '' : '${cd.abstractKeyword} '}${cd.name} extends Entity${id.typeName == null ? '' : '<${id.typeName}>'} {
  $_cs
  $fs
  static final EntityMeta _meta = new ${cd.name}Meta();
  
  List asList () => $_arr;
  
  Map<String, dynamic> asMap () => $_map;
  
  bool _validate (Persistable persistable, value) => persistable.validate(value);
  $gs
  int get hashCode {
    final int p = 37;
    int hash = 1;
    $_hc
    return hash;
  }
  EntityMeta get entityMetadata => _meta;

  $_ms
  $setters
  bool operator == ($name e) => $_eq;
}''';
  }
}

class Member {
  final Annotation a;
  final String typeName;
  final String vdname, vdnameuc;
  
  Member (Annotation this.a, TypeName tn, VariableDeclaration vd) 
  : typeName = null == tn ? tn : tn.toString(),
    vdname = vd.name.toString(),
    vdnameuc = vd.name.toString().toUpperCase();
  
  String get _type => '${typeName == null ? ' ' : '$typeName '}';
  
  String asGetter () => 'get $vdname => _$vdname};';
  
  String asSetter () => '''set $vdname ($_type$vdname) {
    if (_PERSISTABLE_$vdnameuc.validate($vdname)) {
      _$vdname = $vdname;
      _meta.propertyChanged(_SYMBOL_$vdnameuc);
    } else {
      throw new ArgumentError ('$vdname not valid');
    }
  }''';
  
  String asParameter () => '$_type$vdname';
  
  String asPrivate () => '${_type}_$vdname;';
  
  String toString () => '$a $_type$vdname;';
}

class EntityEnhancer extends GeneralizingAstVisitor implements Enhancer<String, String> {
  
  EnhancerEntity _e;
  List<EnhancerEntity> _es = <EnhancerEntity>[];
  
  Annotation _a;
  TypeName _t;
  
  final String ormpath;
  
  EntityEnhancer(this.ormpath);
  
  String enhance (String path) {
    
    parseDartFile(path).accept(this);
    
    var buffer = new StringBuffer ();
    _es.forEach((e) => buffer.write('$e\n  '));
    
    return buffer.toString();
  }
  
  visitAnnotation(Annotation node) {
    _a = node;
    super.visitAnnotation(node);
  }
  
  visitClassDeclaration(ClassDeclaration node) {
    _e = new EnhancerEntity(node);
    _e.ormpath = ormpath;
    super.visitClassDeclaration(node);
    _es.add(_e);
  }
  
  visitMethodDeclaration(MethodDeclaration node) {
    _e.methods.add(node);
    super.visitMethodDeclaration(node);
  }
  
  visitTypeName(TypeName node) {
    _t = _t == null ? node : _t;
    super.visitTypeName(node);
  }
  
  visitVariableDeclaration(VariableDeclaration node) {
    super.visitVariableDeclaration(node);
    _e.members.add(new Member(_a, _t, node));
    _a = null;
    _t = null;
  }
}

Future enhance (Iterable<String> files, String ormpath) {
  Completer c = new Completer();
  final enhancer = new EntityEnhancer(ormpath);
  final futures = <Future>[];
  files.forEach((path) {
    FileSystemEntity.type(path, followLinks: true).then((type) {
      switch (type) {
        case FileSystemEntityType.DIRECTORY:
          var f = new Directory(path).list(recursive: false, followLinks: true).toList();
          futures.add(f);
          f.then((list) => enhance(list.map((file) => file.absolute.path), ormpath),
              onError: (e) => c.completeError(e));
          break;
        case FileSystemEntityType.FILE:
          futures.add(new File('${p.dirname(path)}/${p.basenameWithoutExtension(path)}.enhanced.dart')
            .writeAsString(enhancer.enhance(path), mode: FileMode.WRITE));
          break;
        case FileSystemEntityType.LINK:
          var f = new Link(path).target();
          futures.add(f);
          f.then((target) 
              => new File('${p.dirname(target)}/${p.basenameWithoutExtension(target)}.enhanced.dart')
                  .writeAsString(enhancer.enhance(path), mode: FileMode.WRITE), onError: (e) 
                    => c.completeError(e));
          break;
        case FileSystemEntityType.NOT_FOUND:
          print('Warning! $path not found');
          break;
      }
    }, onError: (e) => c.completeError(e));
  });
  Future.wait(futures, eagerError: true).then((_)
      => c.complete(_), onError: (e) => c.completeError(e));
  return c.future;
}