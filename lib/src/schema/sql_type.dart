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
  SqlString(this.length, [ this.isVarying = true ]);

  SqlString._default();

  final int length;
  final bool isVarying;
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
    length = jsonMap["length"];
    isVarying = jsonMap["isVarying"];
  }
}

class SqlInt extends Object with TypeExtensionMixin {
  SqlInt(this.length, this.displayLength, [ this.unsigned = false ]);

  SqlInt._default();

  final int length;
  final int displayLength;
  final bool unsigned;
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
    length = jsonMap["length"];
    displayLength = jsonMap["displayLength"];
    unsigned = jsonMap["unsigned"];
  }
}

class SqlDecimal extends Object with TypeExtensionMixin {
  SqlDecimal(this.precision, this.scale, [ this.unsigned = false ]);

  SqlDecimal._default();

  final int precision;
  final int scale;
  final bool unsigned;
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
    precision = jsonMap["precision"];
    scale = jsonMap["scale"];
    unsigned = jsonMap["unsigned"];
  }
}

class SqlBinary extends Object with TypeExtensionMixin {
  SqlBinary(this.length, [ this.isVarying = true ]);

  SqlBinary._default();

  final int length;
  final bool isVarying;
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
    length = jsonMap["length"];
    isVarying = jsonMap["isVarying"];
  }
}

class SqlFloat extends Object with TypeExtensionMixin {
  SqlFloat(this.precision, this.scale, [ this.unsigned = false ]);

  SqlFloat._default();

  final int precision;
  final int scale;
  final bool unsigned;
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
    precision = jsonMap["precision"];
    scale = jsonMap["scale"];
    unsigned = jsonMap["unsigned"];
  }
}

class SqlDate extends Object with TypeExtensionMixin {
  // custom <class SqlDate>

  Map toJson() => { };

  static SqlDate fromJson(Object json) => new SqlDate();

  // end <class SqlDate>
}

class SqlTime extends Object with TypeExtensionMixin {
  SqlTime(this.hasTimezone);

  SqlTime._default();

  final bool hasTimezone;
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
    hasTimezone = jsonMap["hasTimezone"];
  }
}

class SqlTimestamp extends Object with TypeExtensionMixin {
  SqlTimestamp(this.hasTimezone, this.autoUpdate);

  SqlTimestamp._default();

  final bool hasTimezone;
  final bool autoUpdate;
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
    hasTimezone = jsonMap["hasTimezone"];
    autoUpdate = jsonMap["autoUpdate"];
  }
}

abstract class SqlTypeVisitor {
  // custom <class SqlTypeVisitor>

  String ddl(SqlType sqlType) {
    switch(sqlType.runtimeType) {
      case SqlString: return sqlStringDdl(sqlType);
      case SqlBinary: return sqlBinaryDdl(sqlType);
      case SqlInt: return sqlIntDdl(sqlType);
      case SqlFloat: return sqlFloatDdl(sqlType);
      case SqlTemporal: return sqlTemporalDdl(sqlType);
      default: return sqlExtensionDdl(sqlType);
    }
  }

  String sqlStringDdl(SqlString);
  String sqlBinaryDdl(SqlBinary);
  String sqlIntDdl(SqlInt);
  String sqlFloatDdl(SqlFloat);
  String sqlTemporalDdl(SqlTemporal);

  String sqlExtensionDdl(SqlType);

  // end <class SqlTypeVisitor>
}
// custom <part sql_type>
// end <part sql_type>
