import "dart:io";
import "package:path/path.dart" as path;
import "package:ebisu/ebisu_dart_meta.dart";
import "package:logging/logging.dart";

String _topDir;

void main() {
  Logger.root.onRecord.listen((LogRecord r) =>
      print("${r.loggerName} [${r.level}]:\t${r.message}"));
  String here = path.absolute(Platform.script.path);
  _topDir = path.dirname(path.dirname(here));
  System ebisu = system('magus')
    ..doc = 'Database schema retrieval'
    ..includeHop = true
    ..rootPath = '$_topDir'
    ..libraries = [
      library('schema')
      ..classes = [
        class_('db_type'),
        class_('schema')
        ..immutable = true
        ..members = [
          member('name'),
          member('tables')..type = 'List<Table>',
        ],
        class_('table')
        ..immutable = true
        ..members = [
          member('name'),
          member('columns')..type = 'List<Column>',
          member('constraints')..type = 'List<Constraint>',
        ],
        class_('column')
        ..immutable = true
        ..members = [
          member('name'),
          member('type')..type = 'DbType',
        ],
        class_('constraint')
        ..immutable = true
        ..members = [
          member('name')
        ],
        class_('foreign_key_constraint')
        ..extend = 'Constraint',
        class_('unique_constraint')
        ..extend = 'Constraint',
      ],

    ];
  ebisu.generate();
}
