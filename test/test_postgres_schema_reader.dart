library magus.test_postgres_schema_reader;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:postgres/postgres.dart';
import 'package:magus/postgres/schema_reader.dart';
import 'package:magus/postgres/engine.dart';
import 'package:magus/odbc_ini.dart';

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

  PostgreSQLConnection connection;

  setUp(() async {
    print('setting up');
    final ini = new OdbcIni().getEntry('postgres-magus');
    connection = new PostgreSQLConnection("localhost", 5432, 'plusauri',
        username: ini.user, password: ini.password);
    print('opening connection');
    await connection.open();
    print('opened connection');    
  });

  tearDown(() async {
    print('tearing down');
    await connection.close();
    connection = null;
  });

  test('read schema', () async {
    print('read schema');    
    final engine = new PostgresEngine(connection);
    final schemaReader = engine.createSchemaReader();
    await schemaReader.readSchema('bam');
  });

// end <main>
}
