library magus.test.schema_reading;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:magus/schema.dart';
import 'package:magus/odbc_ini.dart';
import 'package:magus/mysql.dart';

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

    print('Schema is $schema');
    print('mysqlstring ddl is ${new SqlString(3)}');

  });

// end <main>

}
