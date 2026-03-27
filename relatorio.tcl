# --- Configurações ---
set design_file "netlist.v"

# --- FUNÇÃO DE ANÁLISE DE CÓDIGO (O que você pediu) ---
proc relatorio1 {arquivo} {
    set f [open $arquivo r]
    set conteudo [read $f]
    close $f

    # Contagem de blocos Always
    set num_AND2 [regexp -all {AND2?} $conteudo]

    # Contagem de sinais (logic/wire/reg)
    set num_XOR2 [regexp -all {XOR2} $conteudo]

    set flipflop_D  [regexp -all  {flipflop_D f} $conteudo]

    puts "===  RELATÓRIO DE Células ==="
	puts " "
    puts " AND2 encontrados: $num_AND2 instâncias"
    puts " XOR2 encontrados: $num_XOR2 instâncias"
    puts " flipflop_D encontrados: $flipflop_D instâncias"
    puts " TOTAL: [expr {$num_AND2 + $num_XOR2 + $flipflop_D}] instâncias"
}

proc relatorio2 {arquivo} {
	set modulo1 "module somador_4bits"
	set modulo2 "module contador_4bits"
	set modulo3 "module flipflop_D"
	
	set f [open $arquivo r]
	set conteudo [read $f]
	close $f

	set modulos1 [regexp {module\s+(\w+)} $modulo1 -> nomeDoModulo1 ]

	set inicioDoRecheio1 [string first "module somador_4bits" $conteudo]
	set inicio1  [string first ";" $conteudo $inicioDoRecheio1]
	set fim1  [string first "endmodule" $conteudo $inicio1]
	set bloco1  [string range $conteudo $inicio1 $fim1]
	puts "=== Hierarquia do Design ==="
	puts " "
	puts "$nomeDoModulo1"
	if {[regexp {AND2|XOR2|always} $bloco1] > 0} {puts "|_ celulas primitivas detectada"}
	set i [regexp -all {contador_4bits} $bloco1]
	if {$i > 0} {
	    puts "|_ contador_4bits ($i instâncias)"
	}
	set j [regexp -all {flipflop_D} $bloco1]
	if {$j > 0} {
	    puts "|_ flipflop_D ($i instâncias)"
	}

	puts " "
	
	set modulos2 [regexp {module\s+(\w+)} $modulo2 -> nomeDoModulo2 ]
	set inicioDoRecheio2 [string first "module contador_4bits" $conteudo]
	set inicio2  [string first ";" $conteudo $inicioDoRecheio2]
	set fim2 [string first "endmodule" $conteudo $inicio2]
	set fim2 [expr {$fim2 + 8}]
	set bloco2 [string range $conteudo $inicio2 $fim2]
	puts "$nomeDoModulo2"
	if {[regexp {AND2|XOR2|always} $bloco2] > 0} {puts "|_ celulas primitivas detectada"}
	set k [regexp -all {contador_4bits} $bloco2]
	if {$k > 0} {
	    puts "|_ contador_4bits ($k instâncias)"
	}
	set l [regexp -all {flipflop_D} $bloco2]
	if {$l > 0} {
	    puts "|_ flipflop_D ($l instâncias)"
	}

	puts " "

	set modulos3 [regexp {module\s+(\w+)} $modulo3 -> nomeDoModulo3 ]
	set inicioDoRecheio3 [string first "flipflop_D" $conteudo]
	set inicio3  [string first ";" $conteudo $inicioDoRecheio3]	
	set fim3 [string first "endmodule" $conteudo $inicio3]
	set fim3 [expr {$fim3 + 8}]
	set bloco3 [string range $conteudo $inicio3 $fim3]
	puts "$nomeDoModulo3"
	if {[regexp {AND2|XOR2|always} $bloco3] > 0} {puts "|_ celulas primitivas detectada"}
	set m [regexp -all {contador_4bits} $bloco3]
	if {$m > 0} {
	    puts "|_ contador_4bits ($m instâncias)"
	}
	set n [regexp -all {flipflop_D} $bloco3]
	if {$n > 0} {
	    puts "|_ flipflop_D ($n instâncias)"
	}
	puts " "

}

proc relatorio3 {arquivo} {
    set f [open $arquivo r]
    set conteudo [read $f]
    close $f

    array set fanout {}
    array set fios {}
    
    set conexoes [regexp -all -inline {\.\w+\(([^)]+)\)} $conteudo]
    
    foreach {match sinal} $conexoes {
        
        set sinal [string trim $sinal]
    
        if {[regexp {^\d+'[bhd]} $sinal]} {
            continue
        }
    
        if {![info exists fios($sinal)]} {
            set fios($sinal) 1
            set fanout($sinal) 0
        }
    }
    
    set conexoes_portas [regexp -all -inline {\.(\w+)\(([^)]+)\)} $conteudo]
    
    foreach {match porta sinal} $conexoes_portas {
    
        set sinal [string trim $sinal]
    
        if {[regexp {^\d+'[bhd]} $sinal]} {
            continue
        }
    
        if {$porta eq "y" || $porta eq "Y" || $porta eq "Q"} {
            continue
        }
    
        if {[info exists fanout($sinal)]} {
            incr fanout($sinal)
        }
    }
    
    puts "====== TOP 10 FAN-OUT DOS FIOS ======"
    
    foreach fio [array names fanout] {
        puts "$fio = $fanout($fio)"
    }
    
    puts "\n====== NETS COM FANOUTS ZERO (POSSIVEIS ERROS) ======"
    
    foreach fio [array names fanout] {
        if {$fanout($fio) == 0} {
            puts "$fio"
        }
    }
}

# --- INÍCIO DO FLUXO ---
puts "\n--- INICIANDO FLUXO DE ANÁLISE ---"

# 1. Analisar o código antes de compilar
relatorio1 $design_file
puts " "
relatorio2 $design_file
puts " "
relatorio3 $design_file
