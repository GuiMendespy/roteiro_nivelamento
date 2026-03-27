
proc contar_instancia { tipo linha } {
  set regex "${tipo}\\s+\[a-zA-Z_\]\\w*\\s*\\(.*\\);?"
  set match [regexp -all $regex $linha];

  return $match;
}

proc get_modules {} {
  set f [open "netlist.v" r];
  set netlist [read $f];
  close $f;

  set modules [regexp -inline -all {(?s)module.*?endmodule} $netlist];

  foreach {module} [get_modules] {
    puts $module;
    puts "==========================="
  }
}

proc get_nets {} {
  set f [open "netlist.v" r];
  set netlist [read $f]
  close $f;
  set VAR_NAME "(?s)\[a-zA-Z_\]\\w*\"

  puts [regexp -inline -all ${VAR_NAME} $netlist];
  puts "=========="
  foreach {net} [regexp -inline -all {(?s)\.[a-zA-Z_]\w*\([\[\]\w]+\)} $netlist] {
    # set net [regexp $net {$VAR_NAME}]
    puts $net;
    set vars [regexp -inline -all ${VAR_NAME} $net]
    puts $vars
  }
}

proc tarefa_1 {} {
  set netlist [open "netlist.v" r];
  set n_and2 0;
  set n_xor2 0;
  set n_flipflop 0;

  while { [gets $netlist linha ] >= 0 } {
    set n_and2 [expr {$n_and2 + [contar_instancia "AND2" $linha]}];
    set n_xor2 [expr {$n_xor2 + [contar_instancia "XOR2" $linha]}];
    set n_flipflop [expr {$n_flipflop + [contar_instancia "flipflop_D" $linha]}];
  }

  close $netlist;

  set total [expr $n_and2 + $n_xor2 + $n_flipflop];

  puts "=== RELATÓRIO DE CÉLULAS ===";
  puts "AND2: $n_and2 instâncias";
  puts "XOR2: $n_xor2 instâncias";
  puts "flipflop_D: $n_flipflop instâncias";
  puts "TOTAL: $total instâncias";
}

proc tarefa_2 {} {
  set netlist [open "netlist.v"];

}
proc tarefa_3 {} {
  set f [open "netlist.v" r];
}

get_nets
