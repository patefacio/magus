import 'package:logging/logging.dart';
import 'test_mysql_table_parse.dart' as test_mysql_table_parse;

main() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  test_mysql_table_parse.main();
}

