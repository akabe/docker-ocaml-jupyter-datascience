#require "plplot" ;;

Plplot.Quick_plot.points
  ~filename:"plplot.png"
  ~device:(`png `cairo)
  [
    [|1.; 2.; 3.; 4.|],
    [|4.; 3.; 2.; 1.|]
  ]
;;
