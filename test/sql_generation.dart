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
      // Grab the three Table objects from the Schema
      final Table cl = schema.code_locations;
      final Table cp = schema.code_packages;
      final Table ru = schema.rusage_delta;

      // Create the query - this function takes Iterable<Expr>
      final Query q = query(
        [
          cl.id, cl.label, cl.file_name, cp.id,
          ru.id, abs(ru.cpu_mhz, 'MHZ'), new Col(cp.id, 'CpId'),
          times(ru.cpu_mhz, ru.cpu_mhz, 'MHZ_SQRD')
        ]
        ..addAll(cp.getColumns(['name', 'descr'])))
        ..filter = ands(
          [
            ne(cl.label, cl.file_name),
            ne(cl.label, 'goo'),
            not(le(abs(cl.line_number), 2)),
            not(ge(abs(cl.line_number), 1<<25)),
            notNull(cl.git_commit),
            and(le(ru.cpu_mhz, 1.3e30), ge(ru.cpu_mhz, 2e2))
          ]);

      print(engine.queryVisitor.select(q));
    });
  });


// end <main>

}
