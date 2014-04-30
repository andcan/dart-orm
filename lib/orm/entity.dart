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

class Event {
  bool _sinked = false;
  
  bool get sinked => _sinked;
  
  void sink () {
    _sinked = true; 
  }
}

class ContentChangeEvent<T> extends Event {
  final T entity;
  final List<String> fields;
  
  ContentChangeEvent(T this.entity, List<String> this.fields);
}

abstract class EntityMeta<E extends Entity> {
  
  ContentChangeEvent _last;
  
  Optional<StreamController<ContentChangeEvent>> changeStreamController = 
      new Optional<StreamController<ContentChangeEvent>>.absent();
  
  EntityMeta ();
  
  String get entityName;
  
  Symbol get entityNameSym;
  
  String get idName;
  
  Symbol get idNameSym;
  
  List asList(E e);
  
  Map<String, dynamic> asMap (E e);
  
  Map<Symbol, dynamic> asMapSym (E e);
  
  String delete (E entity);
  
  Object get (E entity, String field);
  
  String insert (E entity, {bool ignore: false});
  
  void onChange (E entity, String field) {
    if (changeStreamController == null) {
      throw new StateError('invalid stream');
    } else if (changeStreamController.isNotAbsent) {
      if (_last == null) {
        _last = new ContentChangeEvent(entity, [field]);
        changeStreamController.value.add(_last);
      } else {
        if (_last.sinked) {
          _last = new ContentChangeEvent(entity, [field]);
          changeStreamController.value.add(_last);
        } else {
          _last.fields.add(field);
        }
      }
    }//else {
      //Nothing to do: object must be persisted first
    //}
  }
  
  String select (E entity, [List<String> fields]);
  
  String selectAll (List<E> entities, [List<String> fields]);
  
  String update (E entity, List values, [List<String> fields]);
  
  static EntityMeta of (Entity e) => e.entityMetadata;
}

abstract class Entity<T> {
  EntityMeta get entityMetadata;
}