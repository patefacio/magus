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

  String get ddl;

  // end <class SqlType>
}

abstract class BaseTypeMixin
  implements SqlType {
  SqlBaseType baseType;
  // custom <class BaseTypeMixin>

  String toString() => ddl;

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

abstract class SqlString
  implements SqlType,
    Length {
  // custom <class SqlString>
  // end <class SqlString>
}

abstract class SqlBinary
  implements SqlType,
    Length {
  // custom <class SqlBinary>
  // end <class SqlBinary>
}

abstract class SqlInt
  implements SqlType,
    Length,
    DisplayLength {
  // custom <class SqlInt>
  // end <class SqlInt>
}

abstract class SqlFloat
  implements SqlType {
  // custom <class SqlFloat>
  // end <class SqlFloat>
}

abstract class SqlTemporal
  implements SqlType {
  // custom <class SqlTemporal>
  // end <class SqlTemporal>
}
// custom <part sql_type>
// end <part sql_type>
