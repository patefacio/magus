part of magus.schema;

/// SQL Expression
class Expr {
  Expr([ this.alias ]);

  String alias;
  // custom <class Expr>

  toString() => 'Some Expr';

  get aliased => alias != null?
    '$this as $alias' : toString();

  // end <class Expr>
}

class Col extends Expr {
  Column get column => _column;
  // custom <class Col>
  Col(this._column, [String alias]) : super(alias);

  get name => '${_column.table.name}.${_column.name}';

  toString() => name;

  // end <class Col>
  final Column _column;
}

class Literal extends Expr {
  dynamic get value => _value;
  // custom <class Literal>

  Literal(this._value, [String alias]) : super(alias);

  toString() =>
    _value is String? "'$_value'" : '$_value';

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

  // end <class BinaryExpr>
}

/// Query unary predicate
class UnaryPred extends Pred {
  Expr expr;
  // custom <class UnaryPred>

  UnaryPred(e, [String alias]) :
    super(alias),
    expr = makeExpr(e);

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

  // end <class BinaryPred>
}

class MultiPred extends Pred {
  List<Expr> exprs;
  // custom <class MultiPred>

  MultiPred(exprs, [ String alias ]) :
    super(alias),
    this.exprs = makeExprs(exprs).toList();

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

class Query {
  List<Expr> returns = [];
  bool distinct = false;
  Pred filter;
  bool imputeJoins = true;
  List<Table> get tables => _tables;
  // custom <class Query>

  Query(this.returns) {
    Set tables = new Set();
    returns
      .where((r) => r is Col)
      .forEach((r) => tables.add(r.column.table));
    _tables = new List.from(tables);
  }

  // end <class Query>
  List<Table> _tables = [];
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

// end <part query>
