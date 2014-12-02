library magus.test.schema_reading;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:magus/schema.dart';
import 'package:magus/odbc_ini.dart';
import 'package:magus/mysql.dart';
import 'package:quiver/iterables.dart';

// end <additional imports>

// custom <library schema_reading>
// end <library schema_reading>
main() {
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
