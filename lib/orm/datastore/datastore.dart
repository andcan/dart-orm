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

abstract class Transformer<I, O> {
  
  const Transformer(this.inputTypeName, this.outputTypeName);
  
  final String inputTypeName;
  
  final String outputTypeName;
  
  Type get inputType => I;
  
  Type get outputType => O;
  
  bool isValid (value);
  
  I revert (O value);
  
  O transform (I value);
}

class _MysqlBoolToInt extends Transformer<bool, int> {
  const _MysqlBoolToInt() : super('bool', 'TINYINT(1)');
  
  bool isValid (value) => value is bool;
  
  bool revert (int value) 
    => 0 == value ? false 
        : (1 == value ? true 
            : throw new ArgumentError ('$value is not a valid bool representation'));
  
  int transform (bool value) => value ? 1 : 0;
}

class Database {
  final String name;
  final Map<Type, Transformer> _transformers;
  
  const Database (this.name, this._transformers);
  
  static const Database MYSQL = const Database('mysql', const <Type, Transformer> {
    bool: const _MysqlBoolToInt()
  });
}

abstract class DataStore<E extends Entity> {
  Orm _orm;
  
  Database get type;
  
  set orm(Orm orm) => _orm = orm;
  
  void close ();
  
  Future<Results> delete (E e);
  
  Future<Optional<E>> get (E e);
  
  Future<List<Optional<E>>> getAll (List<E> es);
  
  Future<Results> put (E e);
  
  Future<Results> update (E e, List<String> symbols);
}