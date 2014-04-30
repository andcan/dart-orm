part of orm;

/**
 * Base annotation class.
 */
class Persistable<T> {
  final T defaultValue;
  final num length;
  final num max;
  final num min;
  final String name;
  final bool nullable;
  final String sqlType;
  final bool unique;
  
  const Persistable ({this.defaultValue, this.length, this.max, this.min, this.name, 
    this.nullable: true, this.sqlType, this.unique: false});
  /**
   * Provides an implementation suitable for objects implementing [Comparable]
   */
  bool validate (value) {
    if(null == value) {
      return nullable;
    } else if (value is Comparable) {
      if (null != min) {
        if (min.compareTo(value) > 0) {
          return false;
        }
      }
      if (null != max) {
        if (max.compareTo(value) < 0) {
          return false;
        }
      }
      return true;
    } else {
      if (value is List) {
        final length = value.length;
        return length >= min && length <= max;
      } else {
        //Unable to compare
        throw new ArgumentError('${value.runtimeType} does not implement comparable');
      }
    }
  }
}

/**
 * Annotation for [int] fields
 */
class IntPersistable extends Persistable<int> {
  const IntPersistable ({int defaultValue, int length, int max, int min, String name,
    bool nullable, String sqlType: 'INTEGER', bool unique})
    : super (defaultValue: defaultValue, name: name, max: max, min: min, 
        nullable: nullable, sqlType: sqlType, unique: unique);
  
  bool validate (int value) {
    if (value == null) {
      return nullable;
    }
    if (min != null) {
      if (value < min) {
        return false;
      }
    }
    if (max != null) {
      if (value > max) {
        return false;
      }
    }
    if (length > value.toString().length) {
      return false;
    }
    return true;
  }
}

class ListPersistable<T> extends Persistable<List<T>> {
  final Persistable<T> fieldsValidator;
  
  const ListPersistable({List<T> defaultValue, this.fieldsValidator, String name,
    int max, int min, bool nullable, String sqlType, bool unique})
      : super (defaultValue: defaultValue, name: name, max: max, min: min, 
          nullable: nullable, sqlType: sqlType, unique: unique);
  
  bool validate (List<T> value) {
    if (null == value) {
      return nullable;
    }
    if (min != null) {
      if (value.length < min) {
        return false;
      }
    }
    if (max != null) {
      if (value.length > max) {
        return false;
      }
    }
    if (null != fieldsValidator) {
      if (!value.every((test) => fieldsValidator.validate(test))) {
        return false;
      }
    }
    return true;
  }
}

/**
 * Annotation for [num] fields
 */
class NumPersistable extends Persistable<num> {
  const NumPersistable ({num defaultValue, String name, num max, num min, bool nullable,
    String sqlType, bool unique})
    : super (defaultValue: defaultValue, name: name, max: max, min: min, 
        nullable: nullable, sqlType: sqlType, unique: unique );
  
  bool validate (num value) {
    if (value == null) {
      return nullable;
    }
    if (min != null) {
      if (value < min) {
        return false;
      }
    }
    if (max != null) {
      if (value > max) {
        return false;
      }
    }
    return true;
  }
}

/**
 * Annotation for [String] fields
 */
class StringPersistable extends Persistable<String> {
  final String _match;
  
  const StringPersistable ({String defaultValue, int length, String name, int max,
    int min, String match, bool nullable, String sqlType, bool unique})
    : _match = match,
      super (defaultValue: defaultValue, name: name, max: max, min: min, 
        nullable: nullable, sqlType: sqlType, unique: unique );
  
  String get match => _match;
  
  bool validate (String value) {
    if (value == null) {
      return nullable;
    }
    int length = value.length;
    if (null != this.length && this.length < length) {
      return false;
    }
    if (null != max) {
      if (length > max) {
        return false;
      }
    }
    if (null != min) {
      if (length < min) {
        return false;
      }
    }
    return true;
  }
}

/**
 * Base id class. All id annotations used to mark ids implement and/or extend this class.
 * Provides an implementation for objects that implement [Comparable]
 */
class Id<T> extends Persistable<T> {
  const Id({String name: null, num max: null, num min: null, 
    String sqlType}) :
    super (name: name, max: max, min: min, nullable: false,
        sqlType: sqlType, unique: true);
}

/**
 * Annotation for [int] ids
 */
class IntId extends Id<int> {
  
  const IntId ({String name, num max, num min, String sqlType}) :
    super (name: name, max: max, min: min, sqlType: sqlType);
  
  bool validate (int value) {
    if (value == null) {
      return nullable;
    }
    if (min != null) {
      if (value < min) {
        return false;
      }
    }
    if (max != null) {
      if (value > max) {
        return false;
      }
    }
    return true;
  }
}

/**
 * Annotation for [num] ids
 */
class NumId extends Id<num> {
  
  const NumId ({String name, num max, num min, String sqlType}) :
    super (name: name, max: max, min: min, sqlType: sqlType);
  
  bool validate (int value) {
    if (value == null) {
      return nullable;
    }
    if (min != null) {
      if (value < min) {
        return false;
      }
    }
    if (max != null) {
      if (value > max) {
        return false;
      }
    }
    return true;
  }
}

/**
 * Annotation for [String] ids
 */
class StringId extends Id<String> implements StringPersistable {
  final String _match;
  
  const StringId ({String name, num max, num min, String match, String sqlType}) 
  : _match = match,
    super (name: name, max: max, min: min, sqlType: sqlType);
  
  String get match => _match;
  
  bool validate (String value) {
    if (value == null) {
      return nullable;
    }
    int length = value.length;
    if (max != null) {
      if (length > max) {
        return false;
      }
    }
    if (min != null) {
      if (length < min) {
        return false;
      }
    }
    return true;
  }
}