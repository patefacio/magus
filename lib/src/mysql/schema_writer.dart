part of magus.mysql;

class MysqlSchemaWriter extends SchemaWriter {

  // custom <class MysqlSchemaWriter>
  
  MysqlSchemaWriter(Engine engine, this._connectionPool) : super(engine);
  writeSchema(Schema schema) => throw 'TODO';
  
  // end <class MysqlSchemaWriter>
  final ConnectionPool _connectionPool;
}
// custom <part schema_writer>
// end <part schema_writer>
