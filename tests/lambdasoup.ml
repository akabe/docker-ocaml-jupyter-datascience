#require "lambdasoup" ;;

open Soup ;;

let str = (parse "<p class='Hello'>World!</p>") $ ".Hello" |> R.leaf_text in
assert(str = "World!")
;;
