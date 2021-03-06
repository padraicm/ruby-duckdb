# ChangeLog

- add test CI on MacOS.

## 0.0.10

- bump DuckDB to v0.2.2
- fix to build failure on MacOS.

## 0.0.9

- bump DuckDB to v0.2.1
- bump Ruby to v2.7.2
- bunmp DuckDB to v0.2.0

## 0.0.8.1

- update Gemfile.lock
- unsupport Ruby 2.4

## 0.0.8

- remove test with Ruby 2.4.10
- bump DuckDB to v0.1.8
- bump DuckDB to v0.1.8
- bump DuckDB to v0.1.7
  - current ruby-duckdb supports DuckDB version 0.1.5 and 0.1.6
- support Ruby 2.7.1
- bump DuckDB to v0.1.6
  - current ruby-duckdb supports DuckDB version 0.1.5 and 0.1.6
- DuckDB::Connection#connect accepts block
- add DuckDB::Connection#connect
- DuckDB::Database#connect accepts block
- DuckDB::Database.open accepts block
- update duckdb.gemspec, required ruby version >= 2.4.0

## 0.0.7

- bump DuckDB to v0.1.5
  - DuckDB version must be 0.1.5 or later.
- add DuckDB::Connection#connect, alias method open
- add DuckDB::Connection#disconnect, alias method close
- add DuckDB::Database#close

## 0.0.6

- add alias `execute` of `DuckDB::Connection#query`
- support `duckdb version 0.1.3`
- add `DuckDB:PreparedStatement`
- create CI (GitHub Actions / Travis-CI)
- create database only once in result_test.rb

## 0.0.5

- add `DuckDB::Error`
- `DuckDB::Result#each` convert DuckDB number value to Ruby's number
- `DuckDB::Result#each` convert DuckDB NULL value to nil
- `DuckDB::Result#each` returns Enumerator object when block is not given
- `DuckDB::Result` include `Enumerable`
- add test for `DuckDB::Result`
- add test for `DuckDB::Connection`
- fix description in duckdb.gemspec

## 0.0.4

- add test for `DuckDB::Database`
- rename module name to `DuckDB` from `Duckdb`

## 0.0.3

- rename native extension name to duckdb_native

## 0.0.2

- fix gem install error

## 0.0.1

- first release
