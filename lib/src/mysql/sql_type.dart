part of magus.mysql;

class MysqlSqlString extends Object with BaseTypeMixin, LengthMixin
  implements SqlString {
  // custom <class MysqlSqlString>

  MysqlSqlString([SqlBaseType baseType = VARCHAR, int length = 0]) {
    assert(baseType == VARCHAR || baseType == CHAR || baseType == TEXT);
    this.baseType = baseType;
    this.length = length;
  }

  String get ddl =>
    baseType == CHAR? (length == 0 ? 'CHAR' : 'CHAR($length)') :
    baseType == VARCHAR? (length == 0 ? 'VARCHAR' : 'VARCHAR($length)') :
    baseType == TEXT? 'TEXT' :
    throw 'Invalid baseType $baseType for SqlString';

  // end <class MysqlSqlString>
}

class MysqlSqlBinary extends Object with BaseTypeMixin, LengthMixin
  implements SqlBinary {
  // custom <class MysqlSqlBinary>

  MysqlSqlBinary([SqlBaseType baseType = BINARY, int length = 0]) {
    assert(baseType == BINARY || baseType == BLOB);
    this.baseType = BINARY;
    this.length = length;
  }

  String get ddl =>
    length == 0? 'BINARY' : 'BINARY($length)';

  // end <class MysqlSqlBinary>
}

class MysqlSqlInt extends Object with BaseTypeMixin, LengthMixin, DisplayLengthMixin
  implements SqlInt {
  // custom <class MysqlSqlInt>

  MysqlSqlInt([SqlBaseType baseType = INT, int displayLength = 0, int length = 0]) {
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

  // end <class MysqlSqlInt>
}

class MysqlSqlFloat extends Object with BaseTypeMixin
  implements SqlFloat {
  // custom <class MysqlSqlFloat>
  // end <class MysqlSqlFloat>
}

class MysqlSqlTemporal extends Object with BaseTypeMixin
  implements SqlTemporal {
  // custom <class MysqlSqlTemporal>
  // end <class MysqlSqlTemporal>
}
// custom <part sql_type>
// end <part sql_type>
