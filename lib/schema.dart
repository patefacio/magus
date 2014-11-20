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
}

class Table {
  const Table(this.name, this.columns, this.constraints);

  final String name;
  final List<Column> columns;
  final List<Constraint> constraints;
  // custom <class Table>
  // end <class Table>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "name": ebisu_utils.toJson(name),
      "columns": ebisu_utils.toJson(columns),
      "constraints": ebisu_utils.toJson(constraints),
  };

  static Table fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new Table._fromJsonMapImpl(json);
  }

  Table._fromJsonMapImpl(Map jsonMap) :
    name = jsonMap["name"],
    // columns is List<Column>
    columns = ebisu_utils
      .constructListFromJsonData(jsonMap["columns"],
                                 (data) => Column.fromJson(data)),
    // constraints is List<Constraint>
    constraints = ebisu_utils
      .constructListFromJsonData(jsonMap["constraints"],
                                 (data) => Constraint.fromJson(data));

  Table._copy(Table other) :
    name = other.name,
    columns = other.columns == null? null :
      (new List.from(other.columns.map((e) =>
        e == null? null : e.copy()))),
    constraints = other.constraints == null? null :
      (new List.from(other.constraints.map((e) =>
        e == null? null : e.copy())));

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

class Constraint {
  const Constraint(this.name);

  final String name;
  // custom <class Constraint>
  // end <class Constraint>
}

class ForeignKeyConstraint extends Constraint {
  // custom <class ForeignKeyConstraint>
  // end <class ForeignKeyConstraint>
}

class UniqueConstraint extends Constraint {
  // custom <class UniqueConstraint>
  // end <class UniqueConstraint>
}

// custom <library schema>
// end <library schema>
