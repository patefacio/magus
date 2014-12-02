part of magus.schema;

/// SQL Expression
class Expr {
  // custom <class Expr>
  // end <class Expr>
}

class Literal extends Expr {
  // custom <class Literal>
  // end <class Literal>
}

class Pred extends Expr {
  // custom <class Pred>
  // end <class Pred>
}

/// Query unary predicate
class UnaryPred extends Pred {
  Expr expr;
  // custom <class UnaryPred>
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
  const Query(this.returns, this.distinct, this.imputeJoins, this.filter);

  final List<Expr> returns;
  final bool distinct;
  final bool imputeJoins;
  final Pred filter;
  // custom <class Query>
  // end <class Query>
}

class QueryBuilder {
  QueryBuilder();

  List<Expr> returns;
  bool distinct = false;
  bool imputeJoins = true;
  Pred filter;
  // custom <class QueryBuilder>
  // end <class QueryBuilder>
  Query buildInstance() => new Query(
    returns, distinct, imputeJoins, filter);

  factory QueryBuilder.copyFrom(Query _) =>
    new QueryBuilder._copyImpl(_.copy());

  QueryBuilder._copyImpl(Query _) :
    returns = _.returns,
    distinct = _.distinct,
    imputeJoins = _.imputeJoins,
    filter = _.filter;


}

/// Create a QueryBuilder sans new, for more declarative construction
QueryBuilder
queryBuilder() =>
  new QueryBuilder();

// custom <part query>
// end <part query>
