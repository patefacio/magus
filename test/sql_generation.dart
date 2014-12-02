library magus.test.sql_generation;

import 'package:unittest/unittest.dart';
// custom <additional imports>
import 'package:magus/schema.dart';
import 'package:magus/odbc_ini.dart';
import 'package:magus/mysql.dart';
// end <additional imports>

// custom <library sql_generation>
// end <library sql_generation>
main() {
// custom <main>

  readSchema() async {
    var cp = OdbcIni.createConnectionPool('code_metrics');
    var engine = new MysqlEngine(cp);
    var reader = engine.createSchemaReader();
    return await reader.readSchema('code_metrics');
  }

  readSchema()
  .then((Schema schema) {
    test('read_schema', () {
      final cl = schema.code_locations;
      final cp = schema.code_packages;

      // schema
      //   .getTables(['code_locations', 'code_packages'])
      //   .forEach((t) => print(t.name));

      // print(schema.code_locations.id);

      final q = query(
        [cl.id, cl.label, cl.file_name, cp.id]
        ..addAll(cp.getColumns(['name', 'descr'])));

      //      print(q);
      //      print('CL id table is ${cl.id.table}');
      print('q tables hit ${q.tables.map((t) => t.name)}');
    });
  });


// end <main>

}
