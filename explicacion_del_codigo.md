# Script de Administración de Servidor

Este script de Bash está diseñado para interactuar con un servidor remoto y realizar diversas tareas administrativas usando `rpcclient`. A continuación, se detalla el funcionamiento y las opciones disponibles del script.

## Encabezado

```bash
#!/bin/bash
```

#  - Funcion de mostrar ayuda 
```bash
function mostrar_ayuda {
    echo -e """ 
    # ASCII Art
    """
    echo "Uso: $0 -s <IP_DEL_SERVIDOR> [-u <USUARIO> -p <CONTRASEÑA>] [-n (opcional)] -f <FUNCION>"
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
```
>Muestra la ayuda sobre el uso del script, incluyendo las opciones disponibles y las funciones que se pueden ejecutar.

### Mas info 
El parámetro `-e` en el comando `echo` en bash se utiliza para habilitar la interpretación de secuencias de escape. Por ejemplo, permite el uso de `\n` para nueva línea, `\t` para tabulación, entre otros. 

Ejemplo:

```bash
echo -e "Línea 1\nLínea 2"
```

Esto imprimirá:

```
Línea 1
Línea 2
```

# Inicialización de Variables
```bash
SERVER_IP=""
USERNAME=""
PASSWORD=""
FUNCTION=""
NULLSESSION=0
```
>Define variables para almacenar los parámetros proporcionados y una  bandera (un indicador booleano)  para la sesión nula.



# Procesamiento de Argumentos
```bash
Copiar código
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--server) SERVER_IP="$2"; shift ;;
        -u|--user) USERNAME="$2"; shift ;;
        -p|--password) PASSWORD="$2"; shift ;;
        -n|--nullsession) NULLSESSION=1 ;;
        -f|--function) FUNCTION="$2"; shift ;;
        -h|--help) mostrar_ayuda; exit 0 ;;
        *) echo "Opción desconocida: $1"; mostrar_ayuda; exit 1 ;;
    esac
    shift
done
```
> Procesa los argumentos pasados al script, asignando valores a las variables correspondientes y gestionando la ayuda y opciones desconocidas.




```markdown
# Explicación del Código de Procesamiento de Argumentos

Este fragmento de código Bash se encarga de procesar los argumentos proporcionados en la línea de comandos para configurar las variables del script. Aquí está el desglose detallado:

```bash
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--server) SERVER_IP="$2"; shift ;;
        -u|--user) USERNAME="$2"; shift ;;
        -p|--password) PASSWORD="$2"; shift ;;
        -n|--nullsession) NULLSESSION=1 ;;
        -f|--function) FUNCTION="$2"; shift ;;
        -h|--help) mostrar_ayuda; exit 0 ;;
        *) echo "Opción desconocida: $1"; mostrar_ayuda; exit 1 ;;
    esac
    shift
done
```

### Explicación

1. **`while [[ "$#" -gt 0 ]]; do`**:
   - Este bucle `while` se ejecuta mientras haya argumentos (`"$#"` representa el número de argumentos restantes) en la línea de comandos.

2. **`case $1 in`**:
   - La estructura `case` evalúa el primer argumento (`$1`) y compara su valor con las opciones especificadas en el patrón (`-s|--server`, `-u|--user`, etc.).

3. **Opciones en `case`**:
   - **`-s|--server) SERVER_IP="$2"; shift ;;`**:
     - Si el argumento es `-s` o `--server`, asigna el siguiente argumento (`$2`) a la variable `SERVER_IP` y usa `shift` para desplazar los argumentos hacia la izquierda.
   - **`-u|--user) USERNAME="$2"; shift ;;`**:
     - Similar al anterior, pero asigna el siguiente argumento a la variable `USERNAME`.
   - **`-p|--password) PASSWORD="$2"; shift ;;`**:
     - Similar, pero asigna el siguiente argumento a la variable `PASSWORD`.
   - **`-n|--nullsession) NULLSESSION=1 ;;`**:
     - Si el argumento es `-n` o `--nullsession`, establece `NULLSESSION` a `1`, indicando que se debe usar una sesión nula.
   - **`-f|--function) FUNCTION="$2"; shift ;;`**:
     - Si el argumento es `-f` o `--function`, asigna el siguiente argumento a la variable `FUNCTION`.
   - **`-h|--help) mostrar_ayuda; exit 0 ;;`**:
     - Si el argumento es `-h` o `--help`, llama a la función `mostrar_ayuda` para mostrar información sobre cómo usar el script y luego termina el script con `exit 0` (código de salida 0 indica éxito).
   - **`*) echo "Opción desconocida: $1"; mostrar_ayuda; exit 1 ;;`**:
     - Para cualquier otro argumento que no coincida con las opciones especificadas, muestra un mensaje de "Opción desconocida" y llama a `mostrar_ayuda`, luego termina el script con `exit 1` (código de salida 1 indica error).

4. **`shift`**:
   - Al final del bucle `while`, `shift` se usa para mover todos los argumentos hacia la izquierda, de modo que `$2` se convierte en `$1`, `$3` en `$2`, etc. Esto permite procesar el siguiente argumento en la siguiente iteración del bucle.

5. **`done`**:
   - Marca el final del bucle `while`.

### Resumen

Este fragmento de código procesa los argumentos de la línea de comandos para configurar las variables del script. Utiliza un bucle `while` para iterar a través de todos los argumentos, un `case` para identificar y manejar cada opción, y `shift` para avanzar a través de los argumentos. Maneja tanto las opciones válidas como las desconocidas, y proporciona una manera de mostrar la ayuda y salir del script según sea necesario.


# Verificación de Argumentos Necesarios
```bash
Copiar código
if [[ -z "$SERVER_IP" || -z "$FUNCTION" ]]; then
    mostrar_ayuda
    exit 1
fi
Asegura que se hayan proporcionado los parámetros obligatorios (SERVER_IP y FUNCTION). Si falta alguno, muestra la ayuda y sale.
```




```markdown
# Verificación de Argumentos Necesarios

Este fragmento de código verifica que se hayan proporcionado los argumentos obligatorios antes de continuar con la ejecución del script.

```bash
if [[ -z "$SERVER_IP" || -z "$FUNCTION" ]]; then
    mostrar_ayuda
    exit 1
fi
```

### Explicación

- **`if [[ -z "$SERVER_IP" || -z "$FUNCTION" ]]; then`**:
  - La condición `[[ -z "$VARIABLE" ]]` verifica si la variable está vacía o no está definida (`-z` significa "es cero"). Aquí se usa para comprobar si `SERVER_IP` o `FUNCTION` están vacías.
  - La parte `||` actúa como un operador "O lógico". La condición completa será verdadera si al menos una de las variables (`SERVER_IP` o `FUNCTION`) está vacía.

- **`mostrar_ayuda`**:
  - Si la condición es verdadera (es decir, si falta uno de los parámetros obligatorios), se llama a la función `mostrar_ayuda` para proporcionar información sobre cómo usar el script.

- **`exit 1`**:
  - Termina la ejecución del script con un código de salida `1`, que indica que se ha producido un error. Esto es útil para indicar que la falta de parámetros obligatorios ha impedido la ejecución correcta del script.

### Resumen

Este fragmento de código asegura que los parámetros obligatorios (`SERVER_IP` y `FUNCTION`) se hayan proporcionado. Si alguno de estos parámetros falta, muestra la ayuda al usuario y termina el script con un código de error.

---

```markdown
# Configuración de Sesión Nula

Este fragmento de código configura la autenticación para usar una sesión nula si se especifica la opción `-n`.

```bash
if [[ $NULLSESSION -eq 1 ]]; then
    USERNAME=""
    PASSWORD=""
fi
```

### Explicación

- **`if [[ $NULLSESSION -eq 1 ]]; then`**:
  - La condición `[[ $NULLSESSION -eq 1 ]]` verifica si la variable `NULLSESSION` tiene el valor `1`. Esto indica que se debe usar una sesión nula (o anónima).

- **`USERNAME=""`**:
  - Si la condición es verdadera, se establece la variable `USERNAME` como una cadena vacía. Esto significa que no se proporcionará un nombre de usuario para la autenticación.

- **`PASSWORD=""`**:
  - Similarmente, se establece la variable `PASSWORD` como una cadena vacía. Esto indica que no se proporcionará una contraseña para la autenticación.

### Resumen

Si se especifica la opción `-n` en los argumentos del script, este fragmento de código configura la autenticación para usar una sesión nula al establecer el nombre de usuario y la contraseña como vacíos. Esto permite al script conectarse al servidor sin requerir credenciales de autenticación.



```markdown
# Funciones del Script

Cada función en el script realiza una tarea específica utilizando el comando `rpcclient`. A continuación se detalla cada función junto con sus comentarios y expresiones regulares utilizadas.

## `enum_users`

Enumera los usuarios del servidor especificado.

```bash
function enum_users {
    echo "Enumerando usuarios en el servidor $SERVER_IP..."
    printf "%-20s %-10s\n" "Usuario" "RID"  # Encabezados de columnas
    printf "%-20s %-10s\n" "------" "---"  # Separadores de columnas
    rpcclient -U "$USERNAME%$PASSWORD" -c "enumdomusers" $SERVER_IP | while read -r line; do
        if [[ $line =~ user:\[([^\]]+)\]\ rid:\[([^\]]+)\] ]]; then
            printf "%-20s %-10s\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done | column -t
}
```

- **Descripción**: Esta función lista todos los usuarios en el servidor especificado.
- **Comentarios**:
  - `rpcclient -U "$USERNAME%$PASSWORD" -c "enumdomusers" $SERVER_IP` ejecuta el comando para enumerar usuarios.
  - `printf` se usa para formatear la salida en columnas.
  - La expresión regular `user:\[([^\]]+)\]\ rid:\[([^\]]+)\]` captura el nombre del usuario y el RID.
  - `${BASH_REMATCH[1]}` y `${BASH_REMATCH[2]}` extraen el nombre de usuario y el RID, respectivamente.

## `enum_groups`

Enumera los grupos del servidor especificado.

```bash
function enum_groups {
    echo "Enumerando grupos en el servidor $SERVER_IP..."
    printf "%-20s %-10s\n" "Grupo" "RID"  # Encabezados de columnas
    printf "%-20s %-10s\n" "-----" "---"  # Separadores de columnas
    rpcclient -U "$USERNAME%$PASSWORD" -c "enumdomgroups" $SERVER_IP | while read -r line; do
        if [[ $line =~ group:\[([^\]]+)\]\ rid:\[([^\]]+)\] ]]; then
            printf "%-20s %-10s\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done | column -t
}
```

- **Descripción**: Esta función lista todos los grupos en el servidor especificado.
- **Comentarios**:
  - `rpcclient -U "$USERNAME%$PASSWORD" -c "enumdomgroups" $SERVER_IP` ejecuta el comando para enumerar grupos.
  - `printf` formatea la salida en columnas.
  - La expresión regular `group:\[([^\]]+)\]\ rid:\[([^\]]+)\]` captura el nombre del grupo y el RID.
  - `${BASH_REMATCH[1]}` y `${BASH_REMATCH[2]}` extraen el nombre del grupo y el RID, respectivamente.

## `enum_shares`

Enumera los recursos compartidos en el servidor especificado.

```bash
function enum_shares {
    echo "Enumerando recursos compartidos en el servidor $SERVER_IP..."
    printf "%-20s %-10s\n" "Recurso" "Tipo"  # Encabezados de columnas
    printf "%-20s %-10s\n" "-------" "----"  # Separadores de columnas
    rpcclient -U "$USERNAME%$PASSWORD" -c "netshareenum" $SERVER_IP | while read -r line; do
        if [[ $line =~ netname:\[([^\]]+)\]\ type:\[([^\]]+)\] ]]; then
            printf "%-20s %-10s\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done | column -t
}
```

- **Descripción**: Esta función lista todos los recursos compartidos en el servidor.
- **Comentarios**:
  - `rpcclient -U "$USERNAME%$PASSWORD" -c "netshareenum" $SERVER_IP` obtiene la lista de recursos compartidos.
  - `printf` formatea la salida en columnas.
  - La expresión regular `netname:\[([^\]]+)\]\ type:\[([^\]]+)\]` captura el nombre del recurso y su tipo.
  - `${BASH_REMATCH[1]}` y `${BASH_REMATCH[2]}` extraen el nombre del recurso y el tipo.

## `enum_group_members`

Enumera los miembros de los grupos en el servidor especificado.

```bash
function enum_group_members {
    echo "Enumerando miembros de grupos en el servidor $SERVER_IP..."
    printf "%-20s %-20s\n" "Grupo" "Miembro"  # Encabezados de columnas
    printf "%-20s %-20s\n" "-----" "-------"  # Separadores de columnas
    rpcclient -U "$USERNAME%$PASSWORD" -c "enumalsgroups domain" $SERVER_IP | while read -r line; do
        if [[ $line =~ group:\[([^\]]+)\]\ member:\[([^\]]+)\] ]]; then
            printf "%-20s %-20s\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done | column -t
}
```

- **Descripción**: Esta función enumera los miembros de todos los grupos en el servidor.
- **Comentarios**:
  - `rpcclient -U "$USERNAME%$PASSWORD" -c "enumalsgroups domain" $SERVER_IP` obtiene los miembros de los grupos.
  - `printf` formatea la salida en columnas.
  - La expresión regular `group:\[([^\]]+)\]\ member:\[([^\]]+)\]` captura el grupo y el miembro.
  - `${BASH_REMATCH[1]}` y `${BASH_REMATCH[2]}` extraen el nombre del grupo y el miembro.

## `enum_password_policy`

Obtiene las políticas de contraseña del servidor especificado.

```bash
function enum_password_policy {
    echo "Enumerando políticas de contraseña en el servidor $SERVER_IP..."
    rpcclient -U "$USERNAME%$PASSWORD" -c "getdompwinfo" $SERVER_IP
}
```

- **Descripción**: Obtiene y muestra las políticas de contraseñas del servidor.
- **Comentarios**:
  - `rpcclient -U "$USERNAME%$PASSWORD" -c "getdompwinfo" $SERVER_IP` obtiene la información de las políticas de contraseña.

## `user_info`

Obtiene información sobre un usuario específico.

```bash
function user_info {
    echo "Introduzca el nombre del usuario para obtener información:"
    read user
    echo "Obteniendo información del usuario $user en el servidor $SERVER_IP..."
    rpcclient -U "$USERNAME%$PASSWORD" -c "queryuser $user" $SERVER_IP
}
```

- **Descripción**: Obtiene información detallada sobre un usuario específico.
- **Comentarios**:
  - `read user` solicita al usuario el nombre del usuario para el cual se necesita información.
  - `rpcclient -U "$USERNAME%$PASSWORD" -c "queryuser $user" $SERVER_IP` consulta la información del usuario especificado.

## `enum_printers`

Enumera las impresoras en el servidor especificado.

```bash
function enum_printers {
    echo "Enumerando impresoras en el servidor $SERVER_IP..."
    printf "%-20s %-10s\n" "Impresora" "Descripción"  # Encabezados de columnas
    printf "%-20s %-10s\n" "---------" "-----------"  # Separadores de columnas
    rpcclient -U "$USERNAME%$PASSWORD" -c "enumprinters" $SERVER_IP | while read -r line; do
        if [[ $line =~ printername:\[([^\]]+)\]\ description:\[([^\]]+)\] ]]; then
            printf "%-20s %-10s\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done | column -t
}
```

- **Descripción**: Lista todas las impresoras disponibles en el servidor.
- **Comentarios**:
  - `rpcclient -U "$USERNAME%$PASSWORD" -c "enumprinters" $SERVER_IP` enumera las impresoras del servidor.
  - `printf` formatea la salida en columnas.
  - La expresión regular `printername:\[([^\]]+)\]\ description:\[([^\]]+)\]` captura el nombre de la impresora y su descripción.
  - `${BASH_REMATCH[1]}` y `${BASH_REMATCH[2]}` extraen el nombre y la descripción de la impresora.

## `query_server_info`

Consulta la configuración del servidor especificado.

```bash
function query_server_info {
    echo "Consultando configuración del servidor $SERVER_IP..."
    rpcclient -U "$USERNAME%$PASSWORD" -c "srvinfo" $SERVER_IP
}
```

- **Descripción**: Muestra la configuración general del servidor.
- **Comentarios**:
  - `rpcclient -U "$USERNAME%$PASSWORD" -c "srvinfo" $SERVER_IP` consulta la información de

 configuración del servidor.

## `querydispinfo`

Consulta la disposición del servidor especificado.

```bash
function querydispinfo {
    echo "Consultando información de la disposición del servidor $SERVER_IP..."
    rpcclient -U "$USERNAME%$PASSWORD" -c "querydispinfo" $SERVER_IP
}
```

- **Descripción**: Obtiene información sobre la disposición del servidor.
- **Comentarios**:
  - `rpcclient -U "$USERNAME%$PASSWORD" -c "querydispinfo" $SERVER_IP` obtiene la disposición del servidor.

## `full_report`

Genera un informe completo que incluye todas las funciones disponibles.

```bash
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
```

- **Descripción**: Genera un informe exhaustivo que abarca todas las funciones del script.
- **Comentarios**:
  - Llama a cada una de las funciones definidas para proporcionar una vista completa de la configuración y los recursos del servidor.
---

```markdown
# Ejecución de la Función

Esta sección del script decide qué función ejecutar en función del valor de la variable `FUNCTION`. Utiliza una estructura `case` para determinar cuál de las funciones definidas debe ejecutarse.

## Código

```bash
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
```

## Explicación

- **Descripción**: Esta sección del script determina cuál función debe ejecutarse basándose en el valor de la variable `FUNCTION`, que se especifica como argumento de entrada. Si la variable `FUNCTION` coincide con uno de los casos definidos, se llama a la función correspondiente. Si no coincide con ninguno de los casos, se muestra un mensaje de error y se muestra la ayuda.

- **Comentarios**:
  - `case $FUNCTION in`: Inicia una estructura `case` que compara el valor de la variable `FUNCTION` con los diferentes patrones definidos.
  - `enum_users) enum_users ;;`: Si `FUNCTION` es igual a `enum_users`, se ejecuta la función `enum_users`.
  - `enum_groups) enum_groups ;;`: Si `FUNCTION` es igual a `enum_groups`, se ejecuta la función `enum_groups`.
  - `enum_shares) enum_shares ;;`: Si `FUNCTION` es igual a `enum_shares`, se ejecuta la función `enum_shares`.
  - `enum_group_members) enum_group_members ;;`: Si `FUNCTION` es igual a `enum_group_members`, se ejecuta la función `enum_group_members`.
  - `enum_password_policy) enum_password_policy ;;`: Si `FUNCTION` es igual a `enum_password_policy`, se ejecuta la función `enum_password_policy`.
  - `user_info) user_info ;;`: Si `FUNCTION` es igual a `user_info`, se ejecuta la función `user_info`.
  - `enum_printers) enum_printers ;;`: Si `FUNCTION` es igual a `enum_printers`, se ejecuta la función `enum_printers`.
  - `query_server_info) query_server_info ;;`: Si `FUNCTION` es igual a `query_server_info`, se ejecuta la función `query_server_info`.
  - `querydispinfo) querydispinfo ;;`: Si `FUNCTION` es igual a `querydispinfo`, se ejecuta la función `querydispinfo`.
  - `full_report) full_report ;;`: Si `FUNCTION` es igual a `full_report`, se ejecuta la función `full_report`.
  - `*) echo "Función desconocida: $FUNCTION"; mostrar_ayuda; exit 1 ;;`: Si `FUNCTION` no coincide con ninguno de los casos anteriores, se muestra un mensaje indicando que la función es desconocida y se llama a la función `mostrar_ayuda`. Luego, el script sale con un código de error 1.

Este enfoque permite una gestión clara y estructurada de las diferentes opciones de funciones disponibles, asegurando que el script ejecute la acción correcta según el valor proporcionado en el argumento `FUNCTION`.
