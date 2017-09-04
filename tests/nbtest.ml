#use "topfind" ;;
#require "ppx_deriving_yojson" ;;

open Format

type cell =
  {
    cell_type : string;
    execution_count : int;
    source : string list;
    outputs : string list;
    metadata : Yojson.Safe.json;
  }
[@@deriving yojson]

type kernelspec =
  {
    display_name : string;
    language : string;
    name : string;
  }
[@@deriving yojson]

type language_info =
  {
    codemirror_mode : string;
    file_extension : string;
    mimetype : string;
    name : string;
    nbconverter_exporter : string option;
    pygments_lexer : string;
    version : string;
  }
[@@deriving yojson]

type metadata =
  {
    kernelspec : kernelspec;
    language_info : language_info;
  }
[@@deriving yojson]

type ipynb =
  {
    nbformat : int;
    nbformat_minor : int;
    cells : cell list;
    metadata : metadata;
  }
[@@deriving yojson]

let cell_of_ml_file fname =
  let ic = open_in fname in
  let rec aux acc = match input_line ic with
    | exception End_of_file -> close_in ic ; List.rev acc
    | line -> aux ((line ^ "\n") :: acc)
  in
  {
    cell_type = "code";
    execution_count = 1;
    source = aux [];
    outputs = [];
    metadata = `Assoc [];
  }

let ipynb_of_ml_file fname =
  {
    cells = [cell_of_ml_file fname];
    nbformat = 4;
    nbformat_minor = 2;
    metadata =
      {
        kernelspec =
          {
            display_name = "OCaml";
            language = "OCaml";
            name = "ocaml-jupyter";
          };
        language_info =
          {
            codemirror_mode = "text/x-ocaml";
            file_extension = ".ml";
            mimetype = "text/x-ocaml";
            name = "OCaml";
            nbconverter_exporter = None;
            pygments_lexer = "OCaml";
            version = Sys.ocaml_version;
          };
      };
  }

let ipynb_file_of_ml_file in_fname =
  let out_fname = in_fname ^ ".ipynb" in
  ipynb_of_ml_file in_fname
  |> [%to_yojson: ipynb]
  |> Yojson.Safe.to_file out_fname ;
  out_fname

let main in_fname =
  let out_fname = ipynb_file_of_ml_file in_fname in
  let cmd = sprintf "jupyter nbconvert --to notebook --execute %s" out_fname in
  exit @@ Sys.command cmd

let () =
  if Array.length Sys.argv = 2
  then main Sys.argv.(1)
  else Format.eprintf "Usage: ocaml tests/nbtest.ml ML_FILE@."
