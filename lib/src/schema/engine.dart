part of magus.schema;

/// An engine is what client code interacts with to read or write schema.
///
/// It provides access to dialect specific visitors that can generate
/// appropriate [Table], [Expr], [Query] and [Schema]
abstract class Engine {
  // custom <class Engine>

  /// Create a [SchemaWriter] specific to this engine
  SchemaWriter createSchemaWriter();

  /// Create a [SchemaReader] specific to this engine
  SchemaReader createSchemaReader();

  /// Provide [SchemaVisitor] specific to this engine
  SchemaVisitor get schemaVisitor;

  /// Provide [TableVisitor] specific to this engine
  TableVisitor get tableVisitor;

  /// Provide [ExprVisitor] specific to this engine
  ExprVisitor get exprVisitor;

  /// Provide [QueryVisitor] specific to this engine
  QueryVisitor get queryVisitor;

  // end <class Engine>

}

// custom <part engine>
// end <part engine>
