import sys
import argparse
import getopt
sys.path.insert(0, '~/dev/open_source/sqlalchemy/lib')
from sqlalchemy import *
from sqlalchemy.dialects.mysql import \
        BIGINT, BINARY, BIT, BLOB, BOOLEAN, CHAR, DATE, \
        DATETIME, DECIMAL, DECIMAL, DOUBLE, ENUM, FLOAT, INTEGER, \
        LONGBLOB, LONGTEXT, MEDIUMBLOB, MEDIUMINT, MEDIUMTEXT, NCHAR, \
        NUMERIC, NVARCHAR, REAL, SET, SMALLINT, TEXT, TIME, TIMESTAMP, \
        TINYBLOB, TINYINT, TINYTEXT, VARBINARY, VARCHAR, YEAR

def main():
    try:
        parser = argparse.ArgumentParser(description='Populate a schema with lots of types.')
        parser.add_argument('-u', '--user', type=str, help='user')
        parser.add_argument('-p', '--password', type=str, help='db password')
        args = parser.parse_args()

    except Exception as err:
        print(err)
        sys.exit()

    engine = create_engine('mysql://%s:%s@localhost'%(args.user, args.password),
                           echo="debug")

    engine.execute("DROP DATABASE IF EXISTS magus")    
    engine.execute("CREATE DATABASE magus")
    engine.execute("USE magus")
    engine.execute("GRANT ALL ON magus.* TO 'magus'@'localhost' IDENTIFIED BY 'maguspwd'");
    insp = inspect(engine)
    print insp

    metadata = MetaData()

    user = Table('user', metadata,
                 Column('user_id', Integer, primary_key = True),
                 Column('boolean', Boolean(), nullable = False),

                 Column('char', CHAR(), nullable = False),
                 Column('char_16', CHAR(16), nullable = False),
                 Column('varchar_16', VARCHAR(16), nullable = False),
                 Column('text', Text(), nullable = False),
                 Column('text_tiny_255', TEXT(255), nullable = False),
                 Column('text_256', TEXT(256), nullable = False),
                 Column('tiny_text', TINYTEXT(), nullable = False),
                 Column('medium_text', MEDIUMTEXT(), nullable = False),
                 Column('long_text', LONGTEXT(), nullable = False),

                 Column('smallint', SmallInteger(), nullable = False),
                 Column('int', Integer(), nullable = False),
                 Column('mediumint_8', MEDIUMINT(display_width=8), nullable = False),
                 Column('mediumint_8_u', MEDIUMINT(display_width=8, unsigned=True), nullable = False),
                 Column('bigint', BigInteger(), nullable = False),
                 Column('bigint_8', BIGINT(display_width=8), nullable = False),

                 Column('decimal', DECIMAL(), nullable = False),
                 Column('decimal_10', DECIMAL(10), nullable = False),
                 Column('decimal_10_2', DECIMAL(10,2), nullable = False),

                 Column('numeric', NUMERIC(), nullable = False),
                 Column('numeric_10_2', NUMERIC(10,2), nullable = False),

                 Column('real', REAL(), nullable = False),
                 Column('float', Float(), nullable = False),
                 Column('float_16', FLOAT(precision=16), nullable = False),
                 Column('float_5_2', FLOAT(precision=5, scale=2), nullable = False),
                 Column('float_5_2_u', FLOAT(precision=5, scale=2, unsigned=True), nullable = False),
                 Column('double', DOUBLE(), nullable = False),
                 Column('double_8_2', DOUBLE(precision=8, scale=2), nullable = False),
                 Column('double_1_1_u', DOUBLE(precision=1, scale=1, unsigned = True), nullable = False),

                 Column('tinyblob', TINYBLOB()),
                 Column('mediumblob', MEDIUMBLOB()),
                 Column('longblob', LONGBLOB()),

                 Column('date', Date(), nullable = False),
                 Column('time', Time(), nullable = False),
                 Column('date_time', DateTime(), nullable = False),
                 Column('timestamp', TIMESTAMP(), nullable = False),
                 Column('email_address', String(60), key='email'),
                 Column('password', String(20), nullable = False))

    user_prefs = Table('user_prefs', metadata,
                       Column('pref_id', Integer, primary_key=True),
                       Column('user_id', Integer, ForeignKey("user.user_id"), nullable=False),
                       Column('pref_name', String(40), nullable=False),
                       Column('pref_value', String(100)))

    multi_key = Table('multi_key', metadata,
                       Column('id_1', Integer, primary_key=True),
                       Column('id_2', Integer, primary_key=True))

    multi_fkey = Table('multi_fkey', metadata,
                       Column('id', Integer, primary_key=True),
                       Column('multi_key_id_1', Integer),
                       Column('multi_key_id_2', Integer),
                       ForeignKeyConstraint(['multi_key_id_1', 'multi_key_id_2'], ['multi_key.id_1', 'multi_key.id_2']))

    for t in [ user_prefs, multi_fkey, multi_key, user ]:
        t.drop(engine, checkfirst=True)

    metadata.create_all(engine)

    print user

if __name__ == "__main__":
    main()
