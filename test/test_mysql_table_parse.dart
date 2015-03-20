library magus.test.test_mysql_table_parse;

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:sqljocky/sqljocky.dart';
import 'package:magus/schema.dart';
import 'package:magus/mysql.dart';
import 'package:quiver/iterables.dart';

// end <additional imports>

final _logger = new Logger('test_mysql_table_parse');

// custom <library test_mysql_table_parse>

final sourcetables = '''
user_prefs
CREATE TABLE `user_prefs` (
  `pref_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `pref_name` varchar(40) NOT NULL,
  `pref_value` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`pref_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_prefs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1
user
CREATE TABLE `user` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `boolean` tinyint(1) NOT NULL,
  `char` char(1) NOT NULL,
  `char_16` char(16) NOT NULL,
  `varchar_16` varchar(16) NOT NULL,
  `text` text NOT NULL,
  `text_tiny_255` tinytext NOT NULL,
  `text_256` text NOT NULL,
  `tiny_text` tinytext NOT NULL,
  `medium_text` mediumtext NOT NULL,
  `long_text` longtext NOT NULL,
  `smallint` smallint(6) NOT NULL,
  `int` int(11) NOT NULL,
  `mediumint_8` mediumint(8) NOT NULL,
  `mediumint_8_u` mediumint(8) unsigned NOT NULL,
  `bigint` bigint(20) NOT NULL,
  `bigint_8` bigint(8) NOT NULL,
  `decimal` decimal(10,0) NOT NULL,
  `decimal_10` decimal(10,0) NOT NULL,
  `decimal_10_2` decimal(10,2) NOT NULL,
  `numeric` decimal(10,0) NOT NULL,
  `numeric_10_2` decimal(10,2) NOT NULL,
  `real` double NOT NULL,
  `float` float NOT NULL,
  `float_16` float NOT NULL,
  `float_5_2` float(5,2) NOT NULL,
  `float_5_2_u` float(5,2) unsigned NOT NULL,
  `double` double NOT NULL,
  `double_8_2` double(8,2) NOT NULL,
  `double_1_1_u` double(1,1) unsigned NOT NULL,
  `tinyblob` tinyblob,
  `mediumblob` mediumblob,
  `longblob` longblob,
  `date` date NOT NULL,
  `time` time NOT NULL,
  `date_time` datetime NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `email_address` varchar(60) DEFAULT NULL,
  `password` varchar(20) NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1
multi_fkey
CREATE TABLE `multi_fkey` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `multi_key_id_1` int(11) DEFAULT NULL,
  `multi_key_id_2` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `multi_key_id_1` (`multi_key_id_1`,`multi_key_id_2`),
  CONSTRAINT `multi_fkey_ibfk_1` FOREIGN KEY (`multi_key_id_1`, `multi_key_id_2`) REFERENCES `multi_key` (`id_1`, `id_2`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1
''';

// end <library test_mysql_table_parse>
main([List<String> args]) {
  Logger.root.onRecord.listen((LogRecord r) =>
      print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  group('table creates', () {
    final parser = new MysqlSchemaParser();

    test('multi_key table', () {
      final create = '''
CREATE TABLE `multi_key` (
  `id_1` int(11) NOT NULL AUTO_INCREMENT,
  `id_2` int(11) NOT NULL,
  PRIMARY KEY (`id_1`,`id_2`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1''';

      final table = parser.parseTableCreate(create);
      final col1 = table.getColumn('id_1');
      expect(col1.name, 'id_1');
      expect(col1.nullable, false);
      expect(col1.autoIncrement, true);
      expect(col1.type is SqlInt, true);
      expect(col1.type.displayLength, 11);

      final col2 = table.getColumn('id_2');
      expect(col2.name, 'id_2');
      expect(col2.nullable, false);
      expect(col2.autoIncrement, false);
      expect(col2.type.displayLength, 11);

      expect(table.primaryKey.length, 2);
      final pkey_1 = table.primaryKey.first;
      final pkey_2 = table.primaryKey.last;
      expect(pkey_1, col1);
      expect(pkey_2, col2);
    });

    test('user_prefs fkey constraint, sized varchar', () {
      final create = '''
CREATE TABLE `user_prefs` (
  `pref_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `pref_name` varchar(40) NOT NULL,
  `pref_value` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`pref_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_prefs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1''';
      final table = parser.parseTableCreate(create);
      final prefName = table.getColumn('pref_name');
      final prefValue = table.getColumn('pref_value');
      final prefValueType = prefValue.type;
      expect(prefValueType is SqlString, true);
      expect(prefValueType.length, 100);
      expect(prefValue.nullable, true);
      //print(table);

      expect(table.foreignKeySpecs.length, 1);
      final fkeySpec = table.foreignKeySpecs.first;
      expect(fkeySpec.columns, ['user_id']);
      expect(fkeySpec.name, 'user_prefs_ibfk_1');
      expect(fkeySpec.refColumns, ['user_id']);
      expect(fkeySpec.refTable, 'user');
    });


  });


// end <main>

}
