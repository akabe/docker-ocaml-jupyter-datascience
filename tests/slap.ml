#require "slap,slap.ppx,slap.top" ;;

open Slap.D ;;

let a = Mat.random Slap.Size.five Slap.Size.three in
let b = Mat.random Slap.Size.three Slap.Size.four in
gemm ~transa:Slap.Common.normal ~transb:Slap.Common.normal a b ;;

[%vec [1.0; 2.0; 3.0]] ;;
