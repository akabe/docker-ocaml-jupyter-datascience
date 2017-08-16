#require "mariadb" ;;

module M = Mariadb.Blocking ;;

let () =
  match M.connect ~host:"mysql" ~user:"root" ~pass:"" () with
  | Ok db -> M.close db
  | Error (n, s) -> failwith (Printf.sprintf "%s (%d)" s n) ;;
