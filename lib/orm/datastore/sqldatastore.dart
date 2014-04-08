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

class MySqlDataStore<E extends EnhancerEntity> implements DataStore<E> {
  
  Orm _orm;
  
  final Map<Symbol, Query> _gets = new Map<Symbol, Query> (),
      _puts = new Map<Symbol, Query> (), _upds = new Map<Symbol, Query> ();
  final ConnectionPool pool;
  
  MySqlDataStore(this.pool);
  
  Database get type => Database.MYSQL;
  
  void close () {
    pool.close();
  }
  
  Future<Results> delete (E e) {
    return pool.prepareExecute(EntityMeta.of(e).delete(e), []);
  }
  
  Future<Optional<E>> get (E e, [List<Symbol> fields]) {
    Completer<Optional<E>> c = new Completer<Optional<E>> ();
    InstanceMirror mirror = reflect (e);
    
    pool.startTransaction(consistent: true).then((transaction) {
      transaction.prepareExecute(EntityMeta.of(e).select(e), []).then((Results results) {
        results.first.then((Row result) {
          if (null == fields) {
            int i = 0;
            results.fields.forEach((field) {
              mirror.setField(new Symbol ('${field.name}'), result[i]);
              ++i;
            });
          } else {
            List<Field> fs = results.fields;
            fields.forEach((field) {
              Field f = fs.firstWhere((test) 
                  => test.name == MirrorSystem.getName(field), orElse: () => null);
              if (null == f) {
                throw new StateError('Field $field not found');
              }
              mirror.setField(field, result[fs.indexOf(f)]);
            });
          }
          c.complete(new Optional<E>(e));
        }).catchError((e) => c.complete(new Optional<E>.absent()),
            test: (e) => e is StateError);
      });
    });
    return c.future;
  }
  
  Future<List<Optional<E>>> _getAll (Iterable<Optional<E>> es, EntityMeta meta, [List<Symbol> fields]) {
    Completer<List<Optional<E>>> c = new Completer<List<Optional<E>>>();
    Symbol id = meta.idFieldName;
    List<Optional<E>> list = <Optional<E>>[];
    InstanceMirror mirror;
    if (null != fields) {
      if (!fields.contains(id)) {
        fields.add(meta.idFieldName);
      }
    }
    pool.startTransaction(consistent: true).then((transaction) {
      transaction.prepareExecute(meta.selectAll(es), []).then((Results results) {
        int length = es.length;
        List<Field> fs = results.fields;
        Field idField = fs.firstWhere((test) 
            => test.name == MirrorSystem.getName(meta.idFieldName), orElse: () => null);
        int idIndex = fs.indexOf(idField);
        results.toList().then((rs) {
          for (int i = 0; i < length; ++i) {
            E e = es.elementAt(i).value;
            mirror = reflect (e);
            Row result = rs.firstWhere((test) => test[idField.name] == mirror.getField(id));
            if (null == result) {
              list.add(new Optional<E>.absent());
            } else {
              if (null == fields) {
                int j = 0;
                results.fields.forEach((field) {
                  mirror.setField(new Symbol ('${field.name}'), result[j]);
                  ++j;
                });
              } else {
                fields.forEach((field) {
                  Field f = fs.firstWhere((test) 
                      => test.name == MirrorSystem.getName(field), orElse: () => null);
                  if (null == f) {
                    throw new StateError('Field $field not found');
                  }
                  mirror.setField(field, result[fs.indexOf(f)]);
                });
              }
              list.add(new Optional (mirror.reflectee));
            }
          }
        }, onError: (e) => throw e).whenComplete(() 
            => transaction.commit().then(c.complete(list), 
                onError: (e) => c.completeError(e)));
      });
    }, onError: (e) => throw e);
    return c.future;
  }
  
  Future<List<Optional<E>>> getAll (List<Optional<E>> es, [List<Symbol> fields]) {
    Completer<List<E>> c = new Completer<List<E>> ();
    InstanceMirror mirror;
    EntityMeta meta = EntityMeta.of(es.first.value);
    if (es.every((test) => EntityMeta.of(test).entityName == meta.entityName)) {
        return _getAll(es, meta, fields);
    } else {
      List<Optional<E>> all = <Optional<E>>[];
      Iterable<Optional<E>> same;
      do {
        meta = EntityMeta.of(es.first.value);
        same = es.where((test) => EntityMeta.of(test).entityName == meta.entityName);
        same.forEach((f) => es.remove(f));
        bool last = es.isEmpty;
        _getAll(same, meta, fields).then((all)
            => es.addAll(all), onError: (e) => c.completeError(e)).whenComplete(() {
              if (last) {
                c.complete(all);
              }
            });
      } while (same.isNotEmpty);
    }
    return c.future;
  }
  
  Future<Results> put (E e) {
    Completer<Results> c = new Completer<Results> ();
    pool.startTransaction(consistent: true).then((transaction) {
      Function handleError = (e) {
        transaction.rollback().then((_) 
            => c.completeError(e), onError: (e) => c.completeError(e));
      };
      transaction.prepareExecute(EntityMeta.of(e).insert(e), []).then((results) {
        transaction.commit().then((_) => c.complete(results), onError: handleError);
      }, onError: handleError);
    });
    return c.future;
  }
  
  Future<Results> update (E e, List<Symbol> fields) {
    Completer<Results> c = new Completer<Results> ();
    InstanceMirror mirror = reflect (e);
    List values = [];
    fields.forEach((field) => values.add(mirror.getField(field).reflectee));
    pool.startTransaction(consistent: true).then((transaction) {
      Function handleError = (e) {
        transaction.rollback().then((_) 
            => c.completeError(e), onError: (e) => c.completeError(e));
      };
      transaction.prepareExecute(EntityMeta.of(e).update(fields, values), []).then((results) 
          => transaction.commit().then((_) 
              => c.complete(results), onError: handleError),
              onError: handleError);
    });
    return c.future;
  }
  
  set orm (Orm orm) => _orm = orm;
}