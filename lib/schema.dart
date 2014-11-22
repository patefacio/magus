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

class Schema {
  const Schema(this.name, this.tables);

  final String name;
  final List<Table> tables;
  // custom <class Schema>
  // end <class Schema>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "name": ebisu_utils.toJson(name),
      "tables": ebisu_utils.toJson(tables),
  };

  static Schema fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new Schema._fromJsonMapImpl(json);
  }

  Schema._fromJsonMapImpl(Map jsonMap) :
    name = jsonMap["name"],
    // tables is List<Table>
    tables = ebisu_utils
      .constructListFromJsonData(jsonMap["tables"],
                                 (data) => Table.fromJson(data));

  Schema._copy(Schema other) :
    name = other.name,
    tables = other.tables == null? null :
      (new List.from(other.tables.map((e) =>
        e == null? null : e.copy())));

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
