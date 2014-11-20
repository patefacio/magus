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
        ..enums = [
          enum_('sql_base_type')
          ..libraryScopedValues = true
          ..values = [

            'boolean',

            'char',
            'varchar',
            'text',

            'binary',
            'varbinary',
            'blob',

            'int',
            'smallint',
            'bigint',

            'decimal',
            'float',

            'date',
            'time',
            'datetime',
            'timestamp',

          ].map((t) => id(t)).toList(),
        ]
        ..classes = [
          class_('sql_type')..isAbstract = true,
          class_('base_type_mixin')
          ..implement = [ 'SqlType' ]
          ..isAbstract = true
          ..members = [
            member('base_type')..type = 'SqlBaseType',
          ],
          class_('length')..isAbstract = true,
          class_('length_mixin')..implement = [ 'Length' ]
          ..members = [
            member('length')..type = 'int'
          ],
          class_('display_length')..isAbstract = true,
          class_('display_length_mixin')..implement = [ 'DisplayLength' ]
          ..members = [
            member('display_length')..type = 'int'
          ],

          class_('sql_string')
          ..mixins = [ 'BaseTypeMixin' ]
          ..members = [
            member('length')..classInit = 0,
            member('display_length')..classInit = 0,
          ],

          class_('sql_int')
          ..mixins = [ 'BaseTypeMixin' ]
          ..members = [
            member('length')..classInit = 0,
            member('display_length')..classInit = 0,
          ],

          class_('sql_binary')
          ..mixins = [ 'BaseTypeMixin' ]
          ..members = [
            member('length')..classInit = 0,
          ],

          class_('sql_float')
          ..mixins = [ 'BaseTypeMixin' ]
          ..members = [
            member('length')..classInit = 0,
          ],

          class_('sql_temporal')
          ..mixins = [ 'BaseTypeMixin' ]
          ..members = [
          ],

          class_('sql_type_visitor')..isAbstract = true,

        ],
      ]
      ..classes = [
        class_('engine')..isAbstract = true,
        class_('schema_writer')..isAbstract = true,
        class_('schema_reader')..isAbstract = true,
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
          member('nullable')..type = 'bool',
          member('auto_increment')..type = 'bool',
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
        part('engine')
        ..classes = [
          class_('mysql_engine')
          ..immutable = true
          ..implement = [ 'Engine' ]
          ..members = [
            member('connection_pool')..type = 'ConnectionPool'..access = IA
          ],
        ],
        part('schema_writer')
        ..classes = [
          class_('mysql_schema_writer')
          ..immutable = true
          ..implement = [ 'SchemaWriter' ]
          ..members = [
            member('connection_pool')..type = 'ConnectionPool'..access = IA
          ],
        ],
        part('schema_reader')
        ..classes = [
          class_('mysql_schema_reader')
          ..immutable = true
          ..implement = [ 'SchemaReader' ]
          ..members = [
            member('connection_pool')..type = 'ConnectionPool'..access = IA
          ],
        ]
      ],

    ];
  ebisu.generate();
}
