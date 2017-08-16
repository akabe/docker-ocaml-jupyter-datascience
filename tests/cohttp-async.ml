#thread ;;
#require "cohttp-async" ;;

open Async ;;

Thread_safe.block_on_async_exn begin fun () ->
  Uri.of_string "http://nginx:80/"
  |> Cohttp_async.Client.get >>= fun (resp, body) ->
  Cohttp_async.Body.to_string body >>| fun body ->
  (resp, body)
end ;;
