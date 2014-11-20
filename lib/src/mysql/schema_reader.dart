part of magus.mysql;

class MysqlSchemaReader
  implements SchemaReader {
  const MysqlSchemaReader(this._connectionPool);

  // custom <class MysqlSchemaReader>

  Future<Schema> readSchema(String schemaName) async {
    final tableCreates = await _readTableCreateStatements(schemaName);
    return _makeSchema(schemaName, tableCreates);
  }

  _readTableCreateStatements(String schemaName) async {
    final tableCreates = {};
    return _connectionPool
    .query('show tables')
    .then((var tableNames) => tableNames.map((t) => t[0]).toList())
    .then((var tableNames) => tableNames
        .map((var tableName) =>
            _connectionPool
            .query('show create table $tableName')
            .then((_) => _.toList())
            .then((var row) => tableCreates[tableName] = row[0][1])))
    .then((futures) => Future.wait(futures))
    .then((var _) {
      _connectionPool.close();
      return tableCreates;
    });
  }

  static var _commaNl = new RegExp(r',?\n');
  static Future<Schema> _makeSchema(String schemaName, Map tableCreates) async {
    final tables = [];
    tableCreates.forEach((String tableName, String create) {
      // Output of create table puts one entry (column, primary key, unqique
      // key, constraint, etc per line. Parsing splits by line first
      print(create);
      final entries = create.split(_commaNl).map((s) => s.trim()).toList();
      assert(entries.first.contains('CREATE TABLE'));
      assert(entries.last.contains('ENGINE'));
      final columns = [];
      entries.sublist(1, entries.length-1).forEach((String entry) {

        if(entry[0] == '`') {
          final column = _makeColumn(entry);
          columns.add(column);
        } else if(entry.contains('PRIMARY KEY')) {
          //print("PKEY $tableName => $entry");
        } else if(entry.contains('UNIQUE KEY')) {
          //print("UNIQUE $tableName => $entry");
        } else if(entry.contains('CONSTRAINT')) {
          //print("CONST $tableName => $entry");
        } else {
          //print("UNKONWN $tableName => $entry");
        }

      });
      assert(columns.length>0);
      tables.add(new Table(tableName, columns, []));
    });
    return new Schema(schemaName, tables);
  }

  static var _whitespaceRe = new RegExp(r'\s+');
  static var _idRe = new RegExp(r'`(.+)`');
  static Column _makeColumn(String columnSpec) {
    columnSpec = columnSpec
      .replaceFirst('NOT NULL', 'NOT_NULL')
      .replaceFirst(' unsigned', '_unsigned');
    final entries = columnSpec.split(_whitespaceRe);
    final name = _idRe.firstMatch(entries[0]).group(1);
    final mysqlType = entries[1];
    final rest = entries.sublist(2);
    final nullable = !rest.contains('NOT_NULL');
    final autoIncrement = rest.contains('AUTO_INCREMENT');
    final sqlType = _makeSqlType(mysqlType);
    return new Column(name, sqlType, nullable, autoIncrement);
  }

  static var _intRe = new RegExp(r'^int(?:\((\d+)\))?(_unsigned)?$');
  static var _qualifiedIntRe = new RegExp(r'^(tiny|small|medium|big)int(?:\((\d+)\))?(_unsigned)?$');
  static var _varcharRe = new RegExp(r'^(var)?char(?:\((\d+)\))?$');
  static var _textRe = new RegExp(r'^(tiny|medium|long)?text$');
  static var _blobRe = new RegExp(r'^(tiny|medium|long)?blob$');
  static var _floatRe = new RegExp(r'^(float|double)(?:\((\d+)\s*,\s*(\d+)\))?(_unsigned)?$');
  static var _decimalRe = new RegExp(r'^(decimal|numeric)(?:\((\d+)\s*,\s*(\d+)\))?(_unsigned)?$');
  static var _temporalRe = new RegExp(r'^(time|date|datetime|timestamp)$');

  static SqlType _makeSqlType(String mysqlType) {
    var match;
    if((match = _intRe.firstMatch(mysqlType)) != null) {
      int display_width = int.parse(match.group(1));
      bool unsigned = match.group(2) != null;
      return new SqlInt(4, display_width, unsigned);
    } else if((match = _qualifiedIntRe.firstMatch(mysqlType)) != null) {
      String qualifier = match.group(1);
      int display_width = int.parse(match.group(2));
      bool unsigned = match.group(3) != null;
      int length = 4;
      switch(qualifier) {
        case 'tiny': length = 1; break;
        case 'small': length = 2; break;
        case 'medium': length = 3; break;
        case 'big': length = 8; break;
      }
      return new SqlInt(length, display_width, unsigned);
    } else if((match = _varcharRe.firstMatch(mysqlType)) != null) {
      bool isVarying = match.group(1) != null;
      int length = int.parse(match.group(2));
      return new SqlString(length, isVarying);
    } else if((match = _textRe.firstMatch(mysqlType)) != null) {
      final qualifier = match.group(1);
      int length = (1<<16) - 1;
      switch(qualifier) {
        case 'tiny': length = (1<<8) -1; break;
        case 'medium': length = (1<<24) -1; break;
        case 'long': length = (1<<32) -1; break;
      }
      return new SqlString(length, true);
    } else if((match = _blobRe.firstMatch(mysqlType)) != null) {
      final qualifier = match.group(1);
      int length = (1<<16) - 1;
      switch(qualifier) {
        case 'tiny': length = (1<<8) -1; break;
        case 'medium': length = (1<<24) -1; break;
        case 'long': length = (1<<32) -1; break;
      }
      return new SqlBinary(length, true);
    } else if((match = _floatRe.firstMatch(mysqlType)) != null) {
      final floatOrDouble = match.group(1);
      final precisionFound = match.group(2);
      int precision;
      int scale;
      if(precisionFound != null) {
        precision = int.parse(precisionFound);
        scale = int.parse(match.group(3));
      }

      bool unsigned = match.group(4) != null;
      return new SqlFloat(precision, scale, unsigned);
    } else if((match = _decimalRe.firstMatch(mysqlType)) != null) {
      final decimalOrNumeric = match.group(1);
      final precisionFound = match.group(2);
      int precision;
      int scale;
      if(precisionFound != null) {
        precision = int.parse(precisionFound);
        scale = int.parse(match.group(3));
      }

      bool unsigned = match.group(4) != null;
      return new SqlDecimal(precision, scale, unsigned);
    } else if((match = _temporalRe.firstMatch(mysqlType)) != null) {
      var tag = match.group(1);
      switch(tag) {
        case "date": return new SqlDate();
        case "time": return new SqlTime(true);
        case "datetime": return new SqlTimestamp(true, false);
        case "timestamp": return new SqlTimestamp(true, true);
      }
      throw "Found unsupported temporal type $mysqlType";
    }

    print("WARNING: add support for $mysqlType");
    return null;
  }

  // end <class MysqlSchemaReader>
  final ConnectionPool _connectionPool;
}
// custom <part schema_reader>
// end <part schema_reader>
