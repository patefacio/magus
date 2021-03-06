library magus.test.mysql.test_mysql_sql_generation;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:magus/schema.dart';
import 'package:magus/mysql.dart';
// end <additional imports>

final Logger _logger = new Logger('test_mysql_sql_generation');

// custom <library test_mysql_sql_generation>
// end <library test_mysql_sql_generation>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  var engine;

  readSchema() async {
    var cp = createConnectionPool('mysql-magus');
    engine = new MysqlEngine(cp);
    var reader = engine.createSchemaReader();
    return await reader.readSchema('code_metrics');
  }

  readSchema().then((Schema schema) {
    test('read_schema', () {
      // Grab the three Table objects from the Schema
      final Table cl = schema._code_locations;
      final Table cp = schema._code_packages;
      final Table ru = schema._rusage_delta;

      // Create the query - this function takes Iterable<Expr>
      final q = new Query(
          [
            cl._id,
            cl._label,
            cl._file_name,
            cp._id,
            ru._id,
            abs(ru._cpu_mhz, 'MHZ'),
            new Col(cp._id, 'CpId'),
            times(ru._cpu_mhz, ru._cpu_mhz, 'MHZ_SQRD')
          ]..addAll(cp.getColumns(['name', 'descr'])),
          filter: ands([
            ne(cl._label, cl._file_name),
            ne(cl._label, 'goo'),
            not(le(abs(cl._line_number), 2)),
            not(ge(abs(cl._line_number), 1 << 25)),
            notNull(cl._git_commit),
            and(le(ru._cpu_mhz, 1.3e30), ge(ru._cpu_mhz, 2e2))
          ]));

      print(engine.queryVisitor.select(q));
    });
  });

// end <main>
}
