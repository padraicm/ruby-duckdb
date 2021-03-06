require 'test_helper'

module DuckDBTest
  class PreparedStatementTest < Minitest::Test
    def self.create_table
      @db ||= DuckDB::Database.open # FIXME
      con = @db.connect
      con.query('CREATE TABLE a (id INTEGER, col_boolean BOOLEAN, col_smallint SMALLINT, col_integer INTEGER, col_bigint BIGINT, col_real REAL, col_double DOUBLE, col_varchar VARCHAR, col_date DATE, col_timestamp TIMESTAMP)')
      datestr = self.today.strftime('%Y-%m-%d')
      con.query("INSERT INTO a VALUES (1, True, 32767, 2147483647, 9223372036854775807, 12345.375, 12345.6789, 'str', '#{datestr}', '2019-11-09 12:34:56')")
      con
    end

    def self.con
      @con ||= create_table
    end

    def self.today
      @today ||= Date.today
    end

    def test_class_exist
      assert_instance_of(Class, DuckDB::PreparedStatement)
    end

    def test_s_new
      con = PreparedStatementTest.con
      assert_instance_of(DuckDB::PreparedStatement, DuckDB::PreparedStatement.new(con, 'SELECT * FROM a'))
      assert_raises(ArgumentError) { DuckDB::PreparedStatement.new(con) }
      assert_raises(ArgumentError) { DuckDB::PreparedStatement.new }
      assert_raises(TypeError) { DuckDB::PreparedStatement.new(con, 1) }
      assert_raises(TypeError) { DuckDB::PreparedStatement.new(1, 1) }
      assert_raises(DuckDB::Error) { DuckDB::PreparedStatement.new(con, 'SELECT * FROM') }
    end

    def test_execute
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a')
      result = stmt.execute
      assert_instance_of(DuckDB::Result, result)

      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a where id = ?')
      assert_raises(DuckDB::Error) { stmt.execute }
    end

    def test_nparams
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a')
      assert_equal(0, stmt.nparams)

      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE id = $1')
      assert_equal(1, stmt.nparams)

      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE id = ?')
      assert_equal(1, stmt.nparams)
    end

    def test_bind_boolean
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_boolean = $1')

      assert_raises(ArgumentError) { stmt.bind_boolean(0, true) }
      assert_raises(DuckDB::Error) { stmt.bind_boolean(2, true) }

      stmt.bind_boolean(1, true)
      assert_equal(1, stmt.execute.each.size)

      stmt.bind_boolean(1, false)
      assert_equal(0, stmt.execute.each.size)

      assert_raises(ArgumentError) { stmt.bind_boolean(1, 'True') }
    end

    def test_bind_int16
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_smallint = $1')

      stmt.bind_int16(1, 32767)
      assert_equal(1, stmt.execute.each.size)

      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_integer = $1')
      stmt.bind_int16(1, 32767)
      assert_equal(0, stmt.execute.each.size)


      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_bigint = $1')
      stmt.bind_int16(1, 32767)
      assert_equal(0, stmt.execute.each.size)
    end

    def test_bind_int32
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_smallint = $1')

      stmt.bind_int32(1, 32767)
      assert_equal(1, stmt.execute.each.size)

      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_integer = $1')
      stmt.bind_int32(1, 2147483647)
      assert_equal(1, stmt.execute.each.size)


      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_bigint = $1')
      stmt.bind_int32(1, 2147483647)
      assert_equal(0, stmt.execute.each.size)
    end

    def test_bind_int64
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_smallint = $1')

      stmt.bind_int64(1, 32767)
      assert_equal(1, stmt.execute.each.size)

      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_integer = $1')
      stmt.bind_int64(1, 2147483647)
      assert_equal(1, stmt.execute.each.size)


      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_bigint = $1')
      stmt.bind_int64(1, 9223372036854775807)
      assert_equal(1, stmt.execute.each.size)
    end

    def test_bind_float
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_real = $1')

      assert_raises(ArgumentError) { stmt.bind_float(0, 12345.375) }
      assert_raises(DuckDB::Error) { stmt.bind_float(2, 12345.375) }

      stmt.bind_float(1, 12345.375)
      assert_equal(1, stmt.execute.each.size)

      assert_raises(TypeError) { stmt.bind_float(1, 'invalid_float_val') }
    end

    def test_bind_double
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_double = $1')

      assert_raises(ArgumentError) { stmt.bind_double(0, 12345.6789) }
      assert_raises(DuckDB::Error) { stmt.bind_double(2, 12345.6789) }

      stmt.bind_double(1, 12345.6789)
      assert_equal(1, stmt.execute.each.size)

      assert_raises(TypeError) { stmt.bind_double(1, 'invalid_double_val') }
    end

    def test_bind_varchar
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_varchar = $1')

      assert_raises(ArgumentError) { stmt.bind_varchar(0, 'str') }
      assert_raises(DuckDB::Error) { stmt.bind_varchar(2, 'str') }
      stmt.bind_varchar(1, 'str')
      result = stmt.execute
      assert_equal(1, result.each.first[0])

      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_varchar = ?')

      assert_raises(ArgumentError) { stmt.bind_varchar(0, 'str') }
      assert_raises(DuckDB::Error) { stmt.bind_varchar(2, 'str') }

      stmt.bind_varchar(1, 'str')
      result = stmt.execute
      assert_equal(1, result.each.first[0])

      # SQL injection
      param = "' or 1 = 1 --"
      result = con.query("SELECT * FROM a WHERE col_varchar = '#{param}'")
      assert_equal(1, result.each.size)

      # block SQL injection using bind_varchar
      stmt.bind_varchar(1, param)
      result = stmt.execute
      assert_equal(0, result.each.size)
    end

    def test_bind_varchar_date
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_date = $1')

      stmt.bind_varchar(1, PreparedStatementTest.today.strftime('%Y-%m-%d'))
      result = stmt.execute
      assert_equal(1, result.each.first[0])

      stmt.bind_varchar(1, 'invalid_date_string')
      assert_raises(DuckDB::Error) { stmt.execute }
    end

    def test_bind_varchar_timestamp
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_timestamp = $1')

      stmt.bind_varchar(1, '2019/11/09 12:34:56')
      result = stmt.execute
      assert_equal(1, result.each.first[0])

      stmt.bind_varchar(1, 'invalid_timestamp_string')
      assert_raises(DuckDB::Error) { stmt.execute }
    end

    def test_bind_null
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'INSERT INTO a(id) VALUES ($1)')
      skip 'bind_null is not defined in DuckDB::PreparedStatement (DuckDB version <= 0.1.1?)' unless stmt.respond_to?(:bind_null)
      stmt.bind_null(1)
      assert_instance_of(DuckDB::Result, stmt.execute)
      r = con.query('SELECT * FROM a WHERE id IS NULL')
      assert_equal(1, r.each.size)
    ensure
      con.query('DELETE FROM a WHERE id IS NULL')
    end

    def test_bind_with_boolean
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_boolean = $1')

      stmt.bind(1, true)
      assert_equal(1, stmt.execute.each.size)

      stmt.bind(1, false)
      assert_equal(0, stmt.execute.each.size)
    end

    def test_bind_with_int16
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_smallint = $1')

      stmt.bind(1, 1)
      assert_equal(0, stmt.execute.each.size)

      stmt.bind(1, 32767)
      assert_equal(1, stmt.execute.each.size)
    end

    def test_bind_with_int32
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_integer = $1')

      stmt.bind(1, 1)
      assert_equal(0, stmt.execute.each.size)

      stmt.bind(1, 2147483647)
      assert_equal(1, stmt.execute.each.size)
    end

    def test_bind_with_int64
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_bigint = $1')

      stmt.bind(1, 1)
      assert_equal(0, stmt.execute.each.size)

      stmt.bind(1, 9223372036854775807)
      assert_equal(1, stmt.execute.each.size)
    end

    def test_bind_with_float
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_real = $1')

      stmt.bind(1, 12345.375)
      assert_equal(1, stmt.execute.each.size)

      stmt.bind(1, 12345.376)
      assert_equal(0, stmt.execute.each.size)
    end

    def test_bind_with_double
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_double = $1')

      stmt.bind(1, 12345.6789)
      assert_equal(1, stmt.execute.each.size)

      stmt.bind(1, 12345.6788)
      assert_equal(0, stmt.execute.each.size)
    end

    def test_bind_with_varchar
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_varchar = $1')

      stmt.bind(1, 'str')
      assert_equal(1, stmt.execute.each.first[0])

      # block SQL injection using bind
      stmt.bind(1, "' or 1 = 1 --")
      assert_equal(0, stmt.execute.each.size)
    end

    def test_bind_with_time
      now = Time.now
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_timestamp = $1')

      stmt.bind(1, Time.mktime(2019, 11, 9, 12, 34, 56, 0))
      assert_equal(1, stmt.execute.each.size)

      stmt.bind(1, Time.mktime(2019, 11, 9, 12, 34, 56, 123456))
      assert_equal(0, stmt.execute.each.size)

      con.query("UPDATE a SET col_timestamp = '#{now.strftime('%Y/%m/%d %H:%M:%S.%N')}'")
      stmt.bind(1, now)
      assert_equal(1, stmt.execute.each.size)
      stmt.bind(1, now.strftime('%Y/%m/%d %H:%M:%S') + ".#{now.nsec + 1000000}")
      assert_equal(0, stmt.execute.each.size)
    ensure
      con.query("UPDATE a SET col_timestamp = '2019/11/09 12:34:56'")
    end

    def test_bind_with_date
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'SELECT * FROM a WHERE col_date = $1')
      date = PreparedStatementTest.today

      stmt.bind(1, date)
      assert_equal(1, stmt.execute.each.size)

      stmt.bind(1, date + 1)
      assert_equal(0, stmt.execute.each.size)
    end

    def test_bind_with_null
      con = PreparedStatementTest.con
      stmt = DuckDB::PreparedStatement.new(con, 'INSERT INTO a(id) VALUES ($1)')

      skip 'bind_null is not defined in DuckDB::PreparedStatement (DuckDB version <= 0.1.1?)' unless stmt.respond_to?(:bind_null)

      stmt.bind(1, nil)
      stmt.execute
      r = con.query('SELECT * FROM a WHERE id IS NULL')
      assert_equal(1, r.each.size)
    ensure
      con.query('DELETE FROM a WHERE id IS NULL')
    end
  end
end
