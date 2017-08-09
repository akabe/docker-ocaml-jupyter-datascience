(** WAV file reader and writer *)

(* WAVE (linear PCM) data format
   +-----+-------+---------------------------------------------+
   | pos | bytes | Meaning                                     |
   +-----+-------+---------------------------------------------+
   |   0 |     4 | RIFF header "RIFF"                          |
   |   4 |     4 | #bytes of file - 8                          |
   |   8 |     4 | WAVE header "WAVE"                          |
   |  12 |     4 | FMT chunk "fmt "                            |
   |  16 |     4 | #bytes of FMT chunk (16 in linear PCM)      |
   |  20 |     2 | Format ID (1 in linear PCM)                 |
   |  22 |     2 | #channels (monoral = 1, stereo = 2)         |
   |  24 |     4 | Sampling rate [Hz]                          |
   |  28 |     4 | Data speed [Byte/sec]                       |
   |  32 |     2 | Block size [Byte/(sample * #channels)]      |
   |  34 |     2 | #bits per one sample [bit/sample] (8 or 16) |
   |  36 |     4 | DATA chunk "data"                           |
   |  40 |     4 | #bytes of DATA chunk                        |
   |  44 |     ? | Data                                        |
   +-----+-------+---------------------------------------------+ *)

module Wav : sig

  type t = [ `Monoral of float array | `Stereo of (float * float) array ]

  val from_string : string -> int * t
  val from_channel : in_channel -> int * t
  val from_file : string -> int * t

  val to_file : ?sample_bits:int -> sample_rate:int -> string -> t -> unit

end = struct

  type t = [ `Monoral of float array | `Stereo of (float * float) array ]

  (** {2 Read} *)

  let signed max n = if n < max then n else n - max * 2
  let read_u8 s i = Char.code s.[i]
  let read_u16le s i = (read_u8 s i) lor (read_u8 s (i + 1) lsl 8)
  let read_u32le s i = (read_u16le s i) lor (read_u16le s (i + 2) lsl 16)
  let read_f8 s i = float (signed 0x80 (read_u8 s i)) /. 128.
  let read_f16le s i = float (signed 0x8000 (read_u16le s i)) /. 32768.

  let read_data_chunk ~channels ~sample_bits s i =
    let data_size = read_u32le s i in
    let k = sample_bits / 8 in (* # of bytes per sample *)
    let n = data_size / (channels * k) in
    let i0 = i + 4 in
    let read j = if k = 1 then read_f8 s (i0 + j) else read_f16le s (i0 + 2 * j) in
    match channels with
    | 1 -> `Monoral (Array.init n read)
    | 2 -> `Stereo (Array.init n (fun j -> read (2 * j), read (2 * j + 1)))
    | _ -> failwith "Unexpected #channels"

  let from_string s =
    if String.sub s 0 4 <> "RIFF" then failwith "Not RIFF format" ;
    if String.sub s 8 8 <> "WAVEfmt " then failwith "Not WAVE format" ;
    if read_u32le s 16 <> 16 || read_u16le s 20 <> 1 then failwith "Not linear PCM" ;
    let channels = read_u16le s 22 in
    let sample_rate = read_u32le s 24 in
    let sample_bits = read_u16le s 34 in
    let rec aux s i = match String.sub s i 4 with
      | "data" -> read_data_chunk ~channels ~sample_bits s (i + 4)
      | _ -> aux s (i + 8 + read_u32le s (i + 4))
      | exception _ -> failwith "Not found \"data\" chunk"
    in
    (sample_rate, aux s 36)

  let from_channel ic =
    let p = pos_in ic in
    seek_in ic (p + 4) ;
    let file_size = read_u32le (really_input_string ic 4) 0 in
    seek_in ic p ;
    from_string (really_input_string ic (file_size + 8))

  let from_file filename =
    let ic = open_in_bin filename in
    let wav = from_channel ic in
    close_in ic;
    wav

  (** {2 Write} *)

  let output_u16le oc n =
    output_byte oc (n land 0xff);
    output_byte oc ((n land 0xff00) lsr 8)

  let output_u32le oc n =
    output_u16le oc (n land 0xffff);
    output_u16le oc ((n land 0x7fff0000) lsr 16)

  let output_s8 oc n = output_byte oc (if n >= 0 then n else n + 0x100)
  let output_s16le oc n = output_u16le oc (if n >= 0 then n else n + 0x10000)
  let output_f8 oc x = output_s8 oc (int_of_float (x *. 128.))
  let output_f16le oc x = output_s16le oc (int_of_float (x *. 32768.))

  let to_file ?(sample_bits = 16) ~sample_rate filename xs =
    let channels, n = match xs with
      | `Monoral xs -> 1, Array.length xs
      | `Stereo xs -> 2, Array.length xs in
    let block_size = channels * (sample_bits / 8) in
    let data_bytes = n * block_size in
    let oc = open_out_bin filename in
    output_string oc "RIFF";
    output_u32le oc (36 + data_bytes); (* #bytes of DATA chunk *)
    output_string oc "WAVEfmt ";
    output_u32le oc 16; (* #bytes of FMT chunk *)
    output_u16le oc 1; (* format ID (linear PCM) *)
    output_u16le oc channels; (* #channels *)
    output_u32le oc sample_rate; (* sampling rate *)
    output_u32le oc (block_size * sample_rate); (* data speed *)
    output_u16le oc block_size; (* block size *)
    output_u16le oc sample_bits; (* #bits per one sample *)
    output_string oc "data"; (* DATA chunk *)
    output_u32le oc data_bytes; (* #bytes of DATA chunk *)
    let output_pt = match sample_bits with
      | 8 -> output_f8
      | 16 -> output_f16le
      | _ -> invalid_arg "Invalid sample bits (8 or 16 is supported)" in
    begin
      match xs with
      | `Monoral xs -> Array.iter (output_pt oc) xs
      | `Stereo xs -> Array.iter (fun (l, r) -> output_pt oc l ; output_pt oc r) xs
    end;
    close_out oc

end
