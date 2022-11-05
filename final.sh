#!/bin/bash

TEXT_BOLD=$(tput bold)
TEXT_ULINE=$(tput sgr 0 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

HEADER=$(df -ahT | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | head -1) 
NAME=$(df -ah | awk '{print $1, $3}' | tail -n+2 | sort -f)
HELP="Este programa muestra informacion acerca de los tipos de sistemas, donde estan montado y el espacio que ocupan"
var1=$(ps -A -o etimes | sed 1d | head | awk '{ sum+=$1} END {print sum}')

## df -ahT | sort -b -k2,2 -u --debug #Comando para obtener tipos de sistemas de archivo unicos 
## df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | sort -f -k1,1

system_info ()
{
  # al llamar a las funciones los parametros posicionales pierden su valor
  # pasar parametros con system_info $@

  if [ "$#" -eq 0 ]; then # El simbolo '#' contiene el numero de elementos en la linea de comandos
    df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | sort -f -k1,1
    # df -ahT | awk '{print $1, $2, $7, $4}' | tail -n+2 | sort -fu -k1,1 
    
  else 
    df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | sort -rf -k1,1
  fi

}

case $1 in
  "-h" | "--help") 
    echo $HELP
    ;;
  "-inv" ) 
    #echo  $HEADER  #por que al hacer la expansion no funciona el formateo del texto?
    df -ahT | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | head -1
    # system_info | sort -rf
    system_info $@
    #echo "====================================================================================="
    #echo "$(($var1/3600)) horas"
    
    ;;
  "" )
    df -ahT | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | head -1
    #df -ahT | awk '{print $1, $2, $7, $4}' | head -1 | column -t
    
    system_info $@
    #echo "====================================================================================="
    #echo "$(($var1/3600)) horas"
    
    ;;
  * ) 
    echo "Parametro incorrecto" 1>&2
    exit 1
    ;;
esac
