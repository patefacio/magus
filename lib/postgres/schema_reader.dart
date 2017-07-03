library magus.postgres.schema_reader;

import 'package:magus/schema.dart';
import 'package:postgres/postgres.dart';

// custom <additional imports>
// end <additional imports>

class PostgresSchemaReader extends SchemaReader {
  PostgreSQLConnection get connection => _connection;

  // custom <class PostgresSchemaReader>

  PostgresSchemaReader(this._connection);

  @override
  readSchema(
      {List skipTables = const [],
      List skipSchemas = const ['pg_catalog', 'information_schema']}) async {
    var query = '''
SELECT 
  T.table_catalog, 
  T.table_schema, 
  T.table_name, 
  T.table_type,
  C.column_name,
  C.data_type,
  C.character_maximum_length
FROM 
  information_schema.tables T
  INNER join information_schema.columns C 
    ON (T.table_catalog = C.table_catalog AND 
        T.table_schema = C.table_schema AND 
        T.table_name = C.table_name)
''';

    if (skipTables.isNotEmpty || skipSchemas.isNotEmpty) {
      var result = 'WHERE\n  ';
      final clauses = [];
      if (skipTables.isNotEmpty) {
        final tables = skipTables.map((t) => "'$t'").join(', ');
        clauses.add('T.table_name NOT IN ($tables)');
      }
      if (skipSchemas.isNotEmpty) {
        final schemas = skipSchemas.map((s) => "'$s'").join(', ');
        clauses.add('T.table_schema NOT IN ($schemas)');
      }
      query += result + clauses.join(' AND ');
    }

    query += '''\n
ORDER BY 
  T.table_catalog, 
  T.table_schema, 
  T.table_name
 ''';

    print(query);

    final filtered = (await connection.query(query));

    print(filtered.first);

    schema(row) => row[1];
    table(row) => row[2];
    column(row) => row[4];
    columnType(row) => row[5];
    maxLength(row) => row[6];

    processTable(Iterable it) {
      it.takeWhile((row) => row[1]);
    }

    for (List row in filtered) {
      print(
          '${schema(row)}.${table(row)}.${column(row)} * => ${columnType(row)} max(${maxLength(row)})');
    }
  }

  // end <class PostgresSchemaReader>

  PostgreSQLConnection _connection;
}

// custom <library schema_reader>

// end <library schema_reader>
