library magus.postgres.engine;

import 'package:magus/postgres/schema_reader.dart';
import 'package:magus/schema.dart';
import 'package:postgres/postgres.dart';

export 'package:magus/postgres/schema_reader.dart';

// custom <additional imports>
// end <additional imports>

class PostgresEngine implements Engine {
  PostgreSQLConnection get connection => _connection;

  // custom <class PostgresEngine>

  PostgresEngine(this._connection);

  SchemaWriter createSchemaWriter() {
    return null;
  }

  SchemaReader createSchemaReader() => new PostgresSchemaReader(this);

  SchemaVisitor get schemaVisitor {
    return null;
  }

  TableVisitor get tableVisitor {
    return null;
  }

  ExprVisitor get exprVisitor {
    return null;
  }

  QueryVisitor get queryVisitor {
    return null;
  }

  // end <class PostgresEngine>

  final PostgreSQLConnection _connection;
  final PostgresVisitor _visitor;
}

class PostgresVisitor extends SqlVisitor {
  // custom <class PostgresVisitor>
  // end <class PostgresVisitor>

}

// custom <library engine>
// end <library engine>
