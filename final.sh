#!/bin/bash

HEADER=$(df -ah | awk '{printf "%-14s %-28s %-7s\n", $1, $6, $3}' | head -1)
NAME=$(df -ah | awk '{print $1, $3}' | tail -n+2 | sort -f)
HELP="Este programa muestra informacion acerca de los tipos de sistemas, donde estan montado y el espacio que ocupan"

system_info ()
{
  # al llamar a las funciones los parametros posicionales pierden su valor

  if [ "$#" -eq 0 ]; then # El simbolo '#' contiene el numero de elementos en la linea de comandos
    df -ah | awk '{printf "%-14s %-28s %-7s\n", $1, $6, $3}' | tail -n+2 | sort -fu -k1,1 
    #for var in $NAME; do
    #  echo "linea $var"
    #done  
  fi
}

case $1 in
  "-h" | "--help") 
    echo $HELP
    ;;
  "-inv" ) 
    ## echo -e $HEADER por que al hacer la expansion no funciona el formateo del texto?
    df -ah | awk '{printf "%-14s %-28s %-7s\n", $1, $6, $3}' | head -1
    system_info | sort -rf
    ;;
  "" )
    df -ah | awk '{printf "%-14s %-28s %-7s\n", $1, $6, $3}' | head -1
    system_info
    ;;
  * ) 
    echo "Parametro incorrecto"
    exit 1
    ;;
esac

