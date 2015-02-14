part of magus.schema;

/// Establishes interface for support sql datatypes
abstract class SqlType {
  // custom <class SqlType>

  // end <class SqlType>
}

abstract class TypeExtensionMixin
  implements SqlType {
  dynamic extension;
  // custom <class TypeExtensionMixin>
  // end <class TypeExtensionMixin>
}

class SqlString extends Object with TypeExtensionMixin {
  SqlString(this._length, this._isVarying);

  SqlString._default();

  int get length => _length;
  bool get isVarying => _isVarying;
  // custom <class SqlString>

  // end <class SqlString>

  Map toJson() => {
      "length": ebisu_utils.toJson(length),
      "isVarying": ebisu_utils.toJson(isVarying),// TODO: consider mixin support
  };

  static SqlString fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new SqlString._default()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    _length = jsonMap["length"];
    _isVarying = jsonMap["isVarying"];
  }
  int _length;
  bool _isVarying;
}

class SqlInt extends Object with TypeExtensionMixin {
  SqlInt(this._length, this._displayLength, [ this._unsigned = false ]);

  SqlInt._default();

  int get length => _length;
  int get displayLength => _displayLength;
  bool get unsigned => _unsigned;
  // custom <class SqlInt>

  // end <class SqlInt>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "length": ebisu_utils.toJson(length),
      "displayLength": ebisu_utils.toJson(displayLength),
      "unsigned": ebisu_utils.toJson(unsigned),// TODO: consider mixin support
  };

  static SqlInt fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new SqlInt._default()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    _length = jsonMap["length"];
    _displayLength = jsonMap["displayLength"];
    _unsigned = jsonMap["unsigned"];
  }
  int _length;
  int _displayLength;
  bool _unsigned;
}

class SqlDecimal extends Object with TypeExtensionMixin {
  SqlDecimal(this._precision, this._scale, [ this._unsigned = false ]);

  SqlDecimal._default();

  int get precision => _precision;
  int get scale => _scale;
  bool get unsigned => _unsigned;
  // custom <class SqlDecimal>
  // end <class SqlDecimal>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "precision": ebisu_utils.toJson(precision),
      "scale": ebisu_utils.toJson(scale),
      "unsigned": ebisu_utils.toJson(unsigned),// TODO: consider mixin support
  };

  static SqlDecimal fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new SqlDecimal._default()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    _precision = jsonMap["precision"];
    _scale = jsonMap["scale"];
    _unsigned = jsonMap["unsigned"];
  }
  int _precision;
  int _scale;
  bool _unsigned;
}

class SqlBinary extends Object with TypeExtensionMixin {
  SqlBinary(this._length, [ this._isVarying = true ]);

  SqlBinary._default();

  int get length => _length;
  bool get isVarying => _isVarying;
  // custom <class SqlBinary>
  // end <class SqlBinary>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "length": ebisu_utils.toJson(length),
      "isVarying": ebisu_utils.toJson(isVarying),// TODO: consider mixin support
  };

  static SqlBinary fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new SqlBinary._default()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    _length = jsonMap["length"];
    _isVarying = jsonMap["isVarying"];
  }
  int _length;
  bool _isVarying;
}

class SqlFloat extends Object with TypeExtensionMixin {
  SqlFloat(this._precision, this._scale, [ this._unsigned = false ]);

  SqlFloat._default();

  int get precision => _precision;
  int get scale => _scale;
  bool get unsigned => _unsigned;
  // custom <class SqlFloat>
  // end <class SqlFloat>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "precision": ebisu_utils.toJson(precision),
      "scale": ebisu_utils.toJson(scale),
      "unsigned": ebisu_utils.toJson(unsigned),// TODO: consider mixin support
  };

  static SqlFloat fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new SqlFloat._default()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    _precision = jsonMap["precision"];
    _scale = jsonMap["scale"];
    _unsigned = jsonMap["unsigned"];
  }
  int _precision;
  int _scale;
  bool _unsigned;
}

class SqlDate extends Object with TypeExtensionMixin {
  // custom <class SqlDate>

  Map toJson() => { };

  static SqlDate fromJson(Object json) => new SqlDate();

  // end <class SqlDate>
}

class SqlTime extends Object with TypeExtensionMixin {
  SqlTime(this._hasTimezone);

  SqlTime._default();

  bool get hasTimezone => _hasTimezone;
  // custom <class SqlTime>
  // end <class SqlTime>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "hasTimezone": ebisu_utils.toJson(hasTimezone),// TODO: consider mixin support
  };

  static SqlTime fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new SqlTime._default()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    _hasTimezone = jsonMap["hasTimezone"];
  }
  bool _hasTimezone;
}

class SqlTimestamp extends Object with TypeExtensionMixin {
  SqlTimestamp(this._hasTimezone, this._autoUpdate);

  SqlTimestamp._default();

  bool get hasTimezone => _hasTimezone;
  bool get autoUpdate => _autoUpdate;
  // custom <class SqlTimestamp>
  // end <class SqlTimestamp>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "hasTimezone": ebisu_utils.toJson(hasTimezone),
      "autoUpdate": ebisu_utils.toJson(autoUpdate),// TODO: consider mixin support
  };

  static SqlTimestamp fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new SqlTimestamp._default()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    _hasTimezone = jsonMap["hasTimezone"];
    _autoUpdate = jsonMap["autoUpdate"];
  }
  bool _hasTimezone;
  bool _autoUpdate;
}

/// Different engines may have different support/naming conventions for
/// the DDL corresponding to a given type. This provides an interface for
/// a specific dialect to generate proper DDL for the supported type.
///
abstract class SqlTypeVisitor {
  // custom <class SqlTypeVisitor>

  String ddl(SqlType sqlType) {
    switch(sqlType.runtimeType) {
      case SqlString: return sqlStringDdl(sqlType);
      case SqlBinary: return sqlBinaryDdl(sqlType);
      case SqlInt: return sqlIntDdl(sqlType);
      case SqlFloat: return sqlFloatDdl(sqlType);
      case SqlDate: return sqlDateDdl(sqlType);
      case SqlTimestamp: return sqlTimestampDdl(sqlType);
      case SqlTime: return sqlTimeDdl(sqlType);
      default: return sqlExtensionDdl(sqlType);
    }
  }

  String sqlStringDdl(SqlString);
  String sqlBinaryDdl(SqlBinary);
  String sqlIntDdl(SqlInt);
  String sqlFloatDdl(SqlFloat);
  String sqlDateDdl(SqlDate);
  String sqlTimeDdl(SqlTime);
  String sqlTimestampDdl(SqlTimestamp);
  String sqlExtensionDdl(SqlType);

  // end <class SqlTypeVisitor>
}
// custom <part sql_type>
// end <part sql_type>
