part of magus.schema;

abstract class SchemaVisitor {
  // custom <class SchemaVisitor>

  String dropAll(Schema schema);
  String createAll(Schema schema);
  String recreateSchema(Schema schema) {
    dropAll(schema);
    createAll(schema);
  }

  // end <class SchemaVisitor>
}

abstract class TableVisitor {
  // custom <class TableVisitor>

  String createTable(Table table);
  String dropTable(Table table);

  // end <class TableVisitor>
}

abstract class ExprVisitor {
  // custom <class ExprVisitor>

  String evalExpr(Expr expr);

  // end <class ExprVisitor>
}

abstract class QueryVisitor {
  // custom <class QueryVisitor>

  String select(Query query);

  // end <class QueryVisitor>
}

class SqlVisitor
  implements SchemaVisitor,
    TableVisitor,
    ExprVisitor,
    QueryVisitor {
  // custom <class SqlVisitor>

  String dropAll(Schema schema);
  String createAll(Schema schema);
  String createTable(Table table);
  String dropTable(Table table);
  String evalExpr(Expr expr);
  String select(Query query) {
  }

  // end <class SqlVisitor>
}
// custom <part dialect>
// end <part dialect>
