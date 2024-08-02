#!/bin/bash

# Función para mostrar la ayuda sobre el uso del script
function mostrar_ayuda {

    echo -e """\n\t\t
     ┬─┐┌─┐┌─┐ ┌─┐┌┐┌┬ ┬┌┬┐
     ├┬┘├─┘│───├┤ ││││ ││││
     ┴└─┴  └─┘ └─┘┘└┘└─┘┴ ┴\n"""


    echo "Uso: $0 -s <IP_DEL_SERVIDOR> [-u <USUARIO> -p <CONTRASEÑA>] [-n (opcional)] -f <FUNCION>" # $0 es el primer parámetro , es una variable  especial en bash
    echo
    echo -e "\t[*] Opciones:"
    echo "-------------------------------------"
    echo "  -s, --server       IP del servidor"
    echo "  -u, --user         Usuario (opcional, solo necesario si no se usa -n)"
    echo "  -p, --password     Contraseña (opcional, solo necesario si no se usa -n)"
    echo "  -n, --nullsession  Usar sesión nula (anónima)"
    echo "  -f, --function     Función a ejecutar"
    echo -e "  -h, --help         Mostrar esta ayuda\n"
    echo -e "Funciones disponibles:\n"
    echo "---------------------- enum_users"
    echo "---------------------- enum_groups"
    echo "---------------------- enum_shares"
    echo "---------------------- enum_group_members"
    echo "---------------------- enum_password_policy"
    echo "---------------------- user_info"
    echo "---------------------- enum_printers"
    echo "---------------------- query_server_info"
    echo "---------------------- querydispinfo"
    echo "---------------------- full_report"
   
}

# Inicialización de variables
SERVER_IP=""
USERNAME=""
PASSWORD=""
FUNCTION=""
NULLSESSION=0

# Procesar los argumentos de la línea de comandos
while [[ "$#" -gt 0 ]]; do #Esa línea es parte de un bucle while  y se usa para procesar los argumentos que se pasan al script
    case $1 in
        -s|--server) SERVER_IP="$2"; shift ;;      # IP del servidor
        -u|--user) USERNAME="$2"; shift ;;         # Nombre de usuario
        -p|--password) PASSWORD="$2"; shift ;;     # Contraseña
        -n|--nullsession) NULLSESSION=1 ;;        # Activar sesión nula
        -f|--function) FUNCTION="$2"; shift ;;     # Función a ejecutar
        -h|--help) mostrar_ayuda; exit 0 ;;        # Mostrar ayuda
        *) echo "Opción desconocida: $1"; mostrar_ayuda; exit 1 ;;  # Manejo de opciones no válidas
    esac
    shift
done

# Verificar si se proporcionaron todos los argumentos necesarios
if [[ -z "$SERVER_IP" || -z "$FUNCTION" ]]; then # Esa línea es una condición if en Bash que se utiliza para verificar si las variables SERVER_IP o FUNCTION están vacías. Aquí está el desglose
    mostrar_ayuda
    exit 1
fi

# Determinar si se usará sesión nula
if [[ $NULLSESSION -eq 1 ]]; then # es una estructura condicional if que se usa para verificar el valor de una variable y, en función de esa verificación, ejecutar un bloque de código.
    USERNAME=""
    PASSWORD=""
fi

# Función para enumerar usuarios
function enum_users {
    echo "Enumerando usuarios en el servidor $SERVER_IP..."
    printf "%-20s %-10s\n" "Usuario" "RID" # La línea printf "%-20s %-10s\n" "Usuario" "RID" en Bash se usa para formatear y alinear la salida en la terminal
    printf "%-20s %-10s\n" "------" "---"
    rpcclient -U "$USERNAME%$PASSWORD" -c "enumdomusers" $SERVER_IP | while read -r line; do
        if [[ $line =~ user:\[([^\]]+)\]\ rid:\[([^\]]+)\] ]]; then # La línea if [[ $line =~ user:\[([^\]]+)\]\ rid:\[([^\]]+)\] ]]; then utiliza una expresión regular para verificar si una cadena ($line) coincide con un patrón específico
            printf "%-20s %-10s\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done | column -t
}

# Función para enumerar grupos
function enum_groups {
    echo "Enumerando grupos en el servidor $SERVER_IP..."
    printf "%-20s %-10s\n" "Grupo" "RID"
    printf "%-20s %-10s\n" "-----" "---"
    rpcclient -U "$USERNAME%$PASSWORD" -c "enumdomgroups" $SERVER_IP | while read -r line; do
        if [[ $line =~ group:\[([^\]]+)\]\ rid:\[([^\]]+)\] ]]; then
            printf "%-20s %-10s\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done | column -t
}

# Función para enumerar recursos compartidos
function enum_shares {
    echo "Enumerando recursos compartidos en el servidor $SERVER_IP..."
    printf "%-20s %-10s\n" "Recurso" "Tipo"
    printf "%-20s %-10s\n" "-------" "----"
    rpcclient -U "$USERNAME%$PASSWORD" -c "netshareenum" $SERVER_IP | while read -r line; do
        if [[ $line =~ netname:\[([^\]]+)\]\ type:\[([^\]]+)\] ]]; then
            printf "%-20s %-10s\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done | column -t
}

# Función para enumerar miembros de grupos
function enum_group_members {
    echo "Enumerando miembros de grupos en el servidor $SERVER_IP..."
    printf "%-20s %-20s\n" "Grupo" "Miembro"
    printf "%-20s %-20s\n" "-----" "-------"
    rpcclient -U "$USERNAME%$PASSWORD" -c "enumalsgroups domain" $SERVER_IP | while read -r line; do
        if [[ $line =~ group:\[([^\]]+)\]\ member:\[([^\]]+)\] ]]; then
            printf "%-20s %-20s\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done | column -t
}

# Función para obtener políticas de contraseña
function enum_password_policy {
    echo "Enumerando políticas de contraseña en el servidor $SERVER_IP..."
    rpcclient -U "$USERNAME%$PASSWORD" -c "getdompwinfo" $SERVER_IP
}

# Función para obtener información de un usuario
function user_info {
    echo "Introduzca el nombre del usuario para obtener información:"
    read user
    echo "Obteniendo información del usuario $user en el servidor $SERVER_IP..."
    rpcclient -U "$USERNAME%$PASSWORD" -c "queryuser $user" $SERVER_IP
}

# Función para enumerar impresoras
function enum_printers {
    echo "Enumerando impresoras en el servidor $SERVER_IP..."
    printf "%-20s %-10s\n" "Impresora" "Descripción"
    printf "%-20s %-10s\n" "---------" "-----------"
    rpcclient -U "$USERNAME%$PASSWORD" -c "enumprinters" $SERVER_IP | while read -r line; do
        if [[ $line =~ printername:\[([^\]]+)\]\ description:\[([^\]]+)\] ]]; then
            printf "%-20s %-10s\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done | column -t
}

# Función para consultar la configuración del servidor
function query_server_info {
    echo "Consultando configuración del servidor $SERVER_IP..."
    rpcclient -U "$USERNAME%$PASSWORD" -c "srvinfo" $SERVER_IP
}

# Función para consultar la disposición del servidor
function querydispinfo {
    echo "Consultando información de la disposición del servidor $SERVER_IP..."
    rpcclient -U "$USERNAME%$PASSWORD" -c "querydispinfo" $SERVER_IP
}

# Función para generar un informe completo
function full_report {
    echo "Generando informe completo para el servidor $SERVER_IP..."
    
    echo -e "\nEnumerando usuarios..."
    enum_users
    
    echo -e "\nEnumerando grupos..."
    enum_groups
    
    echo -e "\nEnumerando recursos compartidos..."
    enum_shares
    
    echo -e "\nEnumerando miembros de grupos..."
    enum_group_members
    
    echo -e "\nObteniendo políticas de contraseña..."
    enum_password_policy
    
    echo -e "\nObteniendo información del usuario (especificar nombre)..."
    user_info
    
    echo -e "\nEnumerando impresoras..."
    enum_printers
    
    echo -e "\nConsultando información del servidor..."
    query_server_info
    
    echo -e "\nConsultando información de la disposición..."
    querydispinfo
}

# Ejecutar la función especificada
case $FUNCTION in
    enum_users) enum_users ;;
    enum_groups) enum_groups ;;
    enum_shares) enum_shares ;;
    enum_group_members) enum_group_members ;;
    enum_password_policy) enum_password_policy ;;
    user_info) user_info ;;
    enum_printers) enum_printers ;;
    query_server_info) query_server_info ;;
    querydispinfo) querydispinfo ;;
    full_report) full_report ;;
    *) echo "Función desconocida: $FUNCTION"; mostrar_ayuda; exit 1 ;;
esac
