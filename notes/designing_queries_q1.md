I'm using Dart to model sql statements. My approach is not to try to parse SQL queries, but to build queries into a Dart model using schema information. The goal is to be able to create/model complex queries easily in Dart. Initially I'm not even interested in running the queries - just using them to generate the SQL text.

Here is some sample code showing a not useful, silly but decently complex query on three tables. I've not worked out the join logic yet.

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

    query(Iterable<dynamic> exprs) =>
      new Query(makeExprs(exprs).toList());

    ...

    // Grab the three Table objects from the Schema
    final cl = schema.code_locations;
    final cp = schema.code_packages;
    final ru = schema.rusage_delta;

    // Create the query - this function takes Iterable<Expr>
    final q = query(
      [
        cl.id, cl.label, cl.file_name, cp.id,
        ru.id, abs(ru.cpu_mhz, 'MHZ'), new Col(cp.id, 'CpId'),
      ]
      ..addAll(cp.getColumns(['name', 'descr'])))
      ..filter = ands(
        [
          ne(cl.label, cl.file_name),
          ne(cl.label, 'goo'),
          not(le(abs(cl.line_number), 2)),
          not(ge(abs(cl.line_number), 1<<25)),
          notNull(cl.git_commit),
          and(le(ru.cpu_mhz, 1.3e30), ge(ru.cpu_mhz, 2e2))
        ]);

    print(engine.queryVisitor.select(q));

That code prints:

    select
      code_locations.id,
      code_locations.label,
      code_locations.file_name,
      code_packages.id,
      rusage_delta.id,
      ABS(rusage_delta.cpu_mhz) as MHZ,
      code_packages.id as CpId,
      code_packages.name,
      code_packages.descr
    from
      code_locations,
      code_packages,
      rusage_delta
    where
      code_locations.label <> code_locations.file_name AND
      code_locations.label <> 'goo' AND
      NOT ABS(code_locations.line_number) <= 2 AND
      NOT ABS(code_locations.line_number) >= 33554432 AND
      code_locations.git_commit IS NOT NULL AND
      rusage_delta.cpu_mhz <= 1.3e+30 AND rusage_delta.cpu_mhz >= 200.0

So, I'm doing some things that are questionable. The schema is created on the fly for Mysql by reading/parsing _'show create table'_ for each table. Yet the 'id' column on table _cl_ is accessed like _cl.id_. To do this I use _noSuchMethod_ to access the column without requiring quotes. This feels nice, except when the column name matches a field in the Column class. For instance, Column class representing a database column in a table has a _name_. But many tables might also have a column named _name_. So in those cases doing _table.name_ returns the name of the table and not the column in the table named _name_. Does this conflict warrant abandoning the nice syntax of _cl.id_ and preferring _cl.getColumn('id')_ exclusively?

I have a class little hierarchy:

 * Expr
 * Pred extends Expr
 * UnaryPred extends Pred
 * BinaryPred extends Pred
 * Not extends UnaryPred
 * NotEq extends BinaryPred
 * And extends BinaryPred
 * ...

So, the where clause is really a single Pred that may be composed of
multiple Preds. Since new is not optional (will it ever be?) and I did
not want to have loads of:

    new NotEq(new Le(new Abs(cl.line_number), new Literal(2)))

I created small creator functions:

    and(a, b, [alias]) => new And(a,b,alias);
    ands(Iterable exprs, [alias]) => new MultiAnd(exprs,alias);
    or(a, b, [alias]) => new Or(a,b,alias);
    ors(Iterable exprs, [alias]) => new MultiOr(exprs,alias);
    not(expr, [alias]) => new Not(expr,alias);
    eq(a, b, [alias]) => new Eq(a,b,alias);
    ne(a, b, [alias]) => new NotEq(a,b,alias);

Is this a bad idea - (e.g. too non-intuitive to have functions used just to get around not wanting to type new)? What are the alternatives/tradeoffs?
