/// Support for parsing odbc ini files to retrieve DSN
///
library magus.odbc_ini;

import 'dart:io';
import 'package:ini/ini.dart';
import 'package:path/path.dart' as path;
import 'package:sqljocky/sqljocky.dart';
// custom <additional imports>
// end <additional imports>

/// Contains entries *of interest* per datasource parsed from an odbc ini file
class OdbcIni {

  Map<String, OdbcIniEntry> get entries => _entries;

  // custom <class OdbcIni>

  factory OdbcIni([String fileName]) {
    if(fileName == null) {
      final env = Platform.environment;
      if(env != null) {
        final home = env['HOME'];
        if(home != null) {
          fileName = path.join(home, '.odbc.ini');
        }
      }
    }
    String contents = new File(fileName).readAsStringSync();
    final config = new Config.fromString(contents);
    final entries = {};

    config
      .sections()
      .forEach((String section) {
        final parms = {};

        config
          .options(section)
          .forEach((String opt) {
            if(_userRe.hasMatch(opt)) {
              parms['user'] = config.get(section, opt);
            } else if(_databaseRe.hasMatch(opt)) {
              parms['database'] = config.get(section, opt);
            } else if(_passwordRe.hasMatch(opt)) {
              parms['password'] = config.get(section, opt);
            }
            if(parms.length == 3) {
              entries[section] =
                new OdbcIniEntry(parms['user'],
                    parms['password'], parms['database']);
            }
          });
      });

    return new OdbcIni._(entries);
  }

  static ConnectionPool createConnectionPool(String dsn, [String odbcIniFileName]) {
    final ini = new OdbcIni(odbcIniFileName);
    final entry = ini.getEntry(dsn);
    return new ConnectionPool(user: entry.user,
        password: entry.password, db: dsn);
  }

  toString() =>
    _entries.keys.map((String section) => '''
[$section]
${_entries[section]}''').join('\n');

  OdbcIni._(this._entries);

  OdbcIniEntry getEntry(String dsn) => _entries[dsn];

  static RegExp _userRe = new RegExp('user', caseSensitive:false);
  static RegExp _passwordRe = new RegExp('pwd', caseSensitive:false);
  static RegExp _databaseRe = new RegExp('database', caseSensitive:false);

  // end <class OdbcIni>

  Map<String, OdbcIniEntry> _entries = {};

}


/// odbc.ini entries for a given DSN that are *of interest* enabling connection
class OdbcIniEntry {

  OdbcIniEntry(this._user, this._password, this._database);

  String get user => _user;
  String get password => _password;
  String get database => _database;

  // custom <class OdbcIniEntry>
  // end <class OdbcIniEntry>

  String _user;
  String _password;
  String _database;

}


// custom <library odbc_ini>
// end <library odbc_ini>
