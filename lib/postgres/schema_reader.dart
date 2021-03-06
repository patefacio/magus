library magus.postgres.schema_reader;

import 'package:magus/postgres/engine.dart';
import 'package:magus/schema.dart';
import 'package:postgres/postgres.dart';

// custom <additional imports>

class SchemaRow {
  List _row;
  SchemaRow(this._row);
  get schema => _row[1];
  get table => _row[2];
  get column => _row[4];
  get columnType => _row[5];
  get maxLength => _row[6];

  bool sameTable(SchemaRow other) =>
      schema == other.schema && table == other.table;
}

// end <additional imports>

class PostgresSchemaReader extends SchemaReader {
  PostgreSQLConnection get connection => _connection;

  // custom <class PostgresSchemaReader>

  PostgresSchemaReader(PostgresEngine engine)
      : super(engine),
        _connection = engine.connection;

  @override
  readSchema(String schemaName,
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
    final tables = {};
    var table;

    newTable(row) => tables['${row.schema}.${row.table}'] = table = [row];

    filtered.fold(null, (SchemaRow prev, elm) {
      final row = new SchemaRow(elm);
      if (prev == null || !row.sameTable(prev)) {
        newTable(row);
      } else {
        table.add(row);
      }

      return row;
    });

    //print('Final $tables');

    tables.forEach((t, rows) {
      print('$t\n\t${rows.map((c) => c.column).join("\n\t")}');
    });

    // for (List row in filtered) {
    //   print(
    //       '${schema(row)}.${table(row)}.${column(row)} * => ${columnType(row)} max(${maxLength(row)})');
    // }
  }

  // end <class PostgresSchemaReader>

  PostgreSQLConnection _connection;
}

// custom <library schema_reader>

// end <library schema_reader>
