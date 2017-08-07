(** Tests for cohttp *)

#thread ;;
#require "cohttp.async" ;;

open Async.Std ;;
open Cohttp ;;
open Cohttp_async ;;

let main () =
  Client.get (Uri.of_string "http://example.com/") >>= fun (resp, body) ->
  Body.to_string body >>| fun body ->
  assert(Response.status resp = `OK) ;
  printf "%s@." body
;;

let () = Async.Std.Thread_safe.block_on_async_exn main ;;
