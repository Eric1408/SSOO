#!/bin/bash

## MODIFICADORES DE ESTILO
TEXT_BOLD=$(tput bold)
TEXT_ULINE=$(tput sgr 0 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

## HEADER Y TEXTO DE USO
HEADER=$(df -ahT | head -1 | awk '{printf "%-14s %-14s %-28s %-7s %-15s %-13s %-15s %-15s\n", $1, $2, $7, $4, "Tot. Devices", "Tot. Used", "Min. Number", "Max. Number"}')  
DEVFILES=$(printf "%-15s\n" "Dev. Files")
HELP="Este programa muestra informacion acerca de los tipos de sistemas, donde estan montado y el espacio que ocupan"

## TABLA Y SUS COMPONENETES
TABLA_ORIG=$(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | sort -f -k1,1)
TABLA_MOD=""
COLUMN1=$(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{print $1}')
COLUMN2=$(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{print $2}')
## POR QUE NO FUNCIONA LA EXPANSION DE ABAJO?
#COLUMN1=$($TABLA_ORIG | awk '{print $1}')

system_info ()
{
  it=0
  counter=0
  first_loop=1
  ## DATA CONTIENE CADA DATO DE LA TABLA_ORIG CUYO DELIMITADOR ES EL ESPACIO
  for data in $(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{print $1, $2}')
  do
    case $counter in
      ## CASE 0 SELECCIONA LA COLUMNA FILESYSTEM
      "0")
        ls -l $data > /dev/null 2>&1  
        if [ $? -eq 0 ]; then
          mayor=$(ls -l $data | awk -F'[ ,]' '{print $5}')
          menor=$(ls -l $data | awk -F'[ ,]' '{print $7}')
        else 
          mayor=$(echo "*")
          menor=$(echo "*")
        fi 
        ;;
      ## CASE 1 SELECCIONA LA COLUMNA TYPE
      "1")
        ## COMPRUEBA SI ES UN TIPO ACCESIBLE POR df
        df -ahTt $data > /dev/null 2>&1
        if [ $? -eq 0 ]; then
          total_dev=$(df -ahTt $data | tail -n+2 | wc -l)
          total_sum=$(df -aTt $data | tail -n+2 | awk '{sum+=$4} END {print sum}')
        else 
          ((total_dev=0))
          ((total_sum=0))
        fi
        
        ((it=it+1))
        ## CON line OBTENEMOS UNA UNICA LINEA DE LA TABLA_ORIG, ESTA LINEA SE VA ITERANDO
        line=$(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | sort -f -k1,1 | sed -n "$it"p)
        #line=$("$TABLA_ORIG" | sed -n "$it"p)
        to_table=$(echo "$line" "$(printf "%-15s %-13s %-15s %-15s\n" "$total_dev" "$total_sum" "$mayor" "$menor")")
        echo "$to_table"
        #(( $first_loop )) &&
        #TABLA_MOD="$to_table" ||
        #TABLA_MOD="$TABLA_MOD"$'\n'"$to_table"
        #unset first_loop
        ;;
    esac
    ((counter=counter+1))
    # 2 is the number of columns, this is the counter reset
    if [ $counter -eq "2" ]; then
      ((counter=0))
    fi
  done
  #echo "$TABLA_MOD"
}

device_files () {
  it=0
  counter=0
  first_loop=1

  ## DATA CONTIENE CADA DATO DE LA TABLA_ORIG CUYO DELIMITADOR ES EL ESPACIO
  for data in $(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{print $1, $2, $1}' | sort -f -k1,1)
  do
    case $counter in
      ## CASE 0 SELECCIONA LA COLUMNA FILESYSTEM
      "0")
        ls -l $data > /dev/null 2>&1  
        if [ $? -eq 0 ]; then
          mayor=$(ls -l $data | awk -F'[ ,]' '{print $5}')
          menor=$(ls -l $data | awk -F'[ ,]' '{print $7}')
        else 
          mayor=$(echo "*")
          menor=$(echo "*")
        
        fi 
        ;;
      ## CASE 1 SELECCIONA LA COLUMNA TYPE
      "1")
        ## COMPRUEBA SI ES UN TIPO ACCESIBLE POR df
        df -ahTt $data > /dev/null 2>&1
        if [ $? -eq 0 ]; then
          total_dev=$(df -ahTt $data | tail -n+2 | wc -l)
          total_sum=$(df -aTt $data | tail -n+2 | awk '{sum+=$4} END {print sum}')
        else 
          ((total_dev=0))
          ((total_sum=0))
        fi
        #echo "im here"
          
        ;;
      "2")
        ((it=it+1))
        lsof $data > /dev/null 2>&1
        if [ $? -eq 0 ]; then
          to_total=$(lsof "$data" | tail -n +2 | wc -l)
          ## CON line OBTENEMOS UNA UNICA LINEA DE LA TABLA_ORIG, ESTA LINEA SE VA ITERANDO
          #line=$(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | sort -f -k1,1 | sed -n "$it"p)
          #line=$("$TABLA_ORIG" | sed -n "$it"p)

          ## echo $(printf "%-14s %-14s %-28s %-7s %-15s %-13s %-15s %-15s %-15s\n" "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$to_total")
          ## (( $first_loop )) &&
          ## total="$to_total" ||
          ## total="$total"$' '"$to_total"
          ## CON line OBTENEMOS UNA UNICA LINEA DE LA TABLA_ORIG, ESTA LINEA SE VA ITERANDO
          
          line=$(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | sort -f -k1,1 | sed -n "$it"p)
          #line=$("$TABLA_ORIG" | sed -n "$it"p)
          to_table=$(echo "$line" "$(printf "%-15s %-13s %-15s %-15s %-15s\n" "$total_dev" "$total_sum" "$mayor" "$menor" "$to_total")")
          echo "$to_table"
          #(( $first_loop )) &&
          #TABLA_MOD="$to_table" ||
          #TABLA_MOD="$TABLA_MOD"$'\n'"$to_table"
          #unset first_loop
        fi
        ;;
    esac
    ((counter=counter+1))
    # 7 is the number of columns, this is the counter reset
    if [ $counter -eq "3" ]; then
      ((counter=0))
    fi
  done
  ## awk -v x="${to_total}" 'BEGIN { split(x,arr) } {printf "%-14s %-14s %-28s %-7s %-15s %-13s %-15s %-15s %-15s\n", $1, $2, $3, $4, $5, $6, $7, $8, arr[FNR]}'
}

the_nice_one () {
  it=1
  
  for data in $(awk '{print $1}')
  do
    echo "$data"
    ((it=it+1))
  done
}

users () {
  it=0
  counter=0
  first_loop=1
  checker=0

  ## DATA CONTIENE CADA DATO DE LA TABLA_ORIG CUYO DELIMITADOR ES EL ESPACIO
  for data in $(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{print $1, $2, $1}' | sort -f -k1,1)
  do
    case $counter in
      ## CASE 0 SELECCIONA LA COLUMNA FILESYSTEM
      "0")
        ls -l $data > /dev/null 2>&1  
        if [ $? -eq 0 ]; then
          mayor=$(ls -l $data | awk -F'[ ,]' '{print $5}')
          menor=$(ls -l $data | awk -F'[ ,]' '{print $7}')
        else 
          mayor=$(echo "*")
          menor=$(echo "*")
        
        fi 
        ;;
      ## CASE 1 SELECCIONA LA COLUMNA TYPE
      "1")
        ## COMPRUEBA SI ES UN TIPO ACCESIBLE POR df
        df -ahTt $data > /dev/null 2>&1
        if [ $? -eq 0 ]; then
          total_dev=$(df -ahTt $data | tail -n+2 | wc -l)
          total_sum=$(df -aTt $data | tail -n+2 | awk '{sum+=$4} END {print sum}')
        else 
          ((total_dev=0))
          ((total_sum=0))
        fi
        
        ;;
      "2")
        ((it=it+1))
        lsof $data > /dev/null 2>&1
        if [ $? -eq 0 ]; then
          to_total=$(lsof "$data" | tail -n +2 | wc -l)
          user=$(lsof "$data" | tail -n +2 | sed -n "$it"p | awk '{print $3}')
          
          ## CON line OBTENEMOS UNA UNICA LINEA DE LA TABLA_ORIG, ESTA LINEA SE VA ITERANDO
          #line=$(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | sort -f -k1,1 | sed -n "$it"p)
          #line=$("$TABLA_ORIG" | sed -n "$it"p)
          
          ## echo $(printf "%-14s %-14s %-28s %-7s %-15s %-13s %-15s %-15s %-15s\n" "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$to_total")
          ## (( $first_loop )) &&
          ## total="$to_total" ||
          ## total="$total"$' '"$to_total"
          ## CON line OBTENEMOS UNA UNICA LINEA DE LA TABLA_ORIG, ESTA LINEA SE VA ITERANDO
          line=$(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{printf "%-14s %-14s %-28s %-7s\n", $1, $2, $7, $4}' | sort -f -k1,1 | sed -n "$it"p)
          #line=$("$TABLA_ORIG" | sed -n "$it"p)
          to_table=$(echo "$line" "$(printf "%-15s %-13s %-15s %-15s %-15s\n" "$total_dev" "$total_sum" "$mayor" "$menor" "$to_total")")
          for it in $@ 
          do
            if [ "$user" == "$it" ]; then
              echo "$to_table"
            fi
          done
          #echo "$it"
          #(( $first_loop )) &&
          #TABLA_MOD="$to_table" ||
          #TABLA_MOD="$TABLA_MOD"$'\n'"$to_table"
          #unset first_loop
        fi
        ;;
    esac
    
    ((counter=counter+1))
    # 7 is the number of columns, this is the counter reset
    if [ $counter -eq "3" ]; then
      ((counter=0))
    fi
  done
}

#while [ "$1" != "" ]; do
  case $1 in
    "-h" | "--help") 
      echo "$HELP"
      exit 1
      ;;
    "-inv" ) 
      echo "${TEXT_ULINE}${TEXT_BOLD}$HEADER${TEXT_RESET}"  #por que al hacer la expansion no funciona el formateo del texto?
      system_info | sort -rf -k1,1 
      ;;
    "" )
      echo "${TEXT_ULINE}${TEXT_BOLD}$HEADER${TEXT_RESET}"
      # $@ ENVIA TODOS LOS PARAMETROS PASADOS POR LINEA DE COMANDO
      system_info 
      #echo "$TABLA_MOD"
      ;;
    "-devicefiles")
      echo "${TEXT_BOLD}${TEXT_ULINE}${HEADER}${DEVFILES}${TEXT_RESET}"
      device_files
      #system_info | the_nice_one
      
      ;;
    "-u")
      echo "${TEXT_BOLD}${TEXT_ULINE}${HEADER}${DEVFILES}${TEXT_RESET}"
      users $@
      ;;
    * ) 
      echo "Parametro incorrecto" 1>&2
      exit 1
      ;;
  esac
  #shift
#done

##another_funct () {
##  select=0
##  first_loop=1
##  second_loop=1
##  columns=$(df -ahT | tail -n+2 | sort -b -k2,2 -u | awk '{print $1, $2}')
##  ## DATA CONTIENE CADA DATO DE LA TABLA_ORIG CUYO DELIMITADOR ES EL ESPACIO
##  for data in $columns
##  do
##    case $select in
##      "0")
##        ls -l $data > /dev/null 2>&1  
##        if [ $? -eq 0 ]; then
##          ## THIS EXPLAIN THIS CODE PART -> https://stackoverflow.com/questions/9139401/trying-to-embed-newline-in-a-variable-in-bash
##          ## (( $first_loop )) &&
##          ## p="$data"         ||
##          ## p="$p"$'\n'"$data"
##          ## unset first_loop
##          to_mayor=$(ls -l $data | awk -F'[ ,]' '{print $5}')
##          to_menor=$(ls -l $data | awk -F'[ ,]' '{print $7}')
##
##          (( $first_loop )) &&
##          mayor="$to_mayor" ||
##          mayor="$mayor"$'\n'"$to_mayor"
##          unset first_loop
##
##          (( $second_loop )) &&
##          menor="$to_menor" ||
##          menor="$menor"$'\n'"$to_menor"
##          unset second_loop
##        else 
##          (( $first_loop )) &&
##          mayor="$(echo "*")" ||
##          mayor="$mayor"$'\n'"$(echo "*")"
##          unset first_loop
##
##          (( $second_loop )) &&
##          menor="$(echo "*")" ||
##          menor="$menor"$'\n'"$(echo "*")"
##          unset second_loop
##        fi 
##      ;;
##      "1")
##        df -ahTt $data > /dev/null 2>&1
##        if [ $? -eq 0 ]; then
##          to_dev=$(df -ahTt $data | tail -n+2 | wc -l)
##          to_sum=$(df -aTt $data | tail -n+2 | awk '{sum+=$4} END {print sum}')
##
##          (( $first_loop )) &&
##          total_dev="$to_dev" ||
##          total_dev="$total_dev"$'\n'"$to_dev"
##          unset first_loop
##
##          (( $second_loop )) &&
##          total_sum="$to_sum" ||
##          total_sum="$total_sum"$'\n'"$to_sum"
##          unset second_loop
##        else 
##          zero=0
##          (( $first_loop )) &&
##          total_dev="$zero" ||
##          total_dev="$total_dev"$'\n'"$zero"
##          unset first_loop
##
##          (( $second_loop )) &&
##          total_sum="$zero" ||
##          total_sum="$total_sum"$'\n'"$zero"
##          unset second_loop
##        fi
##      ;;
##    esac
##    ((select=select+1))
##    if [ $select -eq 2 ]; then
##      ((select=0))
##    fi
##  done
##  #echo "$menor"
##  #echo "$mayor"
##  #echo "$total_dev"
##  #echo "$total_sum"
##}
