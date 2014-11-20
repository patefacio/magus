part of magus.mysql;

class MysqlSchemaReader
  implements SchemaReader {
  const MysqlSchemaReader(this._connectionPool);

  // custom <class MysqlSchemaReader>

  Future<Schema> readSchema(String schemaName) async {
    final tableCreates = await _readTableCreateStatements(schemaName);
    return makeSchema(tableCreates);
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
  static Future<Schema> makeSchema(Map tableCreates) async {
    tableCreates.forEach((String tableName, String create) {
      // Output of create table puts one entry (column, primary key, unqique
      // key, constraint, etc per line. Parsing splits by line first
      print(create);
      final entries = create.split(_commaNl).map((s) => s.trim()).toList();
      assert(entries.first.contains('CREATE TABLE'));
      assert(entries.last.contains('ENGINE'));
      entries.sublist(1, entries.length-1).forEach((String entry) {

        if(entry[0] == '`') {
          makeColumn(entry);
        } else if(entry.contains('PRIMARY KEY')) {
          print("PKEY $tableName => $entry");
        } else if(entry.contains('UNIQUE KEY')) {
          print("UNIQUE $tableName => $entry");
        } else if(entry.contains('CONSTRAINT')) {
          print("CONST $tableName => $entry");
        } else {
          print("UNKONWN $tableName => $entry");
        }

      });
    });
    return new Schema('foo',[]);
  }

  static var _whitespaceRe = new RegExp(r'\s+');
  static var _idRe = new RegExp(r'`(.+)`');
  static Column makeColumn(String columnSpec) {
    columnSpec = columnSpec.replaceFirst('NOT NULL', 'NOT_NULL');
    final entries = columnSpec.split(_whitespaceRe);
    final name = _idRe.firstMatch(entries[0]).group(1);
    final sqlType = entries[1];
    final rest = entries.sublist(2);
    final nullable = !rest.contains('NOT_NULL');
    final autoIncrement = rest.contains('AUTO_INCREMENT');
    print("COL ($columnSpec)  => $name, $sqlType, $nullable, $autoIncrement");
    return null;
  }

  // end <class MysqlSchemaReader>
  final ConnectionPool _connectionPool;
}
// custom <part schema_reader>
// end <part schema_reader>
