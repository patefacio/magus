library magus.schema;

import 'dart:convert' as convert;
import 'package:ebisu/ebisu_utils.dart' as ebisu_utils;
// custom <additional imports>
// end <additional imports>

part 'src/schema/sql_type.dart';

abstract class Engine {
  // custom <class Engine>

  SchemaWriter createSchemaWriter();
  SchemaReader createSchemaReader();

  // end <class Engine>
}

abstract class SchemaWriter {
  // custom <class SchemaWriter>

  writeSchema(Schema schema);

  // end <class SchemaWriter>
}

abstract class SchemaReader {
  // custom <class SchemaReader>

  Future<Schema> readSchema(String schemaName);

  // end <class SchemaReader>
}

/// For a depth first search of related tables, this is one entry
class FkeyPathEntry {
  const FkeyPathEntry(this.table, this.refTable, this.foreignKey);

  /// Table doing the referring
  final Table table;
  /// Table referred to with foreign key constraint
  final Table refTable;
  final ForeignKeyConstraint foreignKey;
  // custom <class FkeyPathEntry>
  // end <class FkeyPathEntry>
}

class Schema {
  Schema(this.name, this.tables) {
    // custom <Schema>
    tables.forEach((Table table) {
      assert(!_tableMap.containsKey(table.name));
      _tableMap[table.name] = table;
    });

    tables.forEach((Table table) =>
        _dfsFkeyPaths[table.name] = _dfsTableVisitorImpl(table, []));;

    // end <Schema>
  }

  Schema._default();

  final String name;
  final List<Table> tables;
  // custom <class Schema>

  Table getTable(String tableName) => _tableMap[tableName];
  List<FkeyPathEntry> getDfsPath(String tableName) => _dfsFkeyPaths[tableName];

  _dfsTableVisitorImpl(Table table, List<FkeyPathEntry> entries) {

    table.foreignKeys.forEach((ForeignKeyConstraint fkey) {
      final refTable = getTable(fkey.refTable);
      _dfsTableVisitorImpl(refTable, entries);
      entries.add(new FkeyPathEntry(table, refTable, fkey));
    });

    return entries;
  }

  // end <class Schema>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
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
  /// For each table a list of path entries comprising a depth-first-search of referred to tables
  Map<String, FkeyPathEntry> _dfsFkeyPaths = {};
}

class PrimaryKey {
  const PrimaryKey(this.columns);

  final List<String> columns;
  // custom <class PrimaryKey>
  // end <class PrimaryKey>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "columns": ebisu_utils.toJson(columns),
  };

  static PrimaryKey fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new PrimaryKey._fromJsonMapImpl(json);
  }

  PrimaryKey._fromJsonMapImpl(Map jsonMap) :
    // columns is List<String>
    columns = ebisu_utils
      .constructListFromJsonData(jsonMap["columns"],
                                 (data) => data);

  PrimaryKey._copy(PrimaryKey other) :
    columns = other.columns == null? null: new List.from(other.columns);

}

class ForeignKeyConstraint {
  const ForeignKeyConstraint(this.name, this.refTable, this.columns,
    this.refColumns);

  final String name;
  final String refTable;
  final List<String> columns;
  final List<String> refColumns;
  // custom <class ForeignKeyConstraint>
  // end <class ForeignKeyConstraint>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "name": ebisu_utils.toJson(name),
      "refTable": ebisu_utils.toJson(refTable),
      "columns": ebisu_utils.toJson(columns),
      "refColumns": ebisu_utils.toJson(refColumns),
  };

  static ForeignKeyConstraint fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new ForeignKeyConstraint._fromJsonMapImpl(json);
  }

  ForeignKeyConstraint._fromJsonMapImpl(Map jsonMap) :
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

  ForeignKeyConstraint._copy(ForeignKeyConstraint other) :
    name = other.name,
    refTable = other.refTable,
    columns = other.columns == null? null: new List.from(other.columns),
    refColumns = other.refColumns == null? null: new List.from(other.refColumns);

}

class UniqueKeyConstraint {
  const UniqueKeyConstraint(this.name, this.columns);

  final String name;
  final List<String> columns;
  // custom <class UniqueKeyConstraint>
  // end <class UniqueKeyConstraint>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "name": ebisu_utils.toJson(name),
      "columns": ebisu_utils.toJson(columns),
  };

  static UniqueKeyConstraint fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new UniqueKeyConstraint._fromJsonMapImpl(json);
  }

  UniqueKeyConstraint._fromJsonMapImpl(Map jsonMap) :
    name = jsonMap["name"],
    // columns is List<String>
    columns = ebisu_utils
      .constructListFromJsonData(jsonMap["columns"],
                                 (data) => data);

  UniqueKeyConstraint._copy(UniqueKeyConstraint other) :
    name = other.name,
    columns = other.columns == null? null: new List.from(other.columns);

}

class Table {
  Table(this.name, this.columns, this.primaryKey, this.foreignKeys,
    this.uniqueKeys);

  Table._default();

  final String name;
  final List<Column> columns;
  final PrimaryKey primaryKey;
  final List<ForeignKeyConstraint> foreignKeys;
  final List<UniqueKeyConstraint> uniqueKeys;
  // custom <class Table>

  Column getColumn(String column) =>
    columns.firstWhere((col) => col.name == column);

  get hasAutoIncrement => columns.any((c) => c.autoIncrement);
  get hasForeignKey => foreignKeys.length > 0;

  get pkeyColumns {
    if(_pkeyColumns == null)
      _pkeyColumns = primaryKey.columns.map((c) => getColumn(c)).toList();
    return _pkeyColumns;
  }

  get valueColumns {
    if(_valueColumns == null) {
      _valueColumns = columns
        .where((col) => !_pkeyColumns.any((pkeyCol) => pkeyCol.name == col.name))
        .toList();
    }
    return _valueColumns;
  }

  get nonAutoColumns => columns.where((c) => !c.autoIncrement);

  // end <class Table>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "name": ebisu_utils.toJson(name),
      "columns": ebisu_utils.toJson(columns),
      "primaryKey": ebisu_utils.toJson(primaryKey),
      "foreignKeys": ebisu_utils.toJson(foreignKeys),
      "uniqueKeys": ebisu_utils.toJson(uniqueKeys),
      "pkeyColumns": ebisu_utils.toJson(_pkeyColumns),
      "valueColumns": ebisu_utils.toJson(_valueColumns),
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
    primaryKey = PrimaryKey.fromJson(jsonMap["primaryKey"]);
    // foreignKeys is List<ForeignKeyConstraint>
    foreignKeys = ebisu_utils
      .constructListFromJsonData(jsonMap["foreignKeys"],
                                 (data) => ForeignKeyConstraint.fromJson(data))
    ;
    // uniqueKeys is List<UniqueKeyConstraint>
    uniqueKeys = ebisu_utils
      .constructListFromJsonData(jsonMap["uniqueKeys"],
                                 (data) => UniqueKeyConstraint.fromJson(data))
    ;
    // pkeyColumns is List<Column>
    _pkeyColumns = ebisu_utils
      .constructListFromJsonData(jsonMap["pkeyColumns"],
                                 (data) => Column.fromJson(data))
    ;
    // valueColumns is List<Column>
    _valueColumns = ebisu_utils
      .constructListFromJsonData(jsonMap["valueColumns"],
                                 (data) => Column.fromJson(data))
  ;
  }
  List<Column> _pkeyColumns;
  List<Column> _valueColumns;
}

class Column {
  const Column(this.name, this.type, this.nullable, this.autoIncrement);

  final String name;
  final SqlType type;
  final bool nullable;
  final bool autoIncrement;
  // custom <class Column>
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
    return new Column._fromJsonMapImpl(json);
  }

  Column._fromJsonMapImpl(Map jsonMap) :
    name = jsonMap["name"],
    type = SqlType.fromJson(jsonMap["type"]),
    nullable = jsonMap["nullable"],
    autoIncrement = jsonMap["autoIncrement"];

  Column._copy(Column other) :
    name = other.name,
    type = other.type == null? null : other.type.copy(),
    nullable = other.nullable,
    autoIncrement = other.autoIncrement;

}

// custom <library schema>

// end <library schema>
