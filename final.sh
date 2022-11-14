#!/bin/bash

TEXT_BOLD=$(tput bold)
TEXT_ULINE=$(tput sgr 0 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

HEADER=$(df -ahT | head -1 | awk '{printf "%-14s %-14s %-28s %-7s %-15s %-13s\n", $1, $2, $7, $4, "Tot. Devices", "Tot. Used"}')  
HELP="Este programa muestra informacion acerca de los tipos de sistemas, donde estan montado y el espacio que ocupan"

TABLA=$(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | sort -f -k1,1)

system_info ()
{
  it=0
  #if [ "$#" -eq 0 ]; then # El simbolo '#' contiene el numero de elementos en la linea de comandos  
    for type in $(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{print $2}')
    do
      total_dev=$(df -ahTt $type | tail -n+2 | wc -l)
      total_sum=$(df -aTt $type | tail -n+2 | awk '{sum+=$4} END {print sum}')
      
      ((it=it+1))

      aux=$(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | sort -f -k1,1 | sed -n "$it"p)
      echo "$aux" "$(printf "%-15s %-13s\n" "$total_dev" "$total_sum")" 
    done
  #fi
}

system_info2 ()
{
  it=0
  counter=0
  #if [ "$#" -eq 0 ]; then # El simbolo '#' contiene el numero de elementos en la linea de comandos  
  for data in $(df -ahT | tail -n+2 | sort -b -k2,2 -u)
  do
    it=0
    ((counter=counter+1))
    case $counter in
      "1")
        #echo "$counter"
        ls -l $data 1>&3
        if [ $? -eq 0 ]; then
          echo "correcto!"
        else 
          echo "mal"
        fi 
        ;;
      "2")
        #echo "Dentro del counter = 2"
        total_dev=$(df -ahTt $data | tail -n+2 | wc -l)
        total_sum=$(df -aTt $data | tail -n+2 | awk '{sum+=$4} END {print sum}')
        ;;
      "3")
        ((it=it+1))
        aux=$(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | sort -f -k1,1 | sed -n "$it"p)
        echo "$aux" "$(printf "%-15s %-13s\n" "$total_dev" "$total_sum")"
        ;;
    esac
    if [ $counter -eq "7" ]; then
      ((counter=0))
    fi
    #echo "$line"
    #type=$($line | awk '{print $2}')
    ##total_dev=$(df -ahTt $type | tail -n+2 | wc -l)
    ##total_sum=$(df -aTt $type | tail -n+2 | awk '{sum+=$4} END {print sum}')
    ##
    ##((it=it+1))
#
    ##aux=$(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | sort -f -k1,1 | sed -n "$it"p)
    ##echo "$aux" "$(printf "%-15s %-13s\n" "$total_dev" "$total_sum")" 
  done
  #fi
}

case $1 in
  "-h" | "--help") 
    echo "$HELP"
    ;;
  "-inv" ) 
    echo "${TEXT_ULINE}$HEADER${TEXT_RESET}"  #por que al hacer la expansion no funciona el formateo del texto?
    system_info2 | sort -rf -k1,1
    ;;
  "" )
    echo "$TEXT_ULINE$HEADER$TEXT_RESET"
    system_info2 #$@
    ;;
  * ) 
    echo "Parametro incorrecto" 1>&2
    exit 1
    ;;
esac
