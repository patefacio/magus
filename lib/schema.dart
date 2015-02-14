library magus.schema;

import 'dart:async';
import 'dart:collection';
import 'dart:convert' as convert;
import 'dart:mirrors';
import 'package:ebisu/ebisu_utils.dart' as ebisu_utils;
import 'package:quiver/iterables.dart';
// custom <additional imports>
// end <additional imports>

part 'src/schema/sql_type.dart';
part 'src/schema/engine.dart';
part 'src/schema/dialect.dart';
part 'src/schema/query.dart';

/// Establishes an interface to write schema to a specific Engine
/// derivative.
abstract class SchemaWriter {
  SchemaWriter(this._engine);

  Engine get engine => _engine;
  // custom <class SchemaWriter>

  writeSchema(Schema schema);

  // end <class SchemaWriter>
  Engine _engine;
}

/// Establishes an interface to read schema to a specific Engine
/// derivative.
abstract class SchemaReader {
  SchemaReader(this._engine);

  Engine get engine => _engine;
  // custom <class SchemaReader>

  Future<Schema> readSchema(String schemaName);

  // end <class SchemaReader>
  Engine _engine;
}

/// For a depth first search of related tables, this is one entry
class FkeyPathEntry {
  FkeyPathEntry(this._name, this._table, this._refTable, this._foreignKeySpec);

  FkeyPathEntry._default();

  /// Name of the fkey constraint linking these tables
  String get name => _name;
  /// Table doing the referring
  Table get table => _table;
  /// Table referred to with foreign key constraint
  Table get refTable => _refTable;
  /// Details of the foreign key at this path
  ForeignKeySpec get foreignKeySpec => _foreignKeySpec;
  // custom <class FkeyPathEntry>

  get _srcColNames => foreignKeySpec.columns;
  get _refColNames => foreignKeySpec.refColumns;

  // end <class FkeyPathEntry>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "name": ebisu_utils.toJson(name),
      "table": ebisu_utils.toJson(table),
      "refTable": ebisu_utils.toJson(refTable),
      "foreignKeySpec": ebisu_utils.toJson(foreignKeySpec),
  };

  static FkeyPathEntry fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new FkeyPathEntry._default()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    _name = jsonMap["name"];
    _table = Table.fromJson(jsonMap["table"]);
    _refTable = Table.fromJson(jsonMap["refTable"]);
    _foreignKeySpec = ForeignKeySpec.fromJson(jsonMap["foreignKeySpec"]);
  }
  String _name;
  Table _table;
  Table _refTable;
  ForeignKeySpec _foreignKeySpec;
}

/// A named database schema with the corresponding table metadata
/// associated with a specific engine.
///
class Schema {
  Schema(this.engine, this.name, this.tables) {
    // custom <Schema>

    _tableMap = tables.fold({}, (prev, t) => prev..[t.name] = t);

    assert(_tableMap.length == tables.length);

    // first sort the tables by name
    tables.sort((a,b) => a.name.compareTo(b.name));

    // While iterating over tables track how many tables directly refer to each
    Map<Table, int> deps = {};

    tables.forEach((Table table) {
      table._schema = this;
      final tname = table.name;

      if(!_dfsFkeyPaths.containsKey(tname)) {
        final path = _dfsTableVisitorImpl(table, []);
        _dfsFkeyPaths[tname] = path;

        Map<String, ForeignKeys> fkeys = {};
        path
          .where((fpe) => fpe.table == table)
          .forEach((FkeyPathEntry fpe) {
            final refTable = fpe.refTable;

            // Found a table referring to refTable
            if(deps.containsKey(refTable)) {
              deps[refTable]++;
            } else {
              deps[refTable] = 1;
            }

            assert(!fkeys.containsKey(fpe.name));
            fkeys[fpe.name] = new ForeignKey(fpe.name,
                fpe._srcColNames.map((col) => table.getColumn(col)).toList(),
                refTable,
                fpe._refColNames.map((col) => refTable.getColumn(col)).toList());
          });
        table._foreignKeys = fkeys;
      }
    });

    // tables with no fkey reference to them can be viewed as root nodes in the
    // graph of tables. This is used to order the tables appropriately
    _orderTablesByRelations(
      tables.where((t) => !deps.containsKey(t)));

    // end <Schema>
  }

  Schema._default();

  final Engine engine;
  final String name;
  final List<Table> tables;
  // custom <class Schema>

  Table getTable(String tableName) => _tableMap[tableName];
  Iterable<Table> getTables(Iterable<String> tnames) =>
    tnames.map((String tname) => getTable(tname));

  noSuchMethod(Invocation invocation) {
    if(invocation.isGetter) {
      String tname = MirrorSystem.getName(invocation.memberName);
      if(tname.startsWith('_')) {
        final result = getTable(tname.substring(1));
        if(result != null)
          return result;
      }
    }
    return super.noSuchMethod(invocation);
  }

  List<FkeyPathEntry> getDfsPath(String tableName) => _dfsFkeyPaths[tableName];

  _dfsTableVisitorImpl(Table table, List<FkeyPathEntry> entries) {

    table.foreignKeySpecs.forEach((ForeignKeySpec fkey) {
      final refTable = getTable(fkey.refTable);
      _dfsTableVisitorImpl(refTable, entries);
      entries.add(new FkeyPathEntry(fkey.name, table, refTable, fkey));
    });

    return entries;
  }

  // It is useful to be able to iterate over tables in an order allowing table
  // deletion/construction. This function takes all rootTables (i.e. tables with
  // no fkey dependencies on them) and walks their dependencies dfs to get
  // ordering. Reassigns list of table with that ordering
  _orderTablesByRelations(Iterable<Table> rootTables) {

    var ordered = new LinkedHashSet<Table>.identity();
    addToOrdered(Table table) {
      table
        .foreignKeys
        .values
        .forEach((ForeignKey fk) => addToOrdered(fk.refTable));
      ordered.add(table);
    };

    rootTables.forEach((t) => addToOrdered(t));

    assert(_dfsFkeyPaths.length == tables.length);
    assert(ordered.length == tables.length);

    tables..clear()..addAll(ordered);
  }

  // end <class Schema>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "engine": ebisu_utils.toJson(engine),
      "name": ebisu_utils.toJson(name),
      "tables": ebisu_utils.toJson(tables),
      "tableMap": ebisu_utils.toJson(_tableMap),
      "dfsFkeyPaths": ebisu_utils.toJson(_dfsFkeyPaths),
  };

  static Schema fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new Schema._default()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    engine = Engine.fromJson(jsonMap["engine"]);
    name = jsonMap["name"];
    // tables is List<Table>
    tables = ebisu_utils
      .constructListFromJsonData(jsonMap["tables"],
                                 (data) => Table.fromJson(data))
    ;
    // tableMap is Map<String, Table>
    _tableMap = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["tableMap"],
        (value) => Table.fromJson(value))
    ;
    // dfsFkeyPaths is Map<String, FkeyPathEntry>
    _dfsFkeyPaths = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["dfsFkeyPaths"],
        (value) => FkeyPathEntry.fromJson(value))
  ;
  }
  Map<String, Table> _tableMap = {};
  /// For each table a list of path entries comprising a depth-first-search
  /// of referred to tables
  Map<String, FkeyPathEntry> _dfsFkeyPaths = {};
}

/// Spec class for a ForeignKey - indicating the relationship by naming
/// the tables and columns
///
class ForeignKeySpec {
  const ForeignKeySpec(this.name, this.refTable, this.columns, this.refColumns);

  final String name;
  final String refTable;
  final List<String> columns;
  final List<String> refColumns;
  // custom <class ForeignKeySpec>
  // end <class ForeignKeySpec>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "name": ebisu_utils.toJson(name),
      "refTable": ebisu_utils.toJson(refTable),
      "columns": ebisu_utils.toJson(columns),
      "refColumns": ebisu_utils.toJson(refColumns),
  };

  static ForeignKeySpec fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new ForeignKeySpec._fromJsonMapImpl(json);
  }

  ForeignKeySpec._fromJsonMapImpl(Map jsonMap) :
    name = jsonMap["name"],
    refTable = jsonMap["refTable"],
    // columns is List<String>
    columns = ebisu_utils
      .constructListFromJsonData(jsonMap["columns"],
                                 (data) => data),
    // refColumns is List<String>
    refColumns = ebisu_utils
      .constructListFromJsonData(jsonMap["refColumns"],
                                 (data) => data);

  ForeignKeySpec._copy(ForeignKeySpec other) :
    name = other.name,
    refTable = other.refTable,
    columns = other.columns == null? null: new List.from(other.columns),
    refColumns = other.refColumns == null? null: new List.from(other.refColumns);

}

class ForeignKey {
  const ForeignKey(this.name, this.columns, this.refTable, this.refColumns);

  final String name;
  final List<Column> columns;
  final Table refTable;
  final List<Column> refColumns;
  // custom <class ForeignKey>

  get columnPairs => zip([ columns, refColumns ]);

  // end <class ForeignKey>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "name": ebisu_utils.toJson(name),
      "columns": ebisu_utils.toJson(columns),
      "refTable": ebisu_utils.toJson(refTable),
      "refColumns": ebisu_utils.toJson(refColumns),
  };

  static ForeignKey fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new ForeignKey._fromJsonMapImpl(json);
  }

  ForeignKey._fromJsonMapImpl(Map jsonMap) :
    name = jsonMap["name"],
    // columns is List<Column>
    columns = ebisu_utils
      .constructListFromJsonData(jsonMap["columns"],
                                 (data) => Column.fromJson(data)),
    refTable = Table.fromJson(jsonMap["refTable"]),
    // refColumns is List<Column>
    refColumns = ebisu_utils
      .constructListFromJsonData(jsonMap["refColumns"],
                                 (data) => Column.fromJson(data));

  ForeignKey._copy(ForeignKey other) :
    name = other.name,
    columns = other.columns == null? null :
      (new List.from(other.columns.map((e) =>
        e == null? null : e.copy()))),
    refTable = other.refTable == null? null : other.refTable.copy(),
    refColumns = other.refColumns == null? null :
      (new List.from(other.refColumns.map((e) =>
        e == null? null : e.copy())));

}

class UniqueKey {
  const UniqueKey(this.name, this.columns);

  final String name;
  final List<Column> columns;
  // custom <class UniqueKey>
  // end <class UniqueKey>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "name": ebisu_utils.toJson(name),
      "columns": ebisu_utils.toJson(columns),
  };

  static UniqueKey fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new UniqueKey._fromJsonMapImpl(json);
  }

  UniqueKey._fromJsonMapImpl(Map jsonMap) :
    name = jsonMap["name"],
    // columns is List<Column>
    columns = ebisu_utils
      .constructListFromJsonData(jsonMap["columns"],
                                 (data) => Column.fromJson(data));

  UniqueKey._copy(UniqueKey other) :
    name = other.name,
    columns = other.columns == null? null :
      (new List.from(other.columns.map((e) =>
        e == null? null : e.copy())));

}

class Table {
  Table(this.name, this.columns, this.primaryKey, this.uniqueKeys,
    this.foreignKeySpecs) {
    // custom <Table>

    columns.forEach((Column c) {
      c._table = this;
      _columnMap[c.name] = c;
    });

    assert(_columnMap.length == columns.length);
    assert(primaryKey.every((c) => columns.contains(c)));

    _valueColumns = columns
      .where((col) => !primaryKey.any((pkeyCol) => pkeyCol.name == col.name))
      .toList();

    // end <Table>
  }

  Table._default();

  final String name;
  final List<Column> columns;
  final List<Column> primaryKey;
  final List<UniqueKey> uniqueKeys;
  final List<ForeignKeySpec> foreignKeySpecs;
  List<Column> get valueColumns => _valueColumns;
  Map<String, ForeignKey> get foreignKeys => _foreignKeys;
  Schema get schema => _schema;
  // custom <class Table>

  Column getColumn(String columnName) => _columnMap[columnName];
  Iterable<Column> getColumns(Iterable<String> cnames) =>
    cnames.map((String cname) => getColumn(cname));

  noSuchMethod(Invocation invocation) {
    if(invocation.isGetter) {
      String cname = MirrorSystem.getName(invocation.memberName);
      if(cname.startsWith('_')) {
        final result = getColumn(cname.substring(1));
        if(result != null)
          return result;
      }
    }
    return super.noSuchMethod(invocation);
  }

  get hasAutoIncrement => columns.any((c) => c.autoIncrement);
  get hasForeignKey => foreignKeySpecs.length > 0;
  get nonAutoColumns => columns.where((c) => !c.autoIncrement);
  get pkeyColumns => primaryKey;

  isPrimaryKeyColumn(Column col) => primaryKey.contains(col);

  // end <class Table>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "name": ebisu_utils.toJson(name),
      "columns": ebisu_utils.toJson(columns),
      "primaryKey": ebisu_utils.toJson(primaryKey),
      "uniqueKeys": ebisu_utils.toJson(uniqueKeys),
      "foreignKeySpecs": ebisu_utils.toJson(foreignKeySpecs),
      "columnMap": ebisu_utils.toJson(_columnMap),
      "valueColumns": ebisu_utils.toJson(valueColumns),
      "foreignKeys": ebisu_utils.toJson(foreignKeys),
  };

  static Table fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new Table._default()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    name = jsonMap["name"];
    // columns is List<Column>
    columns = ebisu_utils
      .constructListFromJsonData(jsonMap["columns"],
                                 (data) => Column.fromJson(data))
    ;
    // primaryKey is List<Column>
    primaryKey = ebisu_utils
      .constructListFromJsonData(jsonMap["primaryKey"],
                                 (data) => Column.fromJson(data))
    ;
    // uniqueKeys is List<UniqueKey>
    uniqueKeys = ebisu_utils
      .constructListFromJsonData(jsonMap["uniqueKeys"],
                                 (data) => UniqueKey.fromJson(data))
    ;
    // foreignKeySpecs is List<ForeignKeySpec>
    foreignKeySpecs = ebisu_utils
      .constructListFromJsonData(jsonMap["foreignKeySpecs"],
                                 (data) => ForeignKeySpec.fromJson(data))
    ;
    // columnMap is Map<String, Column>
    _columnMap = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["columnMap"],
        (value) => Column.fromJson(value))
    ;
    // valueColumns is List<Column>
    _valueColumns = ebisu_utils
      .constructListFromJsonData(jsonMap["valueColumns"],
                                 (data) => Column.fromJson(data))
    ;
    // foreignKeys is Map<String, ForeignKey>
    _foreignKeys = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["foreignKeys"],
        (value) => ForeignKey.fromJson(value))
  ;
  }
  Map<String, Column> _columnMap = {};
  List<Column> _valueColumns;
  Map<String, ForeignKey> _foreignKeys;
  Schema _schema;
}

class Column {
  Column(this.name, this.type, this.nullable, this.autoIncrement);

  Column._default();

  final String name;
  final SqlType type;
  final bool nullable;
  final bool autoIncrement;
  Table get table => _table;
  // custom <class Column>

  get qualifiedName => '${_table.name}.$name';

  // end <class Column>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "name": ebisu_utils.toJson(name),
      "type": ebisu_utils.toJson(type),
      "nullable": ebisu_utils.toJson(nullable),
      "autoIncrement": ebisu_utils.toJson(autoIncrement),
  };

  static Column fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new Column._default()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    name = jsonMap["name"];
    type = SqlType.fromJson(jsonMap["type"]);
    nullable = jsonMap["nullable"];
    autoIncrement = jsonMap["autoIncrement"];
  }
  Table _table;
}

// custom <library schema>

// end <library schema>
