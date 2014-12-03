part of magus.schema;

abstract class SchemaVisitor {
  // custom <class SchemaVisitor>

  String dropAll(Schema schema);
  String createAll(Schema schema);

  String recreateSchema(Schema schema) =>
    dropAll(schema) +
    createAll(schema);

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

  String dropAll(Schema schema) =>
    'Generic drop ${schema.tables.map((t) => t.name)} from schema';
  String createAll(Schema schema) =>
    'Generic create ${schema.tables.map((t) => t.name)} from schema';
  String createTable(Table table) =>
    'Generic create single table ${table.name}';
  String dropTable(Table table) =>
    'Generic drop single table ${table.name}';


  String select(Query query) => '''
select
  ${_returns(query).join(',\n  ')}
from
  ${query.tables.map((t) => t.name).join(',\n  ')}
${_filter(query)}
''';

  _filter(Query query) {
    final filter = query.filter;
    return filter == null?
      '' : 'where\n  ${filter.toString().replaceAll("\n", "\n  ")}';
  }

  _returns(Query query) =>
    query.returns.map((e) => e.aliased);

  // end <class SqlVisitor>
}
// custom <part dialect>
// end <part dialect>
