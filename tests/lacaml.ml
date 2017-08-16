#require "lacaml" ;;

open Lacaml.D ;;

let a = Mat.random 10 20 in
let b = Mat.random 20 30 in
gemm a b ;;
