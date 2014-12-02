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

  var engine;

  readSchema() async {
    var cp = OdbcIni.createConnectionPool('code_metrics');
    engine = new MysqlEngine(cp);
    var reader = engine.createSchemaReader();
    return await reader.readSchema('code_metrics');
  }

  readSchema()
  .then((Schema schema) {
    test('read_schema', () {
      final cl = schema.code_locations;
      final cp = schema.code_packages;
      final ru = schema.rusage_delta;
      final q = query(
        [
          cl.id, cl.label, cl.file_name, cp.id,
          ru.id, ru.cpu_mhz
        ]
        ..addAll(cp.getColumns(['name', 'descr'])))
        ..filter = ands(
          [
            eq(cl.label, cl.file_name),
            eq(cl.label, 'goo'),
            neq(cl.line_number, 25),
            notNull(cl.git_commit),
            and(le(ru.cpu_mhz, 1300000000), ge(ru.cpu_mhz, 800000000))
          ]);

        // new MultiAnd(
        //   [
        //     new Eq(cl.label, cl.file_name),
        //     new Eq(cl.file_name, 'Boo')
        //   ]);

      //      print(q);
      //      print('CL id table is ${cl.id.table}');
      print('q tables hit ${q.tables.map((t) => t.name)}');

      TableVisitor tv = engine.tableVisitor;
      print(tv.createTable(cl));
      print(engine.queryVisitor.select(q));

    });
  });


// end <main>

}
