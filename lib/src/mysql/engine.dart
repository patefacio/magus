part of magus.mysql;

class MysqlEngine implements Engine {
  // custom <class MysqlEngine>

  MysqlEngine(this._connectionPool) : _visitor = new MysqlVisitor();

  SchemaWriter createSchemaWriter() =>
      new MysqlSchemaWriter(this, _connectionPool);
  SchemaReader createSchemaReader() =>
      new MysqlSchemaReader(this, _connectionPool);

  SchemaVisitor get schemaVisitor => _visitor;
  TableVisitor get tableVisitor => _visitor;
  ExprVisitor get exprVisitor => _visitor;
  QueryVisitor get queryVisitor => _visitor;

  // end <class MysqlEngine>

  final ConnectionPool _connectionPool;
  final MysqlVisitor _visitor;
}

class MysqlVisitor extends SqlVisitor {
  // custom <class MysqlVisitor>

  String dropAll(Schema schema) =>
      'Mysql drop ${schema.tables.map((t) => t.name)} from schema';
  String createAll(Schema schema) =>
      'Mysql create ${schema.tables.map((t) => t.name)} from schema';
  String createTable(Table table) => 'Mysql create single table ${table.name}';
  String dropTable(Table table) => 'Mysql drop single table ${table.name}';

  String evalExpr(Expr expr) => throw "TODO";
  String recreateSchema(Schema schema) => throw "TODO";

  // end <class MysqlVisitor>

}

// custom <part engine>

ConnectionPool createConnectionPool(String dsn, [String odbcIniFileName]) {
  if (odbcIniFileName == null) {
    odbcIniFileName = path.join(Platform.environment['HOME'], '.odbc.ini');
  }

  final ini = new OdbcIni(odbcIniFileName);
  final entry = ini.getEntry(dsn);
  print(entry);  
  return new ConnectionPool(
      user: entry.user, password: entry.password, db: entry.database);
}

// end <part engine>
