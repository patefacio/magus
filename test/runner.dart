import 'package:logging/logging.dart';
import 'postgres/test_postgres_schema_reader.dart'
    as test_postgres_schema_reader;
import 'mysql/test_mysql_table_parse.dart' as test_mysql_table_parse;
import 'mysql/test_mysql_schema_reader.dart' as test_mysql_schema_reader;
import 'mysql/test_mysql_sql_generation.dart' as test_mysql_sql_generation;

void main() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  test_postgres_schema_reader.main(null);
  test_mysql_table_parse.main(null);
  test_mysql_schema_reader.main(null);
  //test_mysql_sql_generation.main(null);
}
