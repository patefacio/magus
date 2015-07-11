library magus.schema_reading;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:magus/schema.dart';
import 'package:magus/odbc_ini.dart';
import 'package:magus/mysql.dart';
import 'package:quiver/iterables.dart';

// end <additional imports>

final _logger = new Logger('schema_reading');

// custom <library schema_reading>
// end <library schema_reading>

main([List<String> args]) {
  Logger.root.onRecord.listen((LogRecord r) =>
      print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('read_schema', () async {
    var cp = OdbcIni.createConnectionPool('code_metrics');
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


