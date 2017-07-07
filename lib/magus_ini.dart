/// Support for parsing magus ini files to retrieve DSN
library magus.magus_ini;

import 'dart:io';
import 'package:ini/ini.dart';
import 'package:path/path.dart' as path;

// custom <additional imports>
// end <additional imports>

/// Contains entries *of interest* per datasource parsed from an magus ini file
class MagusIni {
  Map<String, MagusIniEntry> get entries => _entries;

  // custom <class MagusIni>

  factory MagusIni([String fileName]) {
    if (fileName == null) {
      final env = Platform.environment;
      if (env != null) {
        final home = env['HOME'];
        if (home != null) {
          fileName = path.join(home, '.magus.ini');
        }
      }
    }
    String contents = new File(fileName).readAsStringSync();
    final config = new Config.fromString(contents);
    final entries = {};

    config.sections().forEach((String section) {
      final parms = {};

      config.options(section).forEach((String opt) {
        if (_userRe.hasMatch(opt)) {
          parms['user'] = config.get(section, opt);
        } else if (_databaseRe.hasMatch(opt)) {
          parms['database'] = config.get(section, opt);
        } else if (_passwordRe.hasMatch(opt)) {
          parms['password'] = config.get(section, opt);
        } else if (_hostRe.hasMatch(opt)) {
          parms['hostname'] = config.get(section, opt);
        } else if (_portRe.hasMatch(opt)) {
          parms['port'] = config.get(section, opt);
        }
        if (parms.length >= 3) {
          entries[section] = new MagusIniEntry(parms['user'], parms['password'],
              parms['database'], parms['hostname'], parms['port']);
        }
      });
    });

    return new MagusIni._(entries);
  }

  toString() => _entries.keys.map((String section) => '''
[$section]
${_entries[section]}''').join('\n');

  MagusIni._(this._entries);

  MagusIniEntry getEntry(String dsn) => _entries[dsn];

  static RegExp _userRe = new RegExp('user', caseSensitive: false);
  static RegExp _passwordRe = new RegExp('pwd|password', caseSensitive: false);
  static RegExp _databaseRe = new RegExp('database', caseSensitive: false);
  static RegExp _hostRe = new RegExp('host|hostname', caseSensitive: false);
  static RegExp _portRe = new RegExp('port', caseSensitive: false);

  // end <class MagusIni>

  Map<String, MagusIniEntry> _entries = {};
}

/// magus.ini entries for a given DSN that are *of interest* enabling connection
class MagusIniEntry {
  MagusIniEntry(this._user, this._password, this._database,
      [this._hostname, this._port]);

  String get user => _user;
  String get password => _password;
  String get database => _database;
  String get hostname => _hostname;
  String get port => _port;

  // custom <class MagusIniEntry>

  toString() => '(user:$_user, pwd:$_password, db:$_database)';

  // end <class MagusIniEntry>

  String _user;
  String _password;
  String _database;
  String _hostname;
  String _port;
}

// custom <library magus_ini>
// end <library magus_ini>
