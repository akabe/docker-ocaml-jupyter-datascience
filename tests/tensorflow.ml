#thread ;;
#require "tensorflow" ;;

open Tensorflow ;;

let forty_two = Ops.(f 40. + f 2.) in
let y = Session.run (Session.Output.scalar_float forty_two) in
assert(abs_float (y -. 42.) < 1e-9)
