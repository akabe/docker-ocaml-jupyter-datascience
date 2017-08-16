#require "gsl" ;;

open Gsl ;;

let rng = Rng.make (Rng.default ()) in
Rng.get rng
