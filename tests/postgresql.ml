#thread ;; (* for Mutex *)
#load "bigarray.cma" ;; (* required by v4.1.0 *)
#require "postgresql" ;;

let c =
  new Postgresql.connection
    ~host:"postgres"
    ~port:"5432"
    ~user:"postgres"
    ~password:"" ()
in
c#finish ;;
