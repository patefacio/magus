library magus.schema;

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
}

class Column {
  const Column(this.name, this.type, this.nullable, this.autoIncrement);

  final String name;
  final SqlType type;
  final bool nullable;
  final bool autoIncrement;
  // custom <class Column>
  // end <class Column>
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
