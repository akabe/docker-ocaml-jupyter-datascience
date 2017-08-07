(** Tests for cohttp *)

#require "cohttp.lwt" ;;

open Format ;;

let main () =
  let open Lwt.Infix in
  let open Cohttp in
  let open Cohttp_lwt_unix in
  Client.get (Uri.of_string "https://example.com/") >>= fun (resp, body) ->
  Cohttp_lwt_body.to_string body >|= fun body ->
  assert(Response.status resp = `OK) ;
  printf "%s@." body
;;

let () = Lwt_main.run (main ()) ;;
