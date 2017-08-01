(** Tests for Lacaml *)

#require "lacaml" ;;

open Lacaml.D ;;

let () =
  let a = Mat.random 10 20 in
  let b = Mat.random 20 30 in
  let c = gemm a b in
  assert(Mat.dim1 c = 10);
  assert(Mat.dim2 c = 30);
  Format.printf "%a@." Lacaml.Io.pp_fmat c
;;
