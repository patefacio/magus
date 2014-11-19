library magus.schema;

// custom <additional imports>
// end <additional imports>

part 'src/schema/sql_type.dart';

class SchemaReader {


  // custom <class SchemaReader>
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

  const Column(this.name, this.type);

  final String name;
  final SqlType type;

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
