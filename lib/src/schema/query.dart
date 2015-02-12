part of magus.schema;

class JoinType implements Comparable<JoinType> {
  static const INNER = const JoinType._(0);
  static const LEFT = const JoinType._(1);
  static const RIGHT = const JoinType._(2);
  static const FULL = const JoinType._(3);

  static get values => [
    INNER,
    LEFT,
    RIGHT,
    FULL
  ];

  final int value;

  int get hashCode => value;

  const JoinType._(this.value);

  copy() => this;

  int compareTo(JoinType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case INNER: return "inner";
      case LEFT: return "left";
      case RIGHT: return "right";
      case FULL: return "full";
    }
    return null;
  }

  static JoinType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "inner": return INNER;
      case "left": return LEFT;
      case "right": return RIGHT;
      case "full": return FULL;
      default: return null;
    }
  }

  int toJson() => value;
  static JoinType fromJson(int v) {
    return v==null? null : values[v];
  }

}

const INNER = JoinType.INNER;
const LEFT = JoinType.LEFT;
const RIGHT = JoinType.RIGHT;
const FULL = JoinType.FULL;


/// SQL Expression
abstract class Expr {
  Expr([ this.alias ]);

  String alias;
  // custom <class Expr>

  toString() => 'Some Expr';

  get aliased => alias != null?
    '$this as $alias' : toString();

  addColumns(Set<Column> out);

  // end <class Expr>
}

class Col extends Expr {
  Column get column => _column;
  // custom <class Col>
  Col(this._column, [String alias]) : super(alias);

  get name => '${_column.table.name}.${_column.name}';

  toString() => name;

  addColumns(Set<Column> out) => out.add(_column);

  // end <class Col>
  final Column _column;
}

class Literal extends Expr {
  dynamic get value => _value;
  // custom <class Literal>

  Literal(this._value, [String alias]) : super(alias);

  toString() =>
    _value is String? "'$_value'" : '$_value';

  addColumns(Set<Column> out) {}

  // end <class Literal>
  dynamic _value;
}

class Pred extends Expr {
  // custom <class Pred>
  Pred([ String alias ]) : super(alias);
  // end <class Pred>
}

class UnaryExpr extends Expr {
  Expr expr;
  // custom <class UnaryExpr>

  UnaryExpr(e, [String alias]) :
    super(alias),
    expr = makeExpr(e);

  addColumns(Set<Column> out) => expr.addColumns(out);

  // end <class UnaryExpr>
}

class BinaryExpr extends Expr {
  Expr a;
  Expr b;
  // custom <class BinaryExpr>

  BinaryExpr(a, b, [ String alias ]) :
    super(alias),
    this.a = makeExpr(a),
    this.b = makeExpr(b);

  addColumns(Set<Column> out) {
    a.addColumns(out);
    b.addColumns(out);
  }

  // end <class BinaryExpr>
}

/// Query unary predicate
class UnaryPred extends Pred {
  Expr expr;
  // custom <class UnaryPred>

  UnaryPred(e, [String alias]) :
    super(alias),
    expr = makeExpr(e);

  addColumns(Set<Column> out) => expr.addColumns(out);

  // end <class UnaryPred>
}

class BinaryPred extends Pred {
  Expr a;
  Expr b;
  // custom <class BinaryPred>

  BinaryPred(a, b, [ String alias ]) :
    super(alias),
    this.a = makeExpr(a),
    this.b = makeExpr(b);

  addColumns(Set<Column> out) {
    a.addColumns(out);
    b.addColumns(out);
  }

  // end <class BinaryPred>
}

class MultiPred extends Pred {
  List<Expr> exprs;
  // custom <class MultiPred>

  MultiPred(exprs, [ String alias ]) :
    super(alias),
    this.exprs = makeExprs(exprs).toList();

  addColumns(Set<Column> out) =>
    exprs.forEach((e) => e.addColumns(out));

  // end <class MultiPred>
}

class IsNull extends UnaryPred {
  // custom <class IsNull>

  IsNull(expr, [String alias]) :
    super(makeExpr(expr), alias),

  toString() => '$expr IS NULL';

  // end <class IsNull>
}

class NotNull extends UnaryPred {
  // custom <class NotNull>

  NotNull(expr, [String alias]) :
    super(makeExpr(expr), alias);

  toString() => '$expr IS NOT NULL';

  // end <class NotNull>
}

class Not extends UnaryPred {
  // custom <class Not>

  Not(expr, [String alias]) :
    super(makeExpr(expr), alias);

  toString() => 'NOT $expr';

  // end <class Not>
}

class And extends BinaryPred {
  // custom <class And>

  And(a, b, [String alias]) :
    super(a, b, alias);

  toString() => '$a AND $b';

  // end <class And>
}

class Or extends BinaryPred {
  // custom <class Or>

  Or(a, b, [String alias]) :
    super(a, b, alias);

  toString() => '$a OR $b';

  // end <class Or>
}

class MultiAnd extends MultiPred {
  // custom <class MultiAnd>

  MultiAnd(exprs, [String alias]) :
    super(makeExprs(exprs).toList(), alias);

  toString() => exprs.join(' AND \n');

  // end <class MultiAnd>
}

class MultiOr extends MultiPred {
  // custom <class MultiOr>

  MultiOr(exprs, [String alias]) :
    super(makeExprs(exprs).toList(), alias);

  toString() => exprs.join(' OR \n');

  // end <class MultiOr>
}

class Eq extends BinaryPred {
  // custom <class Eq>

  Eq(a, b, [String alias]) :
    super(a, b, alias);

  toString() => '$a = $b';

  // end <class Eq>
}

class NotEq extends BinaryPred {
  // custom <class NotEq>

  NotEq(a, b, [String alias]) :
    super(a, b, alias);

  toString() => '$a <> $b';

  // end <class NotEq>
}

class Like extends BinaryPred {
  // custom <class Like>

  Like(a, b, [String alias]) :
    super(a, b, alias);

  toString() => '$a LIKE $b';

  // end <class Like>
}

class Gt extends BinaryPred {
  // custom <class Gt>

  Gt(a, b, [String alias]) :
    super(a, b, alias);

  toString() => '$a > $b';

  // end <class Gt>
}

class Lt extends BinaryPred {
  // custom <class Lt>

  Lt(a, b, [String alias]) :
    super(a, b, alias);

  toString() => '$a < $b';

  // end <class Lt>
}

class Ge extends BinaryPred {
  // custom <class Ge>

  Ge(a, b, [String alias]) :
    super(a, b, alias);

  toString() => '$a >= $b';

  // end <class Ge>
}

class Le extends BinaryPred {
  // custom <class Le>

  Le(a, b, [String alias]) :
    super(a, b, alias);

  toString() => '$a <= $b';

  // end <class Le>
}

class Abs extends UnaryExpr {
  // custom <class Abs>

  Abs(expr, [String alias]) :
    super(makeExpr(expr), alias);

  toString() => 'ABS($expr)';

// end <class Abs>
}

class Plus extends BinaryExpr {
  // custom <class Plus>

  Plus(a, b, [String alias]) :
    super(a, b, alias);

  toString() => '$a - $b';

  // end <class Plus>
}

class Minus extends BinaryExpr {
  // custom <class Minus>

  Minus(a, b, [String alias]) :
    super(a, b, alias);

  toString() => '$a - $b';

  // end <class Minus>
}

class Times extends BinaryExpr {
  // custom <class Times>

  Times(a, b, [String alias]) :
    super(a, b, alias);

  toString() => '$a * $b';

  // end <class Times>
}

class Join {
  const Join(this.table, this.joinExpr, this.joinType);

  final Table table;
  final Expr joinExpr;
  final JoinType joinType;
  // custom <class Join>

  toString() => '$joinType join ${table.name} on ${joinExpr}';

  // end <class Join>
}

/// Build a query by specifying returns, joins [optionally], and a filter
/// (i.e. where clause). The query builder will find all tables referenced by the
/// returns and filter expressions in order to collect all tables that need to be
/// specified. Joins can be imputed for normal foreign key relationships by
/// traversing all fkey relationships on the tables referenced by the query. Joins
/// are imputed with equality expressions linking the two tables.
///
class Query {
  final List<Expr> returns;
  List<Join> get joins => _joins;
  final bool imputeJoins;
  final Pred filter;
  final bool distinct;
  /// Tables hit by the query - determined by all columns hit by [returns] and [joins]
  List<Table> get tables => _tables;
  // custom <class Query>

  Query._all(this.returns, this._joins, this.imputeJoins, this.filter,
    this.distinct, this._tables);

  factory Query(List columnsOrExprs,
      {
        List<Joins> joins : null,
        bool imputeJoins : true,
        Pred filter : null,
        bool distinct : false
      }) {
    final columns = new Set<Column>();
    final exprs = makeExprs(columnsOrExprs).toList();
    exprs.forEach((expr) => expr.addColumns(columns));
    if(filter != null) {
      filter.addColumns(columns);
    }
    final tables = new Set.from(columns.map((c) => c.table));

    if(tables.isEmpty)
      throw "Queries must resolve to at least one table";

    if(imputeJoins) {
      final ordered = tables.first.schema.tables;
      final imputedJoins = _imputeJoins(tables);
      // order the joins so tables being referred to come first
      // Note b <=> a, to reverse natural order of tables for this op
      imputedJoins.sort((a,b) =>
          ordered.indexOf(b.table).compareTo(
            ordered.indexOf(a.table)));

      joins = joins == null?
        imputedJoins : (joins..addAll(imputedJoins));
    }

    return new Query._all(exprs, joins, imputeJoins, filter,
        distinct, tables.toList());
  }

  static List<Join> _imputeJoins(Set<Table> tables) {
    final joins = [];
    for(var table in tables) {
      table.foreignKeys.forEach((String fkeyName, ForeignKey fkey) {
        if(tables.contains(fkey.refTable)) {
          int end = fkey.columns.length;
          for(int i=0; i<end; i++) {
            final c1 = fkey.columns[i];
            final c2 = fkey.refColumns[i];
            joins.add(join(fkey.refTable, eq(c1, c2)));
          }
        }
      });
    }
    return joins;
  }

  // end <class Query>
  final List<Join> _joins;
  final List<Table> _tables;
}
// custom <part query>

makeExpr(dynamic e) =>
  e is Expr? e :
  e is Column? new Col(e) :
  (e is double || e is int || e is String)? new Literal(e) :
  throw '${e.runtimeType} is not convertible to Expr';

makeExprs(Iterable<dynamic> exprs) =>
  exprs.map((dynamic e) => makeExpr(e));

query(Iterable<dynamic> exprs) =>
  new Query(makeExprs(exprs).toList());

col(Column e, [alias]) => new Col(e, alias);
and(a, b, [alias]) => new And(a, b, alias);
ands(Iterable exprs, [alias]) => new MultiAnd(exprs, alias);
or(a, b, [alias]) => new Or(a, b, alias);
ors(Iterable exprs, [alias]) => new MultiOr(exprs, alias);
not(expr, [alias]) => new Not(expr, alias);
eq(a, b, [alias]) => new Eq(a, b, alias);
ne(a, b, [alias]) => new NotEq(a, b, alias);
notNull(expr, [alias]) => new NotNull(expr, alias);
ge(expr, [alias]) => new Ge(expr, alias);
le(expr, [alias]) => new Le(expr, alias);
abs(expr, [alias]) => new Abs(expr, alias);
plus(a, b, [alias]) => new Plus(a, b, alias);
minus(a, b, [alias]) => new Minus(a, b, alias);
times(a, b, [alias]) => new Times(a, b, alias);

join(Table table, Expr joinExpr, [ JoinType joinType = INNER ]) =>
  new Join(table, joinExpr, joinType);

_orderItems(Iterable ordering, Set subset) =>
  ordering.where((e) => subset.contains(e));


// end <part query>
