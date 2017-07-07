#!/usr/bin/env dart
import 'dart:io';
import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:postgres/postgres.dart';
import 'package:sqljocky/sqljocky.dart';
// custom <additional imports>

import 'package:magus/magus_ini.dart';
import 'package:magus/mysql.dart';
import 'package:ebisu/ebisu.dart';

// end <additional imports>
//! The parser for this script
ArgParser _parser;
//! The comment and usage associated with this script
void _usage() {
  print(r'''
null
''');
  print(_parser.getUsage());
}

//! Method to parse command line options.
//! The result is a map containing all options, including positional options
Map _parseArgs(List<String> args) {
  ArgResults argResults;
  Map result = {};
  List remaining = [];

  _parser = new ArgParser();
  try {
    /// Fill in expectations of the parser
    _parser.addFlag('help',
        help: r'''
Display this help screen
''',
        abbr: 'h',
        defaultsTo: false);

    _parser.addOption('file',
        help: '',
        defaultsTo: null,
        allowMultiple: false,
        abbr: 'f',
        allowed: null);
    _parser.addOption('ini-entry',
        help: r'''
ini entry for credentials
''',
        defaultsTo: 'magus',
        allowMultiple: false,
        abbr: 'i',
        allowed: null);
    _parser.addOption('log-level',
        help: r'''
Select log level from:
[ all, config, fine, finer, finest, info, levels,
  off, severe, shout, warning ]

''',
        defaultsTo: null,
        allowMultiple: false,
        abbr: null,
        allowed: null);

    /// Parse the command line options (excluding the script)
    argResults = _parser.parse(args);
    if (argResults.wasParsed('help')) {
      _usage();
      exit(0);
    }
    result['file'] = argResults['file'];
    result['ini-entry'] = argResults['ini-entry'];
    result['help'] = argResults['help'];
    result['log-level'] = argResults['log-level'];

    if (result['log-level'] != null) {
      const choices = const {
        'all': Level.ALL,
        'config': Level.CONFIG,
        'fine': Level.FINE,
        'finer': Level.FINER,
        'finest': Level.FINEST,
        'info': Level.INFO,
        'levels': Level.LEVELS,
        'off': Level.OFF,
        'severe': Level.SEVERE,
        'shout': Level.SHOUT,
        'warning': Level.WARNING
      };
      final selection = choices[result['log-level'].toLowerCase()];
      if (selection != null) Logger.root.level = selection;
    }

    return {'options': result, 'rest': argResults.rest};
  } catch (e) {
    _usage();
    throw e;
  }
}

final _logger = new Logger('runSql');

main(List<String> args) async {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
  Map argResults = _parseArgs(args);
  Map options = argResults['options'];
  List positionals = argResults['rest'];
  try {
    if (options["file"] == null)
      throw new ArgumentError("option: file is required");
  } on ArgumentError catch (e) {
    print(e);
    _usage();
    exit(-1);
  }
  // custom <runSql main>

  Logger.root.level = Level.INFO;
  final file = new File(options['file']);
  final ext = extension(file.path);
  final sql = file.readAsStringSync();

  if (ext == '.psql') {
    print('processing psql');
    final config = new MagusIni().getEntry(options['ini-entry']);
    final hostname = config.hostname ?? 'localhost';
    final port = config.port ?? 5432;
    print(config);
    final connection = new PostgreSQLConnection(
        hostname, port, config.database,
        username: config.user, password: config.password);
    await connection.open();
    for (var query in sql.split(';')) {
      query = query.trim();
      final result = await connection.execute(query + ';');
      _logger.info('${indentBlock(query)}\n----(${result} rows affected)');
    }
    await connection.close();
  } else if (ext == '.mysql') {
    print(options['ini-entry']);
    final connectionPool = createConnectionPool(options['ini-entry']);
    for (var query in sql.split(';')) {
      query = query.trim();
      if (query.isNotEmpty) {
        final result = await connectionPool.query(query + ';');
        _logger.info(
            'ran\n${indentBlock(query)}\n----(${result.affectedRows} rows affected)');
      }
    }

    await connectionPool.closeConnectionsNow();
  }

  // end <runSql main>
}

// custom <runSql global>
// end <runSql global>
