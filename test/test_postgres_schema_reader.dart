library magus.test_postgres_schema_reader;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:postgres/postgres.dart';
import 'package:magus/postgres/schema_reader.dart';
import 'package:magus/postgres/engine.dart';

// end <additional imports>

final Logger _logger = new Logger('test_postgres_schema_reader');

// custom <library test_postgres_schema_reader>
// end <library test_postgres_schema_reader>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('read schema', () async {
    var connection = new PostgreSQLConnection("localhost", 5432, "plusauri",
        username: "postgres", password: "fkb92");
    await connection.open();

    final engine = new PostgresEngine(connection);
    final schemaReader = engine.createSchemaReader();
    await schemaReader.readSchema('bam');

    await connection.close();
    expect(2, 1 + 1);
  });

// end <main>
}
