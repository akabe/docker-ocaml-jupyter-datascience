(** Tests for libsvm *)

#require "libsvm";;

open Lacaml.D ;;
open Libsvm ;;

let () =
  let x = Mat.of_array
    [|
      [| 0.; 0. |];
      [| 0.; 1. |];
      [| 1.; 0. |];
      [| 1.; 1. |];
    |]
  in
  let targets = Vec.of_array [| 0.; 1.; 1.; 0. |] in
  let problem = Svm.Problem.create ~x ~y:targets in
  let model = Svm.train ~kernel:`RBF problem in
  let y = Svm.predict model ~x in
  for i = 1 to 4 do
    Printf.printf "(%1.0f, %1.0f) -> %1.0f\n" x.{i,1} x.{i,2} y.{i}
  done
;;
