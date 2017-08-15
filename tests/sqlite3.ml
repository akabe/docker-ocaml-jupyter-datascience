#require "sqlite3" ;;

let c = Sqlite3.db_open "/tmp/sqlite3_test.sqlite" in
assert(Sqlite3.db_close c)
