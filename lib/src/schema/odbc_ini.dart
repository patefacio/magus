part of magus.schema;

class OdbcIni {

  Map<String, OdbcIniEntry> get entries => _entries;

  // custom <class OdbcIni>
  // end <class OdbcIni>
  Map<String, OdbcIniEntry> _entries = {};
}

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
// custom <part odbc_ini>
// end <part odbc_ini>
