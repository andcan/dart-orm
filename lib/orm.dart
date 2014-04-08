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
library orm;

import 'dart:async';
import 'dart:io';
import 'dart:mirrors';

import 'package:analyzer/analyzer.dart';
import 'package:path/path.dart' as p;
import 'package:serialization/serialization.dart';
import 'package:sqljocky/sqljocky.dart';
import 'package:utils/utils.dart';

part 'orm/enhancer.dart';
part 'orm/entity.dart';
part 'orm/datastore/datastore.dart';
part 'orm/datastore/sqldatastore.dart';


class Orm {
  
  final Serialization _serialization = new Serialization();

  void addSerializationRule (SerializationRule rule) => _serialization.addRule(rule);

  String serialize (Object value) {
    return _serialization.write(value, format: new SimpleJsonFormat(storeRoundTripInfo: true));
  }
  
  final DataStore datastore;
  
  final StreamController<ContentChangeEvent> _onChange = 
      new StreamController<ContentChangeEvent> ();
  
  Orm (DataStore datastore)
  : this.datastore = datastore {
    datastore.orm = this;
    _onChange.stream.listen(_listen, onError: (e) => print (e));
  }
  
  void _listen (ContentChangeEvent e) {  
    e.sink();
    datastore.update(e.entity, e.fields);
  }
  
  Future<Results> persist (Entity e) {
    EntityMeta meta = EntityMeta.of(e);
    if (meta.changeStreamController.isAbsent) {
      meta.changeStreamController = new Optional(_onChange);
    }
    return datastore.put(e);
  }
}