part of magus.mysql;

class MysqlEngine
  implements Engine {
  const MysqlEngine(this._connectionPool);

  // custom <class MysqlEngine>

  SchemaWriter createSchemaWriter() => new MysqlSchemaWriter(_connectionPool);
  SchemaReader createSchemaReader() => new MysqlSchemaReader(_connectionPool);

  // end <class MysqlEngine>
  final ConnectionPool _connectionPool;
}
// custom <part engine>
// end <part engine>
