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
    ..testLibraries = [
      library('schema_reading')
    ]
    ..libraries = [

      library('odbc_ini')
      ..imports = [
        'dart:io',
        'package:sqljocky/sqljocky.dart',
        'package:ini/ini.dart',
        "'package:path/path.dart' as path",
      ]
      ..classes = [
        class_('odbc_ini')
        ..defaultMemberAccess = RO
        ..members = [
          member('entries')..type = 'Map<String, OdbcIniEntry>'..classInit = {}
        ],
        class_('odbc_ini_entry')
        ..defaultMemberAccess = RO
        ..members = [
          member('user')..ctors = [''],
          member('password')..ctors = [''],
          member('database')..ctors = [''],
        ]
      ],

      library('schema')
      ..parts = [
        part('sql_type')
        ..classes = [
          class_('sql_type'),
        ],
      ]
      ..classes = [
        class_('schema_reader'),
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
          member('type')..type = 'SqlType',
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
      library('mysql')
      ..imports = [
        'dart:async',
        'package:sqljocky/sqljocky.dart',
        'package:magus/odbc_ini.dart',
        'package:magus/schema.dart',
      ]
      ..parts = [
        part('sql_type'),
        part('schema_reader')
        ..classes = [
          class_('mysql_schema_reader')
          ..immutable = true
          ..implement = [ 'SchemaReader' ]
          ..members = [
            member('connection_pool')..type = 'ConnectionPool'
          ],
        ]
      ],

    ];
  ebisu.generate();
}
