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
    print('CP $cp');

    print('mysqlstring ddl is ${new SqlString(3)}');

    // print('mysqlstring ddl is ${new SqlString(VARCHAR, 5)}');
    // print('mysqlstring ddl is ${new SqlString(TEXT, 5)}');
    // print('mysqlstring ddl is ${new SqlString(CHAR, 5)}');

    // print('binary ddl is ${new SqlBinary(BINARY, 2)}');

    // print('binary ddl is ${new SqlInt(INT, 6)}');
    // print('binary ddl is ${new SqlInt(INT, 0, 3)}'); // Medium int
    // print('binary ddl is ${new SqlInt(BIGINT, 6)}');
    // print('binary ddl is ${new SqlInt(BIGINT)}');
    // print('binary ddl is ${new SqlInt(SMALLINT, 2)}');
    // print('binary ddl is ${new SqlInt(SMALLINT)}');
  });

// end <main>

}
