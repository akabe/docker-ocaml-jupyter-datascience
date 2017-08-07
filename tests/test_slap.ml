(** Tests for SLAP *)

#require "slap" ;;

open Slap.D ;;

let () =
  let a = Mat.random Slap.Size.five Slap.Size.three in
  let b = Mat.random Slap.Size.three Slap.Size.four in
  let c = gemm ~transa:Slap.Common.normal ~transb:Slap.Common.normal a b in
  assert(Mat.dim1 c = Slap.Size.five);
  assert(Mat.dim2 c = Slap.Size.four);
  Format.printf "%a@." Slap.Io.pp_fmat c
;;
