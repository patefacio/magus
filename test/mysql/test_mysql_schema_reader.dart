library magus.test.mysql.test_mysql_schema_reader;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:magus/schema.dart';
import 'package:magus/odbc_ini.dart';
import 'package:magus/mysql.dart';
import 'package:quiver/iterables.dart';

// end <additional imports>

final Logger _logger = new Logger('test_mysql_schema_reader');

// custom <library test_mysql_schema_reader>
// end <library test_mysql_schema_reader>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('read_schema', () async {
    var cp = createConnectionPool('mysql-magus');
    var engine = new MysqlEngine(cp);
    var reader = engine.createSchemaReader();
    var schema = (await reader.readSchema('code_metrics'));

    schema.tables.forEach((Table table) {
      print('''Fkeys for ${table.name} =>
${table.foreignKeys}
}''');

      print(new Col(table.columns.first));
    });
    //print('Schema is $schema');
  });

// end <main>
}
