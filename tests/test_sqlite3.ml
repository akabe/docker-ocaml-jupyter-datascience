(** Tests for sqlite3 *)

#require "sqlite3" ;;

let () =
  let c = Sqlite3.db_open "./sqlite3_test.sqlite" in
  assert (Sqlite3.db_close c)
;;
