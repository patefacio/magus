part of magus.schema;

/// SQL Expression
class Expr {
  Expr([ this.alias ]);

  String alias;
  // custom <class Expr>
  // end <class Expr>
}

class Col extends Expr {
  Column get column => _column;
  // custom <class Col>
  Col(this._column, [String alias]) : super(alias);
  // end <class Col>
  final Column _column;
}

class Literal extends Expr {
  dynamic get value => _value;
  // custom <class Literal>
  Col(this._value, [String alias]) : super(alias);
  // end <class Literal>
  dynamic _value;
}

class Pred extends Expr {
  // custom <class Pred>
  Pred([ String alias ]) : super(alias);
  // end <class Pred>
}

/// Query unary predicate
class UnaryPred extends Pred {
  Expr expr;
  // custom <class UnaryPred>
  Unary(this._expr, [String alias]) : super(alias);
  // end <class UnaryPred>
}

class BinaryPred extends Pred {
  Expr a;
  Expr b;
  // custom <class BinaryPred>
  // end <class BinaryPred>
}

class MultiPred extends Pred {
  List<Expr> exprs;
  // custom <class MultiPred>
  // end <class MultiPred>
}

class IsNull extends UnaryPred {
  // custom <class IsNull>
  // end <class IsNull>
}

class Not extends UnaryPred {
  // custom <class Not>
  // end <class Not>
}

class And extends BinaryPred {
  // custom <class And>
  // end <class And>
}

class Or extends BinaryPred {
  // custom <class Or>
  // end <class Or>
}

class MultiAnd extends MultiPred {
  // custom <class MultiAnd>
  // end <class MultiAnd>
}

class MultiOr extends MultiPred {
  // custom <class MultiOr>
  // end <class MultiOr>
}

class Equal extends BinaryPred {
  // custom <class Equal>
  // end <class Equal>
}

class NotEqual extends BinaryPred {
  // custom <class NotEqual>
  // end <class NotEqual>
}

class Like extends BinaryPred {
  // custom <class Like>
  // end <class Like>
}

class Gt extends BinaryPred {
  // custom <class Gt>
  // end <class Gt>
}

class Lt extends BinaryPred {
  // custom <class Lt>
  // end <class Lt>
}

class Ge extends BinaryPred {
  // custom <class Ge>
  // end <class Ge>
}

class Le extends BinaryPred {
  // custom <class Le>
  // end <class Le>
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

_makeExpr(dynamic e) =>
    e is Expr? e :
    e is Column? new Col(e) :
    throw '${e.runtimeType} is not convertible to Expr';

makeExprs(Iterable<dynamic> exprs) =>
  exprs.map((dynamic e) => _makeExpr(e));

query(Iterable<dynamic> exprs) =>
  new Query(makeExprs(exprs).toList());

// end <part query>
