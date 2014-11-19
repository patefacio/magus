library magus.test.schema_reading;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:magus/odbc_ini.dart';
import 'package:magus/mysql.dart';

// end <additional imports>

// custom <library schema_reading>
// end <library schema_reading>
main() {
// custom <main>

  test('read_schema', () {
    var cp = OdbcIni.createConnectionPool('code_metrics');
    var reader = new MysqlSchemaReader(cp);
    var schema = (await reader.readSchema('code_metrics'));
print('Schema is $schema');
    print('CP $cp');
  });

// end <main>

}
