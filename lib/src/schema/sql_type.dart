part of magus.schema;

class SqlBaseType implements Comparable<SqlBaseType> {
  static const BOOLEAN = const SqlBaseType._(0);
  static const CHAR = const SqlBaseType._(1);
  static const VARCHAR = const SqlBaseType._(2);
  static const TEXT = const SqlBaseType._(3);
  static const BINARY = const SqlBaseType._(4);
  static const VARBINARY = const SqlBaseType._(5);
  static const BLOB = const SqlBaseType._(6);
  static const INT = const SqlBaseType._(7);
  static const SMALLINT = const SqlBaseType._(8);
  static const BIGINT = const SqlBaseType._(9);
  static const DECIMAL = const SqlBaseType._(10);
  static const FLOAT = const SqlBaseType._(11);
  static const DATE = const SqlBaseType._(12);
  static const TIME = const SqlBaseType._(13);
  static const DATETIME = const SqlBaseType._(14);
  static const TIMESTAMP = const SqlBaseType._(15);

  static get values => [
    BOOLEAN,
    CHAR,
    VARCHAR,
    TEXT,
    BINARY,
    VARBINARY,
    BLOB,
    INT,
    SMALLINT,
    BIGINT,
    DECIMAL,
    FLOAT,
    DATE,
    TIME,
    DATETIME,
    TIMESTAMP
  ];

  final int value;

  int get hashCode => value;

  const SqlBaseType._(this.value);

  copy() => this;

  int compareTo(SqlBaseType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case BOOLEAN: return "Boolean";
      case CHAR: return "Char";
      case VARCHAR: return "Varchar";
      case TEXT: return "Text";
      case BINARY: return "Binary";
      case VARBINARY: return "Varbinary";
      case BLOB: return "Blob";
      case INT: return "Int";
      case SMALLINT: return "Smallint";
      case BIGINT: return "Bigint";
      case DECIMAL: return "Decimal";
      case FLOAT: return "Float";
      case DATE: return "Date";
      case TIME: return "Time";
      case DATETIME: return "Datetime";
      case TIMESTAMP: return "Timestamp";
    }
    return null;
  }

  static SqlBaseType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Boolean": return BOOLEAN;
      case "Char": return CHAR;
      case "Varchar": return VARCHAR;
      case "Text": return TEXT;
      case "Binary": return BINARY;
      case "Varbinary": return VARBINARY;
      case "Blob": return BLOB;
      case "Int": return INT;
      case "Smallint": return SMALLINT;
      case "Bigint": return BIGINT;
      case "Decimal": return DECIMAL;
      case "Float": return FLOAT;
      case "Date": return DATE;
      case "Time": return TIME;
      case "Datetime": return DATETIME;
      case "Timestamp": return TIMESTAMP;
      default: return null;
    }
  }

}

const BOOLEAN = SqlBaseType.BOOLEAN;
const CHAR = SqlBaseType.CHAR;
const VARCHAR = SqlBaseType.VARCHAR;
const TEXT = SqlBaseType.TEXT;
const BINARY = SqlBaseType.BINARY;
const VARBINARY = SqlBaseType.VARBINARY;
const BLOB = SqlBaseType.BLOB;
const INT = SqlBaseType.INT;
const SMALLINT = SqlBaseType.SMALLINT;
const BIGINT = SqlBaseType.BIGINT;
const DECIMAL = SqlBaseType.DECIMAL;
const FLOAT = SqlBaseType.FLOAT;
const DATE = SqlBaseType.DATE;
const TIME = SqlBaseType.TIME;
const DATETIME = SqlBaseType.DATETIME;
const TIMESTAMP = SqlBaseType.TIMESTAMP;

abstract class SqlType {
  // custom <class SqlType>

  // end <class SqlType>
}

abstract class BaseTypeMixin
  implements SqlType {
  SqlBaseType baseType;
  // custom <class BaseTypeMixin>

  // end <class BaseTypeMixin>
}

abstract class Length {
  // custom <class Length>
  // end <class Length>
}

class LengthMixin
  implements Length {
  int length;
  // custom <class LengthMixin>
  // end <class LengthMixin>
}

abstract class DisplayLength {
  // custom <class DisplayLength>
  // end <class DisplayLength>
}

class DisplayLengthMixin
  implements DisplayLength {
  int displayLength;
  // custom <class DisplayLengthMixin>
  // end <class DisplayLengthMixin>
}

class SqlString extends Object with BaseTypeMixin {
  int length = 0;
  int displayLength = 0;
  // custom <class SqlString>

  SqlString([SqlBaseType baseType = VARCHAR, int length = 0]) {
    assert(baseType == VARCHAR || baseType == CHAR || baseType == TEXT);
    this.baseType = baseType;
    this.length = length;
  }

  String get ddl =>
    baseType == CHAR? (length == 0 ? 'CHAR' : 'CHAR($length)') :
    baseType == VARCHAR? (length == 0 ? 'VARCHAR' : 'VARCHAR($length)') :
    baseType == TEXT? 'TEXT' :
    throw 'Invalid baseType $baseType for SqlString';

  // end <class SqlString>
}

class SqlInt extends Object with BaseTypeMixin {
  int length = 0;
  int displayLength = 0;
  // custom <class SqlInt>

  SqlInt([ SqlBaseType baseType, int displayLength = 0, int length = 0]) {
    assert(baseType == INT || baseType == SMALLINT || baseType == BIGINT);
    this.baseType = baseType;
    this.length = length;
    this.displayLength = displayLength;
  }

  String get ddl {
    var tag = 'INT';
    if(baseType == INT) {
      if(length == 2) {
        tag = 'SMALLINT';
      } else if(length == 3) {
        tag = 'MEDIUMINT';
      } else if(length == 1) {
        tag = 'TINYINT';
      }
    } else if(baseType == BIGINT) {
      tag = 'BIGINT';
    } else if(baseType == SMALLINT) {
      tag = 'SMALLINT';
    } else {
      throw 'Invalid baseType $baseType for SqlInt';
    }

    return displayLength == 0? tag : '$tag($displayLength)';
  }

  // end <class SqlInt>
}

class SqlBinary extends Object with BaseTypeMixin {
  int length = 0;
  // custom <class SqlBinary>

  SqlBinary([SqlBaseType baseType = BINARY, int length = 0]) {
    assert(baseType == BINARY || baseType == BLOB);
    this.baseType = BINARY;
    this.length = length;
  }

  String get ddl =>
    length == 0? 'BINARY' : 'BINARY($length)';

  // end <class SqlBinary>
}

class SqlFloat extends Object with BaseTypeMixin {
  int length = 0;
  // custom <class SqlFloat>
  // end <class SqlFloat>
}

class SqlTemporal extends Object with BaseTypeMixin {
  // custom <class SqlTemporal>
  // end <class SqlTemporal>
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
