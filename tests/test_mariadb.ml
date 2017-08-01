(** Tests for mariadb *)

#require "mariadb" ;;

module M = Mariadb.Blocking ;;

let () =
  match M.connect ~host:"mysql" ~user:"root" ~pass:"" () with
  | Error (num, msg) -> failwith (Printf.sprintf "error #%d: %s" num msg)
  | Ok mariadb -> M.close mariadb
;;
