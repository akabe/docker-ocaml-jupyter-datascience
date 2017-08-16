#require "libsvm" ;;

open Lacaml.D ;;
open Libsvm ;;

let x = Mat.of_array [|[|0.; 0.|]; [|0.; 1.|]; [|1.; 0.|]; [|1.; 1.|]|] in
let y = Vec.of_array [| 0.; 1.; 1.; 0. |] in
let problem = Svm.Problem.create ~x ~y in
let model = Svm.train ~kernel:`RBF problem in
Svm.predict model ~x ;;
