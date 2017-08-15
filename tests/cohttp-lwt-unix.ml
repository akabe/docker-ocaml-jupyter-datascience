#require "cohttp-lwt-unix" ;;

open Lwt.Infix ;;

Lwt_main.run begin
  Uri.of_string "http://nginx:80/"
  |> Cohttp_lwt_unix.Client.get >>= fun (resp, body) ->
  Cohttp_lwt_body.to_string body >|= fun body ->
  (resp, body)
end ;;
