(** Tests for L-BFGS *)

#require "lbfgs" ;;

open Format ;;
open Bigarray ;;

let () =
  let f x = x *. x -. 2. in
  let f' x = 2. *. x in
  let u = Array1.create float64 fortran_layout 1 in
  u.{1} <- 1. ;
  try
    let m = Lbfgs.F.min (fun u df -> df.{1} <- f' u.{1}; f u.{1}) u
      ~print:(Lbfgs.Every 1) in
    printf "min = %g at x = %g\n" m u.{1}
  with Lbfgs.Abnormal(fx, err) ->
    printf "ERROR: %S, x = %g, f = %g\n" err u.{1} fx
;;
