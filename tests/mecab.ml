#require "mecab" ;;

List.iter
  (fun dic ->
     let mecab = Mecab.Tagger.create [|"-d"; dic|] in
     Mecab.Tagger.sparse_tostr mecab "すもももももももものうち"
     |> print_endline)
  [
    "/usr/lib/mecab/dic/mecab-ipadic";
    "/usr/lib/mecab/dic/mecab-ipadic-neologd";
  ]
;;
