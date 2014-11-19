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
    var reader = new MysqlSchemaReader(cp);
    var schema = (await reader.readSchema('code_metrics'));
print('Schema is $schema');
    print('CP $cp');

    print('mysqlstring ddl is ${new MysqlSqlString(VARCHAR)}');
    print('mysqlstring ddl is ${new MysqlSqlString(VARCHAR, 5)}');
    print('mysqlstring ddl is ${new MysqlSqlString(TEXT, 5)}');
    print('mysqlstring ddl is ${new MysqlSqlString(CHAR, 5)}');

    print('binary ddl is ${new MysqlSqlBinary(BINARY, 2)}');

    print('binary ddl is ${new MysqlSqlInt(INT, 6)}');
    print('binary ddl is ${new MysqlSqlInt(INT, 0, 3)}'); // Medium int
    print('binary ddl is ${new MysqlSqlInt(BIGINT, 6)}');
    print('binary ddl is ${new MysqlSqlInt(BIGINT)}');
    print('binary ddl is ${new MysqlSqlInt(SMALLINT, 2)}');
    print('binary ddl is ${new MysqlSqlInt(SMALLINT)}');
  });

// end <main>

}
