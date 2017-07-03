library magus.schema_reading;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:magus/schema.dart';
import 'package:magus/odbc_ini.dart';
import 'package:quiver/iterables.dart';
import 'package:postgres/postgres.dart';

// end <additional imports>

final Logger _logger = new Logger('schema_reading');

// custom <library schema_reading>

create_stuff(connection) async =>
    await connection.execute(
        '''
DROP TABLE IF EXISTS plus_cms.posts;
DROP TABLE IF EXISTS plus_cms.article;

CREATE TABLE plus_cms.posts (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL
);

INSERT INTO plus_cms.posts (title, body) VALUES
  ('First Post', 'This is my first post'),
  ('Second Post', 'This is my second post');


CREATE TABLE plus_cms.article (
    article_id bigserial primary key,
    article_name varchar(20) NOT NULL,
    article_desc text NOT NULL,
    date_added timestamp default NULL
);



DROP TABLE IF EXISTS plus_cms.code_locations CASCADE;
DROP TABLE IF EXISTS plus_cms.code_packages CASCADE;
DROP TABLE IF EXISTS plus_cms.rusage_delta CASCADE;

CREATE TABLE plus_cms.code_packages (
  id SERIAL NOT NULL,
  name varchar(64) NOT NULL,
  descr varchar(256) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE(name)
); 

CREATE TABLE plus_cms.code_locations (
  id SERIAL NOT NULL,
  code_packages_id int NOT NULL,
  label varchar(256) NOT NULL,
  file_name varchar(256) NOT NULL,
  line_number int NOT NULL,
  git_commit varchar(40) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE(code_packages_id,label,file_name,line_number),
  FOREIGN KEY (code_packages_id) REFERENCES plus_cms.code_packages (id)
);

CREATE TABLE plus_cms.rusage_delta (
  id SERIAL NOT NULL,
  code_locations_id int NOT NULL,
  created timestamp NOT NULL,
  start_processor int NOT NULL,
  end_processor int NOT NULL,
  cpu_mhz double precision NOT NULL,
  debug int NOT NULL,
  user_time_sec bigint NOT NULL,
  user_time_usec bigint NOT NULL,
  system_time_sec bigint NOT NULL,
  system_time_usec bigint NOT NULL,
  ru_maxrss bigint NOT NULL,
  ru_ixrss bigint NOT NULL,
  ru_idrss bigint NOT NULL,
  ru_isrss bigint NOT NULL,
  ru_minflt bigint NOT NULL,
  ru_majflt bigint NOT NULL,
  ru_nswap bigint NOT NULL,
  ru_inblock bigint NOT NULL,
  ru_oublock bigint NOT NULL,
  ru_msgsnd bigint NOT NULL,
  ru_msgrcv bigint NOT NULL,
  ru_nsignals bigint NOT NULL,
  ru_nvcsw bigint NOT NULL,
  ru_nivcsw bigint NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (code_locations_id) REFERENCES plus_cms.code_locations (id)
)

''');

// end <library schema_reading>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('read_schema', () async {
    var connection = new PostgreSQLConnection("localhost", 5432, "plusauri", username: "postgres", password: "fkb92");
    await connection.open();

    //await create_stuff(connection);

    //print(await connection.query('select * from plus_cms.posts'));
    
    // var results = await connection.query("SELECT * FROM plusauri.asset");

    // print(results);

    for(final row in await connection.query("select table_catalog, table_name, table_type from information_schema.tables where table_schema = 'plus_cms'")) {
      var table = row[1];
      print(table);
      for(final row in await connection.query("select column_name, data_type, character_maximum_length from information_schema.columns where table_name = '$table' and table_schema = 'plus_cms'")) {
        print(row);
      }
    }
    
    // for(final row in await connection.query("select column_name, data_type from information_schema.columns")) {
    //   // print(row);
    // }

    connection.close();
  });

// end <main>
}
