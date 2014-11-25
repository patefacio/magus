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
        ]
        ..classes = [
          class_('sql_type')..isAbstract = true,

          class_('type_extension_mixin')
          ..implement = [ 'SqlType' ]
          ..isAbstract = true
          ..members = [
            member('extension')..type = 'dynamic',
          ],

          class_('sql_string')
          ..jsonSupport = true
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('length')..type = 'int'..isFinal = true..ctors = [''],
            member('is_varying')..type = 'bool'..isFinal = true..ctorsOpt = ['']..ctorInit = 'true',
          ],

          class_('sql_int')
          ..jsonToString = true
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('length')..type = 'int'..isFinal = true..ctors = [''],
            member('display_length')..type = 'int'..isFinal = true..ctors = [''],
            member('unsigned')..type = 'bool'..isFinal = true..ctorsOpt = ['']..ctorInit = 'false'
          ],

          class_('sql_decimal')
          ..jsonToString = true
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('precision')..type = 'int'..isFinal = true..ctors = [''],
            member('scale')..type = 'int'..isFinal = true..ctors = [''],
            member('unsigned')..type = 'bool'..isFinal = true..ctorsOpt = ['']..ctorInit = 'false',
          ],

          class_('sql_binary')
          ..jsonToString = true
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('length')..type = 'int'..isFinal = true..ctors = [''],
            member('is_varying')..type = 'bool'..isFinal = true..ctorsOpt = ['']..ctorInit = 'true',
          ],

          class_('sql_float')
          ..jsonToString = true
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('precision')..type = 'int'..isFinal = true..ctors = [''],
            member('scale')..type = 'int'..isFinal = true..ctors = [''],
            member('unsigned')..type = 'bool'..isFinal = true..ctorsOpt = ['']..ctorInit = 'false',
          ],

          class_('sql_date')
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
          ],

          class_('sql_time')
          ..jsonToString = true
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('has_timezone')..type = 'bool'..isFinal = true..ctors = [''],
          ],

          class_('sql_timestamp')
          ..jsonToString = true
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('has_timezone')..type = 'bool'..isFinal = true..ctors = [''],
            member('auto_update')..type = 'bool'..isFinal = true..ctors = [''],
          ],

          class_('sql_type_visitor')..isAbstract = true,

        ],
      ]
      ..classes = [
        class_('engine')..isAbstract = true,
        class_('schema_writer')..isAbstract = true,
        class_('schema_reader')..isAbstract = true,
        class_('fkey_path_entry')
        ..doc = 'For a depth first search of related tables, this is one entry'
        ..immutable = true
        ..members = [
          member('table')..doc = 'Table doing the referring'..type = 'Table',
          member('ref_table')..doc = 'Table referred to with foreign key constraint'..type = 'Table',
          member('foreign_key_spec')..type = 'ForeignKeySpec',
        ],
        class_('schema')
        ..ctorCustoms = ['']
        ..jsonToString = true
        ..members = ([
          member('name'),
          member('tables')..type = 'List<Table>',
        ]
        ..forEach((member) =>
            member
            ..isFinal = true
            ..ctors = [''])
        ..addAll([
          member('table_map')..type = 'Map<String, Table>'..access = IA..classInit = {},
          member('dfs_fkey_paths')
          ..doc = 'For each table a list of path entries comprising a depth-first-search of referred to tables'
          ..type = 'Map<String, FkeyPathEntry>'..access = IA..classInit = {},
        ])),
        class_('foreign_key_spec')
        ..doc = 'Spec class for a ForeignKey - indicating the relationship by naming the tables and columns'
        ..jsonToString = true
        ..immutable = true
        ..members = [
          member('name'),
          member('ref_table'),
          member('columns')..type = 'List<String>',
          member('ref_columns')..type = 'List<String>',
        ],
        class_('foreign_key')
        ..immutable = true
        ..members = [
          member('name'),
          member('ref_table')..type = 'Table',
          member('columns')..type = 'List<Column>',
          member('ref_columns')..type = 'List<Column>',
        ],
        class_('unique_key')
        ..jsonToString = true
        ..immutable = true
        ..members = [
          member('name'),
          member('columns')..type = 'List<Column>',
        ],
        class_('table')
        ..jsonToString = true
        ..ctorCustoms = ['']
        ..members = (
          [
            member('name')..ctors = [''],
            member('columns')..type = 'List<Column>',
            member('primary_key')..type = 'List<Column>',
            member('unique_keys')..type = 'List<UniqueKey>',
            member('foreign_key_specs')..type = 'List<ForeignKeySpec>',
          ]
          ..forEach((member) =>
              member
              ..isFinal = true
              ..ctors = [''])
          ..addAll([
            member('value_columns')..type = 'List<Column>'..access = RO,
            member('foreign_keys')..type = 'Map<String, ForeignKey>'..access = IA,
          ])),
        class_('column')
        ..jsonToString = true
        ..immutable = true
        ..members = [
          member('name'),
          member('type')..type = 'SqlType',
          member('nullable')..type = 'bool',
          member('auto_increment')..type = 'bool',
        ],
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
          class_('unique_key_spec')
          ..doc = 'Spec class for a UniqueKey - indicating the relationship by naming the columns in the unique constraint'
          ..jsonToString = true
          ..immutable = true
          ..members = [
            member('name'),
            member('columns')..type = 'List<String>',
          ],
          class_('primary_key_spec')
          ..doc = 'Spec class for a PrimaryKey - indicating the key columns with string names'
          ..jsonToString = true
          ..immutable = true
          ..members = [
            member('columns')..type = 'List<String>',
          ],
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
