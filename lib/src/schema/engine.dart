part of magus.schema;

abstract class Engine {
  // custom <class Engine>

  SchemaWriter createSchemaWriter();
  SchemaReader createSchemaReader();

  SchemaVisitor get schemaVisitor;
  TableVisitor get tableVisitor;
  ExprVisitor get exprVisitor;
  QueryVisitor get queryVisitor;

  // end <class Engine>
}
// custom <part engine>
// end <part engine>
