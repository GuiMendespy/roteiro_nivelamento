#!/bin/bash

# 1. Cria os arquivos de exemplo
criar_arq(){
    touch alu.v regfile.v alu_tb.v defs.vh script.tcl top.v README.md mux.v sim.do
    echo "Arquivos criados com sucesso."
}

# 2. Função para mover arquivos (O segredo está no 'shift')
mover_arq(){
    local DIR=$1
    shift # Remove o primeiro argumento (o diretório) da lista
    
    # Se o diretório não existir, cria ele
    [ ! -d "$DIR" ] && mkdir -p "$DIR"
    
    # Move todos os arquivos restantes para o diretório
    mv "$@" "$DIR" 2>/dev/null
    echo "Arquivo  $@ -> $DIR/"
}

# --- Execução ---

criar_arq

# Organizando por extensões e nomes (conforme sua foto)

# Testbench (Arquivos que terminam com _tb.v)
if ls *_tb.v >/dev/null 2>&1; then
    mover_arq "tb" *_tb.v
fi

# Código Fonte (Arquivos .v que restaram)
if ls *.v >/dev/null 2>&1; then
    mover_arq "src" *.v
fi

# Includes (.vh)
if ls *.vh >/dev/null 2>&1; then
    mover_arq "include" *.vh
fi

# Scripts (.tcl e .do)
if ls *.tcl *.do >/dev/null 2>&1; then
    mover_arq "scripts" *.tcl *.do
fi

# Documentação
if [ -f "README.md" ]; then
    mover_arq "docs" README.md
fi

echo "Organização concluída!"
