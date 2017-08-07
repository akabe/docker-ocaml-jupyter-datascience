(** Tests for GSL *)

#require "gsl" ;;

open Gsl ;;

let () =
  Error.init () ;
  Rng.env_setup ()
;;

let rng = Rng.make (Rng.default ()) ;;

let () =
  Printf.printf "# generator type: %s\n" (Rng.name rng) ;
  Printf.printf "# seed = %nu\n"  (Rng.default_seed ()) ;
  Printf.printf "# min value   = %nu\n" (Rng.min rng) ;
  Printf.printf "# max value   = %nu\n" (Rng.max rng) ;
  Printf.printf "# first value = %nu\n" (Rng.get rng)
;;
