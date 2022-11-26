#!/bin/bash

TEXT_BOLD=$(tput bold)
TEXT_ULINE=$(tput sgr 0 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

HEADER=$(df -ahT | head -1 | awk '{printf "%-14s %-14s %-28s %-7s %-15s %-13s %-15s %-15s\n", $1, $2, $7, $4, "Tot. Devices", "Tot. Used", "Min. Number", "Max. Number"}')  
HELP="Este programa muestra informacion acerca de los tipos de sistemas, donde estan montado y el espacio que ocupan"

TABLA=$(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | sort -f -k1,1)

system_info ()
{
  it=0
  counter=0
  ## DATA CONTIENE CADA LINEA DE LA TABLA
  for data in $(df -ahT | tail -n+2 | sort -b -k2,2 -u)
  do
    ((counter=counter+1))
    case $counter in
      "1")
        ls -l $data > /dev/null 2>&1  
        if [ $? -eq 0 ]; then
          echo "$data"
          mayor=$(ls -l $data | awk -F'[ ,]' '{print $5}')
          echo "$mayor"
          menor=$(ls -l $data | awk -F'[ ,]' '{print $7}')
        
        else 
          mayor=$(echo "*")
          menor=$(echo "*")
        
        fi 
        ;;
      "2")
        total_dev=$(df -ahTt $data | tail -n+2 | wc -l)
        total_sum=$(df -aTt $data | tail -n+2 | awk '{sum+=$4} END {print sum}')
        ;;
      "3")
        ((it=it+1))
        
        aux=$(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | sort -f -k1,1 | sed -n "$it"p)
        echo "$aux" "$(printf "%-15s %-13s %-15s %-15s\n" "$total_dev" "$total_sum" "$mayor" "$menor")"
        ;;
    esac
    # 7 is the number of columns
    if [ $counter -eq "7" ]; then
      ((counter=0))
    fi
  done
  
}

case $1 in
  "-h" | "--help") 
    echo "$HELP"
    ;;
  "-inv" ) 
    echo "${TEXT_ULINE}$HEADER${TEXT_RESET}"  #por que al hacer la expansion no funciona el formateo del texto?
    system_info | sort -rf -k1,1 
    ;;
  "" )
    echo "$TEXT_ULINE$HEADER$TEXT_RESET"
    system_info #$@
    ;;
  "-devicefiles")
    
    ;;
  * ) 
    echo "Parametro incorrecto" 1>&2
    exit 1
    ;;
esac
