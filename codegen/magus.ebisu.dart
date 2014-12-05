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
  bool jsonToString = true;
  System ebisu = system('magus')
    ..doc = 'Database schema retrieval'
    ..includeHop = true
    ..rootPath = '$_topDir'
    ..testLibraries = [
      library('schema_reading'),
      library('sql_generation'),
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
      ..imports = [
        'package:quiver/iterables.dart',
        'async',
        'collection',
        'mirrors',
      ]
      ..parts = [
        part('sql_type')
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
          ..jsonToString = jsonToString
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('length')..type = 'int'..isFinal = true..ctors = [''],
            member('display_length')..type = 'int'..isFinal = true..ctors = [''],
            member('unsigned')..type = 'bool'..isFinal = true..ctorsOpt = ['']..ctorInit = 'false'
          ],

          class_('sql_decimal')
          ..jsonToString = jsonToString
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('precision')..type = 'int'..isFinal = true..ctors = [''],
            member('scale')..type = 'int'..isFinal = true..ctors = [''],
            member('unsigned')..type = 'bool'..isFinal = true..ctorsOpt = ['']..ctorInit = 'false',
          ],

          class_('sql_binary')
          ..jsonToString = jsonToString
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('length')..type = 'int'..isFinal = true..ctors = [''],
            member('is_varying')..type = 'bool'..isFinal = true..ctorsOpt = ['']..ctorInit = 'true',
          ],

          class_('sql_float')
          ..jsonToString = jsonToString
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
          ..jsonToString = jsonToString
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('has_timezone')..type = 'bool'..isFinal = true..ctors = [''],
          ],

          class_('sql_timestamp')
          ..jsonToString = jsonToString
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('has_timezone')..type = 'bool'..isFinal = true..ctors = [''],
            member('auto_update')..type = 'bool'..isFinal = true..ctors = [''],
          ],

          class_('sql_type_visitor')..isAbstract = true,

        ],
        part('engine')
        ..classes = [
          class_('engine')..isAbstract = true,
        ],
        part('dialect')
        ..classes = [
          class_('schema_visitor')..isAbstract = true,
          class_('table_visitor')..isAbstract = true,
          class_('expr_visitor')..isAbstract = true,
          class_('query_visitor')..isAbstract = true,
          class_('sql_visitor')..implement = [
            'SchemaVisitor', 'TableVisitor', 'ExprVisitor', 'QueryVisitor'
          ],
        ],
        part('query')
        ..enums = [
          enum_('join_type')
          ..libraryScopedValues = true
          ..isSnakeString = true
          ..jsonSupport = true
          ..values = [
            id('inner'), id('left'), id('right'), id('full'),
          ],
        ]
        ..classes = [
          class_('expr')
          ..doc = 'SQL Expression'
          ..isAbstract = true
          ..members = [
            member('alias')..ctorsOpt = [''],
          ],
          class_('col')
          ..extend = 'Expr'
          ..members = [
            member('column')..type = 'Column'..access = RO..isFinal = true,
          ],
          class_('literal')
          ..extend = 'Expr'
          ..members = [
            member('value')..type = 'dynamic'..access = RO,
          ],
          class_('pred')
          ..extend = 'Expr',
          class_('unary_expr')
          ..extend = 'Expr'
          ..members = [
            member('expr')..type = 'Expr',
          ],
          class_('binary_expr')
          ..extend = 'Expr'
          ..members = [
            member('a')..type = 'Expr',
            member('b')..type = 'Expr',
          ],
          class_('unary_pred')
          ..extend = 'Pred'
          ..doc = 'Query unary predicate'
          ..members = [
            member('expr')..type = 'Expr',
          ],
          class_('binary_pred')
          ..extend = 'Pred'
          ..members = [
            member('a')..type = 'Expr',
            member('b')..type = 'Expr',
          ],
          class_('multi_pred')
          ..extend = 'Pred'
          ..members = [
            member('exprs')..type = 'List<Expr>',
          ],
          class_('is_null')
          ..extend = 'UnaryPred',
          class_('not_null')
          ..extend = 'UnaryPred',
          class_('not')
          ..extend = 'UnaryPred',
          class_('and')
          ..extend = 'BinaryPred',
          class_('or')
          ..extend = 'BinaryPred',
          class_('multi_and')
          ..extend = 'MultiPred',
          class_('multi_or')
          ..extend = 'MultiPred',
          class_('eq')
          ..extend = 'BinaryPred',
          class_('not_eq')
          ..extend = 'BinaryPred',
          class_('like')
          ..extend = 'BinaryPred',
          class_('gt')
          ..extend = 'BinaryPred',
          class_('lt')
          ..extend = 'BinaryPred',
          class_('ge')
          ..extend = 'BinaryPred',
          class_('le')
          ..extend = 'BinaryPred',
          class_('abs')
          ..extend = 'UnaryExpr',
          class_('plus')
          ..extend = 'BinaryExpr',
          class_('minus')
          ..extend = 'BinaryExpr',
          class_('times')
          ..extend = 'BinaryExpr',
          class_('join')
          ..immutable = true
          ..members = [
            member('table')..type = 'Table',
            member('join_expr')..type = 'Expr',
            member('join_type')..type = 'JoinType',
          ],
          class_('query')
          ..members = ([
            member('returns')..type = 'List<Expr>',
            member('table')
            ..doc = 'Table to be queried and joined against'
            ..type = 'Table',
            member('joins')..type = 'List<Join>'..access = RO,
            member('impute_joins')..type = 'bool',
            member('filter')..type = 'Pred',
            member('distinct')..type = 'bool',
            member('tables')
            ..doc = 'Tables hit by the query - determined by all columns hit by [returns] and [joins]'
            ..type = 'List<Table>'..access = RO,
          ]..map((m) => m.isFinal = true).toList()),
        ]
      ]
      ..classes = [
        class_('schema_writer')..isAbstract = true,
        class_('schema_reader')..isAbstract = true,
        class_('fkey_path_entry')
        ..doc = 'For a depth first search of related tables, this is one entry'
        ..jsonToString = jsonToString
        ..immutable = true
        ..members = [
          member('name')..doc = 'Name of the fkey constraint linking these tables',
          member('table')..doc = 'Table doing the referring'..type = 'Table',
          member('ref_table')..doc = 'Table referred to with foreign key constraint'..type = 'Table',
          member('foreign_key_spec')..type = 'ForeignKeySpec',
        ],
        class_('schema')
        ..ctorCustoms = ['']
        ..jsonToString = jsonToString
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
        ..jsonToString = jsonToString
        ..immutable = true
        ..members = [
          member('name'),
          member('ref_table'),
          member('columns')..type = 'List<String>',
          member('ref_columns')..type = 'List<String>',
        ],
        class_('foreign_key')
        ..immutable = true
        ..jsonToString = jsonToString
        ..members = [
          member('name'),
          member('columns')..type = 'List<Column>',
          member('ref_table')..type = 'Table',
          member('ref_columns')..type = 'List<Column>',
        ],
        class_('unique_key')
        ..jsonToString = jsonToString
        ..immutable = true
        ..members = [
          member('name'),
          member('columns')..type = 'List<Column>',
        ],
        class_('table')
        ..jsonToString = jsonToString
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
            member('column_map')..type = 'Map<String, Column>'..access = IA..classInit = {},
            member('value_columns')..type = 'List<Column>'..access = RO,
            member('foreign_keys')..type = 'Map<String, ForeignKey>'..access = RO,
            member('schema')..type = 'Schema'..access = RO..jsonTransient = true,
          ])),
        class_('column')
        ..jsonToString = jsonToString
        ..members = (
          [
            member('name'),
            member('type')..type = 'SqlType',
            member('nullable')..type = 'bool',
            member('auto_increment')..type = 'bool',
          ]
          ..forEach((member) => member..isFinal = true..ctors = [''])
          ..addAll([
            member('table')..type = 'Table'..access = RO..jsonTransient = true,
          ])),
      ],
      library('mysql')
      ..imports = [
        'dart:async',
        "'package:sqljocky/sqljocky.dart' hide Query",
        'package:magus/odbc_ini.dart',
        'package:magus/schema.dart',
      ]
      ..parts = [
        part('engine')
        ..classes = [
          class_('mysql_engine')
          ..implement = [ 'Engine' ]
          ..members = [
            member('connection_pool')..type = 'ConnectionPool'..access = IA..isFinal = true,
            member('visitor')..type = 'MysqlVisitor'..access = IA..isFinal = true
            ..ctorInit = 'new MysqlVisitor',
          ],
          class_('mysql_visitor')
          ..extend = 'SqlVisitor',
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
          ..jsonToString = jsonToString
          ..immutable = true
          ..members = [
            member('name'),
            member('columns')..type = 'List<String>',
          ],
          class_('primary_key_spec')
          ..doc = 'Spec class for a PrimaryKey - indicating the key columns with string names'
          ..jsonToString = jsonToString
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
