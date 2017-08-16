#require "lbfgs" ;;

open Format ;;
open Bigarray ;;

let f x = x *. x -. 2. in
let f' x = 2. *. x in
let u = Array1.create float64 fortran_layout 1 in
u.{1} <- 1. ;
let m = Lbfgs.F.min ~print:(Lbfgs.Every 1) (fun u df -> df.{1} <- f' u.{1}; f u.{1}) u in
(m, u) ;;
