part of magus.mysql;

/// Spec class for a UniqueKey - indicating the relationship by naming the columns in the unique constraint
class UniqueKeySpec {
  const UniqueKeySpec(this.name, this.columns);

  final String name;
  final List<String> columns;

  // custom <class UniqueKeySpec>
  // end <class UniqueKeySpec>

  toString() => '(${runtimeType}) => ${ebisu.prettyJsonMap(toJson())}';

  Map toJson() => {
        "name": ebisu.toJson(name),
        "columns": ebisu.toJson(columns),
      };

  static UniqueKeySpec fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new UniqueKeySpec._fromJsonMapImpl(json);
  }

  UniqueKeySpec._fromJsonMapImpl(Map jsonMap)
      : name = jsonMap["name"],
        // columns is List<String>
        columns =
            ebisu.constructListFromJsonData(jsonMap["columns"], (data) => data);
}

/// Spec class for a PrimaryKey - indicating the key columns with string names
class PrimaryKeySpec {
  const PrimaryKeySpec(this.columns);

  final List<String> columns;

  // custom <class PrimaryKeySpec>
  // end <class PrimaryKeySpec>

  toString() => '(${runtimeType}) => ${ebisu.prettyJsonMap(toJson())}';

  Map toJson() => {
        "columns": ebisu.toJson(columns),
      };

  static PrimaryKeySpec fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new PrimaryKeySpec._fromJsonMapImpl(json);
  }

  PrimaryKeySpec._fromJsonMapImpl(Map jsonMap)
      :
        // columns is List<String>
        columns =
            ebisu.constructListFromJsonData(jsonMap["columns"], (data) => data);
}

class MysqlSchemaParser {
  // custom <class MysqlSchemaParser>

  /// Given a single Mysql DDL Table Create statement, return the metadata
  /// equivalent
  Table parseTableCreate(String create) {
    // Output of create table puts one entry (column, primary key, unqique
    // key, constraint, etc per line. Parsing splits by line first
    PrimaryKeySpec primaryKeySpec;
    final uniqueKeySpecs = [];
    final foreignKeySpecs = [];
    final entries = create.split(_commaNl).map((s) => s.trim()).toList();
    assert(entries.first.contains('CREATE TABLE'));
    assert(entries.last.contains('ENGINE'));
    final tableName = _idRe.firstMatch(entries.first).group(1);

    final columns = [];
    entries.sublist(1, entries.length - 1).forEach((String entry) {
      if (entry[0] == '`') {
        final column = _makeColumn(entry);
        columns.add(column);
      } else if (entry.contains('FOREIGN KEY')) {
        foreignKeySpecs.add(_makeForeignKeySpec(entry));
      } else if (entry.contains('PRIMARY KEY')) {
        primaryKeySpec = _makePrimaryKeySpec(entry);
      } else if (entry.contains('UNIQUE KEY')) {
        uniqueKeySpecs.add(_makeUniqueKeySpec(entry));
      } else {
        _logger.warning('''
Unsupported line in create table:
**** line ***
$entry
**** create ***
$create
''');
      }
    });
    assert(columns.length > 0);

    List pkeyColumns = primaryKeySpec.columns
        .map(
            (colName) => columns.firstWhere((column) => colName == column.name))
        .toList();

    List uniqueKeys = uniqueKeySpecs
        .map((UniqueKeySpec spec) => new UniqueKey(
            spec.name,
            spec.columns
                .map((colName) =>
                    columns.firstWhere((column) => colName == column.name))
                .toList()))
        .toList();

    return new Table(
        tableName, columns, pkeyColumns, uniqueKeys, foreignKeySpecs);
  }

  /// Given a mapping of table name to table DDL, parses the DDL and creates the
  /// corresponding [Table] instance
  List<Table> parseTables(Map<String, String> createsMap) => createsMap.keys
      .map((String tableName) => parseTableCreate(createsMap[tableName]))
      .toList();

  static var _commaNl = new RegExp(r',?\n');
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
  static var _qualifiedIntRe =
      new RegExp(r'^(tiny|small|medium|big)int(?:\((\d+)\))?(_unsigned)?$');
  static var _varcharRe = new RegExp(r'^(var)?char(?:\((\d+)\))?$');
  static var _textRe = new RegExp(r'^(tiny|medium|long)?text$');
  static var _blobRe = new RegExp(r'^(tiny|medium|long)?blob$');
  static var _floatRe =
      new RegExp(r'^(float|double)(?:\((\d+)\s*,\s*(\d+)\))?(_unsigned)?$');
  static var _decimalRe =
      new RegExp(r'^(decimal|numeric)(?:\((\d+)\s*,\s*(\d+)\))?(_unsigned)?$');
  static var _temporalRe = new RegExp(r'^(time|date|datetime|timestamp)$');

  static SqlType _makeSqlType(String mysqlType) {
    var match;
    if ((match = _intRe.firstMatch(mysqlType)) != null) {
      int display_width = int.parse(match.group(1));
      bool unsigned = match.group(2) != null;
      return new SqlInt(4, display_width, unsigned);
    } else if ((match = _qualifiedIntRe.firstMatch(mysqlType)) != null) {
      String qualifier = match.group(1);
      int display_width = int.parse(match.group(2));
      bool unsigned = match.group(3) != null;
      int length = 4;
      switch (qualifier) {
        case 'tiny':
          length = 1;
          break;
        case 'small':
          length = 2;
          break;
        case 'medium':
          length = 3;
          break;
        case 'big':
          length = 8;
          break;
      }
      return new SqlInt(length, display_width, unsigned);
    } else if ((match = _varcharRe.firstMatch(mysqlType)) != null) {
      bool isVarying = match.group(1) != null;
      int length = int.parse(match.group(2));
      return new SqlString(length, isVarying);
    } else if ((match = _textRe.firstMatch(mysqlType)) != null) {
      final qualifier = match.group(1);
      int length = (1 << 16) - 1;
      switch (qualifier) {
        case 'tiny':
          length = (1 << 8) - 1;
          break;
        case 'medium':
          length = (1 << 24) - 1;
          break;
        case 'long':
          length = (1 << 32) - 1;
          break;
      }
      return new SqlString(length, true);
    } else if ((match = _blobRe.firstMatch(mysqlType)) != null) {
      final qualifier = match.group(1);
      int length = (1 << 16) - 1;
      switch (qualifier) {
        case 'tiny':
          length = (1 << 8) - 1;
          break;
        case 'medium':
          length = (1 << 24) - 1;
          break;
        case 'long':
          length = (1 << 32) - 1;
          break;
      }
      return new SqlBinary(length, true);
    } else if ((match = _floatRe.firstMatch(mysqlType)) != null) {
      final floatOrDouble = match.group(1);
      final precisionFound = match.group(2);
      int precision;
      int scale;
      if (precisionFound != null) {
        precision = int.parse(precisionFound);
        scale = int.parse(match.group(3));
      }

      bool unsigned = match.group(4) != null;
      return new SqlFloat(precision, scale, unsigned);
    } else if ((match = _decimalRe.firstMatch(mysqlType)) != null) {
      final decimalOrNumeric = match.group(1);
      final precisionFound = match.group(2);
      int precision;
      int scale;
      if (precisionFound != null) {
        precision = int.parse(precisionFound);
        scale = int.parse(match.group(3));
      }

      bool unsigned = match.group(4) != null;
      return new SqlDecimal(precision, scale, unsigned);
    } else if ((match = _temporalRe.firstMatch(mysqlType)) != null) {
      var tag = match.group(1);
      switch (tag) {
        case "date":
          return new SqlDate();
        case "time":
          return new SqlTime(true);
        case "datetime":
          return new SqlTimestamp(true, false);
        case "timestamp":
          return new SqlTimestamp(true, true);
      }
      throw "Found unsupported temporal type $mysqlType";
    }

    _logger.warning("Add support for $mysqlType!");
    return null;
  }

  static var _delimRe = new RegExp(',\s*');
  static var _pullIdRe = new RegExp(r"^\s*[`']?(\w+)[`']?\s*$");
  static String _pullId(String s) => _pullIdRe.firstMatch(s).group(1);
  static var _fkeyRe = new RegExp(
      r"CONSTRAINT (.+) FOREIGN KEY \(([^)]+)\) REFERENCES (.+) \(([^)]+)\)");

  static ForeignKeySpec _makeForeignKeySpec(String keyText) {
    var match = _fkeyRe.firstMatch(keyText);
    assert(match != null);
    final name = _pullId(match.group(1));
    final colsTxt = match.group(2);
    final refTable = _pullId(match.group(3));
    final refColsTxt = match.group(4);
    return new ForeignKeySpec(
        name,
        refTable,
        colsTxt.split(_delimRe).map((id) => _pullId(id)).toList(),
        refColsTxt.split(_delimRe).map((id) => _pullId(id)).toList());
  }

  static var _uniqueKeyRe = new RegExp(r"UNIQUE KEY (.+) \(([^)]+)\)");
  static UniqueKeySpec _makeUniqueKeySpec(String keyText) {
    var match = _uniqueKeyRe.firstMatch(keyText);
    assert(match != null);
    final name = _pullId(match.group(1));
    final colsTxt = match.group(2);
    return new UniqueKeySpec(
        name, colsTxt.split(_delimRe).map((id) => _pullId(id)).toList());
  }

  static var _primaryKeyRe = new RegExp(r"PRIMARY KEY \(([^)]+)\)");
  static PrimaryKeySpec _makePrimaryKeySpec(String keyText) {
    var match = _primaryKeyRe.firstMatch(keyText);
    assert(match != null);
    final colTerms = match.group(1).split(_delimRe);
    return new PrimaryKeySpec(colTerms.map((id) => _pullId(id)).toList());
  }

  // end <class MysqlSchemaParser>

}

class MysqlSchemaReader extends SchemaReader {
  // custom <class MysqlSchemaReader>

  MysqlSchemaReader(Engine engine, this._connectionPool) : super(engine);

  Future<Map<String, String>> tableCreateStatements(String schemaName) async {
    final tableCreates = {};
    return _connectionPool
        .query('show tables')
        .then((var tableNames) => tableNames.map((t) => t[0]).toList())
        .then((var tableNames) => tableNames.map((var tableName) =>
            _connectionPool
                .query('show create table $tableName')
                .then((_) => _.toList())
                .then((var row) => tableCreates[tableName] = row[0][1])))
        .then((futures) => Future.wait(futures))
        .then((var _) {
      _connectionPool.closeConnectionsNow();
      return tableCreates;
    });
  }

  Future<Schema> readSchema(String schemaName) async {
    final tableCreates = await tableCreateStatements(schemaName);
    _logger.info(tableCreates);
    final tables = new MysqlSchemaParser().parseTables(tableCreates);
    return new Schema(engine, schemaName, tables);
  }

  // end <class MysqlSchemaReader>

  final ConnectionPool _connectionPool;
}

// custom <part schema_reader>
// end <part schema_reader>
