#!/bin/bash
#Linea shebang

# sysinfo - Un script que informa del estado del sistema

##### Constantes

TITLE="Información del sistema para $HOSTNAME"

RIGHT_NOW=$(date +"%x %r%Z")
TIME_STAMP="Actualizada el $RIGHT_NOW por $USER"


##### Estilos


TEXT_BOLD=$(tput bold)
TEXT_ULINE=$(tput sgr 0 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)


##### Funciones


system_info()
{
   # Función de stub temporal
   echo "${TEXT_ULINE}Versión del sistema${TEXT_RESET}"
   echo
   uname -a
}


show_uptime()
{
   # Función de stub temporal
   echo "${TEXT_ULINE}Tiempo de encendido del sistema$TEXT_RESET"
   echo
   uptime
}


drive_space()

{
   # Función de stub temporal
   echo "${TEXT_ULINE}Espacio ocupado en particiones/discos duros del sistema$TEXT_RESET"
   echo
   df -h
}


home_space()
{
    # Función de stub temporal
   echo "${TEXT_ULINE}Espacio ocupado por cada uno de los directorios de /home$TEXT_RESET"
   echo
   echo "USADO    DIRECTORIO"
   if [ "$USER" != root ]; then
      du -s /home/$USER | cut -d / -f 1,3 | tr -d /
   else 
      du --max-depth=1 /home | cut -d / -f 1,3 | tr -d / | head -n 1 | sort -nr
   fi
}


##### Programa principal


cat << _EOF_

$TEXT_BOLD$TITLE$TEXT_RESET


$TEXT_GREEN$TIME_STAMP$TEXT_RESET

_EOF_


system_info
show_uptime
drive_space
home_space
