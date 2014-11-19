part of magus.mysql;

class MysqlSchemaReader implements SchemaReader {

  const MysqlSchemaReader(this.connectionPool);

  final ConnectionPool connectionPool;

  // custom <class MysqlSchemaReader>

  Future<Schema> readSchema(String schemaName) async {
    return connectionPool
      .query('show tables')
      .then((var tableNames) => tableNames.map((t) => t[0]).toList())
      .then((var tableNames) =>
          tableNames.map((var t) =>
              pool
              .query('describe $t')
              .then((_) => _.toList())
              .then((var describe) =>
                  [
                    t,
                    describe.map(
                      (row) =>
                      new Column()
                      ..name = row[0]
                      ..type = mapDataType(row[1].toString())
                      ..isNull = row[2] != 'NO'
                      ..isPrimaryKey = row[3] == 'PRI'
                      ..isForeignKey = row[3] == 'MUL'
                      ..defaultValue = row[4]
                      ..extra = row[5]
                      ..isAutoIncrement = row[5] == 'auto_increment'
                                 )]
                    )))
      .then((futures) => Future.wait(futures))
      .then((List tableData) {
        tableData.forEach((List tableData) =>
            tables.add(new Table(tableData[0], tableData[1].toList())));
        pool.close();
        print('Connection pool has closed');
        return null;
        //return new Schema(entry.database, tables);
      });
  }

  // end <class MysqlSchemaReader>
}
// custom <part schema_reader>
// end <part schema_reader>
