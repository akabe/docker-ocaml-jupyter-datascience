#require "camomile" ;;

open CamomileLibraryDefault ;;

let () =
  let str = "こんにちは" in
  assert(Camomile.UTF8.get str 0 = Camomile.UChar.of_int 0x3053);
  assert(Camomile.UTF8.get str 1 = Camomile.UChar.of_int 0x3093);
  assert(Camomile.UTF8.get str 2 = Camomile.UChar.of_int 0x306B);
  assert(Camomile.UTF8.get str 3 = Camomile.UChar.of_int 0x3061);
  assert(Camomile.UTF8.get str 4 = Camomile.UChar.of_int 0x306F)
;;
