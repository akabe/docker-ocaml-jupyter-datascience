#require "mysql" ;;

let dbd = Mysql.quick_connect ~host:"mysql" ~user:"root" ~password:"" () in
Mysql.disconnect dbd ;;
