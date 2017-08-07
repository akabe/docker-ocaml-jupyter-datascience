(** Tests for Ocephes *)

#require "ocephes" ;;

let () =
  Format.printf "gamma = %g@." (Ocephes.gamma 4.0)
;;
