import "dart:io";
import "package:path/path.dart" as path;
import "package:ebisu/ebisu_dart_meta.dart";
import "package:logging/logging.dart";

String _topDir;

void main() {
  Logger.root.onRecord.listen((LogRecord r) =>
      print("${r.loggerName} [${r.level}]:\t${r.message}"));
  String here = path.absolute(Platform.script.toFilePath());
  _topDir = path.dirname(path.dirname(here));
  bool hasJsonToString = true;
  final descr = 'Package for reading schema and making metadata available';
  System ebisu = system('magus')
    ..doc = descr
    ..pubSpec.doc = descr
    ..pubSpec.homepage = 'https://github.com/patefacio/magus'
    ..pubSpec.version = '0.0.13'
    ..license = 'boost'
    ..includesHop = true
    ..rootPath = '$_topDir'
    ..testLibraries = [
      library('schema_reading'),
      library('sql_generation'),
      library('test_mysql_table_parse'),
    ]
    ..libraries = [

      library('odbc_ini')
      ..doc = '''
Support for parsing odbc ini files to retrieve DSN
'''
      ..imports = [
        'dart:io',
        'package:sqljocky/sqljocky.dart',
        'package:ini/ini.dart',
        "'package:path/path.dart' as path",
      ]
      ..classes = [
        class_('odbc_ini')
        ..doc = 'Contains entries *of interest* per datasource parsed from an odbc ini file'
        ..defaultMemberAccess = RO
        ..members = [
          member('entries')..type = 'Map<String, OdbcIniEntry>'..classInit = {}
        ],
        class_('odbc_ini_entry')
        ..doc = 'odbc.ini entries for a given DSN that are *of interest* enabling connection'
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
          class_('sql_type')
          ..doc = 'Establishes interface for support sql datatypes'
          ..isAbstract = true,

          class_('type_extension_mixin')
          ..implement = [ 'SqlType' ]
          ..isAbstract = true
          ..members = [
            member('extension')..type = 'dynamic',
          ],

          class_('sql_string')
          ..hasJsonSupport = true
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('length')
            ..doc = 'Length of the integer *in characters*'
            ..type = 'int'..access = RO..ctors = [''],
            member('is_varying')
            ..doc = 'If true the string is varying'
            ..type = 'bool'..access = RO..ctors = [''],
          ],

          class_('sql_int')
          ..hasJsonToString = hasJsonToString
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('length')
            ..doc = 'Length of the integer *in bytes*'
            ..type = 'int'..access = RO..ctors = [''],
            member('display_length')
            ..doc = 'Display length used by databases to limit width when displaying'
            ..type = 'int'..access = RO..ctors = [''],
            member('unsigned')
            ..doc = 'Display if true the integer is unsigned'
            ..type = 'bool'..access = RO..ctorsOpt = ['']..ctorInit = 'false',
          ],

          class_('sql_decimal')
          ..hasJsonToString = hasJsonToString
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('precision')
            ..type = 'int'..access = RO..ctors = [''],
            member('scale')..type = 'int'..access = RO..ctors = [''],
            member('unsigned')..type = 'bool'..access = RO..ctorsOpt = ['']..ctorInit = 'false',
          ],

          class_('sql_binary')
          ..hasJsonToString = hasJsonToString
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('length')..type = 'int'..access = RO..ctors = [''],
            member('is_varying')..type = 'bool'..access = RO..ctorsOpt = ['']..ctorInit = 'true',
          ],

          class_('sql_float')
          ..hasJsonToString = hasJsonToString
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('precision')
            ..doc = 'Precision *in digits* - for portability best not to use'
            ..type = 'int'..access = RO..ctors = [''],
            member('scale')
            ..doc = 'Scale *in digits* - for portability best not to use'
            ..type = 'int'..access = RO..ctors = [''],
            member('unsigned')..type = 'bool'..access = RO..ctorsOpt = ['']..ctorInit = 'false',
          ],

          class_('sql_date')
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
          ],

          class_('sql_time')
          ..hasJsonToString = hasJsonToString
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('has_timezone')..type = 'bool'..access = RO..ctors = [''],
          ],

          class_('sql_timestamp')
          ..hasJsonToString = hasJsonToString
          ..mixins = [ 'TypeExtensionMixin' ]
          ..members = [
            member('has_timezone')..type = 'bool'..access = RO..ctors = [''],
            member('auto_update')..type = 'bool'..access = RO..ctors = [''],
          ],

          class_('sql_type_visitor')
          ..doc = '''
Different engines may have different support/naming conventions for
the DDL corresponding to a given type. This provides an interface for
a specific dialect to generate proper DDL for the supported type.
'''
          ..isAbstract = true,

        ],
        part('engine')
        ..classes = [
          class_('engine')
          ..doc = '''
An engine is what client code interacts with to read or write schema.

It provides access to dialect specific visitors that can generate
appropriate [Table], [Expr], [Query] and [Schema]
'''
          ..isAbstract = true,
        ],
        part('dialect')
        ..doc = '''
Library of interfaces allowing decoupling of specific database implmentation
from functional requirements'''
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
        ..doc = 'Metadata required for a database query'
        ..enums = [
          enum_('join_type')
          ..hasLibraryScopedValues = true
          ..isSnakeString = true
          ..hasJsonSupport = true
          ..values = [
            id('inner'), id('left'), id('right'), id('full'),
          ],
        ]
        ..classes = [
          class_('expr')
          ..doc = '''
SQL Expression

The reqult of a query is essentially a collection of expressions comprising the
return fields. This provides such an interface.

'''
          ..isAbstract = true
          ..members = [
            member('alias')..ctorsOpt = [''],
          ],
          class_('col')
          ..doc = 'A single database column expression'
          ..extend = 'Expr'
          ..members = [
            member('column')..type = 'Column'..access = RO..isFinal = true,
          ],
          class_('literal')
          ..doc = 'A literal expression, as in SQL integer, float, string'
          ..extend = 'Expr'
          ..members = [
            member('value')..type = 'dynamic'..access = RO,
          ],
          class_('pred')
          ..isAbstract = true
          ..doc = 'A predicate expression - i.e. an expression that returns true or false'
          ..extend = 'Expr',
          class_('unary_expr')
          ..doc = 'A unary expression'
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
          ..isImmutable = true
          ..members = [
            member('table')..type = 'Table',
            member('join_expr')..type = 'Expr',
            member('join_type')..type = 'JoinType',
          ],
          class_('query')
          ..doc = '''
Build a query by specifying returns, joins [optionally], and a filter
(i.e. where clause). The query builder will find all tables referenced by the
returns and filter expressions in order to collect all tables that need to be
specified. Joins can be imputed for normal foreign key relationships by
traversing all fkey relationships on the tables referenced by the query. Joins
are imputed with equality expressions linking the two tables.
'''
          ..members = ([
            member('returns')..type = 'List<Expr>',
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
        class_('schema_writer')
        ..doc = '''
Establishes an interface to write schema to a specific Engine
derivative.'''
        ..members = [ member('engine')..access = RO..type = 'Engine'..ctors = [''] ]
        ..isAbstract = true,
        class_('schema_reader')
        ..doc = '''
Establishes an interface to read schema to a specific Engine
derivative.'''
        ..members = [ member('engine')..access = RO..type = 'Engine'..ctors = [''] ]
        ..isAbstract = true,
        class_('fkey_path_entry')
        ..doc = 'For a depth first search of related tables, this is one entry'
        ..hasJsonToString = hasJsonToString
        //..isImmutable = true
        ..members = [
          member('name')
          ..doc = 'Name of the fkey constraint linking these tables'
          ..access = RO..ctors = [''],
          member('table')
          ..doc = 'Table doing the referring'..type = 'Table'
          ..access = RO..ctors = [''],
          member('ref_table')
          ..doc = 'Table referred to with foreign key constraint'..type = 'Table'
          ..access = RO..ctors = [''],
          member('foreign_key_spec')
          ..doc = 'Details of the foreign key at this path'
          ..type = 'ForeignKeySpec'
          ..access = RO..ctors = [''],
        ],
        class_('schema')
        ..doc = '''
A named database schema with the corresponding table metadata
associated with a specific engine.
'''
        ..ctorCustoms = ['']
        ..hasJsonToString = hasJsonToString
        ..members = ([
          member('engine')..type = 'Engine'..isJsonTransient = true,
          member('name'),
          member('tables')..type = 'List<Table>',
        ]
        ..forEach((member) =>
            member
            ..access = RO
            ..ctors = [''])
        ..addAll([
          member('table_map')
          ..type = 'Map<String, Table>'..access = IA..classInit = {},
          member('dfs_fkey_paths')
          ..doc = '''
For each table a list of path entries comprising a depth-first-search
of referred to tables
'''
          ..type = 'Map<String, List<FkeyPathEntry>>'..access = IA..classInit = {},
        ])),
        class_('foreign_key_spec')
        ..doc = '''
Spec class for a ForeignKey - indicating the relationship by naming
the tables and columns
'''
        ..hasJsonToString = hasJsonToString
        ..isImmutable = true
        ..members = [
          member('name'),
          member('ref_table'),
          member('columns')..type = 'List<String>',
          member('ref_columns')..type = 'List<String>',
        ],
        class_('foreign_key')
        ..hasJsonToString = hasJsonToString
        ..members = [
          member('name')
          ..doc = 'Name of the foreign key definition'
          ..access = RO..ctors = [''],
          member('columns')
          ..doc = 'Columns present in the foreign key'
          ..type = 'List<Column>'..access = RO..ctors = [''],
          member('ref_table')
          ..doc = ''
          ..type = 'Table'..access = RO..ctors = [''],
          member('ref_columns')
          ..doc = ''
          ..type = 'List<Column>'..access = RO..ctors = [''],
        ],
        class_('unique_key')
        ..hasJsonToString = hasJsonToString
        ..isImmutable = true
        ..members = [
          member('name'),
          member('columns')..type = 'List<Column>',
        ],
        class_('table')
        ..hasJsonToString = hasJsonToString
        ..ctorCustoms = ['']
        ..members = (
          [
            member('name'),
            member('columns')..type = 'List<Column>',
            member('primary_key')..type = 'List<Column>',
            member('unique_keys')..type = 'List<UniqueKey>',
            member('foreign_key_specs')..type = 'List<ForeignKeySpec>',
          ]
          ..forEach((member) =>
              member
              ..access = RO
              ..ctors = [''])
          ..addAll([
            member('column_map')..type = 'Map<String, Column>'..access = IA..classInit = {},
            member('value_columns')..type = 'List<Column>'..access = RO,
            member('foreign_keys')..type = 'Map<String, ForeignKey>'..access = RO,
            member('schema')..type = 'Schema'..access = RO..isJsonTransient = true,
          ])),
        class_('column')
        ..hasJsonToString = hasJsonToString
        ..members = (
          [
            member('name'),
            member('type')..type = 'SqlType',
            member('nullable')..type = 'bool',
            member('auto_increment')..type = 'bool',
          ]
          ..forEach((member) => member..access = RO..ctors = [''])
          ..addAll([
            member('table')..type = 'Table'..access = RO..isJsonTransient = true,
          ])),
      ],
      library('mysql')
      ..includesLogger = true
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
          ..extend = 'SchemaWriter'
          ..members = [
            member('connection_pool')..type = 'ConnectionPool'..access = IA
          ],
        ],
        part('schema_reader')
        ..classes = [
          class_('unique_key_spec')
          ..doc = 'Spec class for a UniqueKey - indicating the relationship by naming the columns in the unique constraint'
          ..hasJsonToString = hasJsonToString
          ..isImmutable = true
          ..members = [
            member('name'),
            member('columns')..type = 'List<String>',
          ],
          class_('primary_key_spec')
          ..doc = 'Spec class for a PrimaryKey - indicating the key columns with string names'
          ..hasJsonToString = hasJsonToString
          ..isImmutable = true
          ..members = [
            member('columns')..type = 'List<String>',
          ],
          class_('mysql_schema_parser'),
          class_('mysql_schema_reader')
          ..extend = 'SchemaReader'
          ..members = [
            member('connection_pool')..type = 'ConnectionPool'..access = IA..isFinal = true
          ],
        ]
      ],

    ];
  ebisu.generate();
}
