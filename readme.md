![imagen script](img/Captura%20de%20pantalla%202024-08-02%20132020.png)


<div style="display: flex; align-items: center;">
    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Gnu-bash-logo.svg/1200px-Gnu-bash-logo.svg.png" alt="Bash Icon" width="50" style="margin-right: 10px;"/>
    <img src="https://upload.wikimedia.org/wikipedia/commons/a/af/Tux.png" alt="Linux Icon" width="50" style="margin-right: 10px;"/>
    <img src="https://cdn-icons-png.flaticon.com/512/732/732225.png" alt="Windows Icon" width="50" style="margin-right: 10px;"/>
</div>


# Script de Enumeración de Recursos en Servidores Windows

Este script en Bash está diseñado para realizar diversas tareas de enumeración en servidores Windows, utilizando `rpcclient` para interactuar con los servicios del servidor. A continuación se proporciona una explicación detallada de su funcionamiento y de cada una de sus funcionalidades.

## Descripción General

El script permite:
- Enumerar usuarios, grupos y recursos compartidos.
- Obtener información detallada de usuarios.
- Consultar políticas de contraseña, impresoras, y la configuración general del servidor.
- Generar informes completos de los recursos enumerados.

## Uso del Script

Para ejecutar el script, se deben proporcionar ciertos parámetros obligatorios y opcionales desde la línea de comandos.

### Parámetros Obligatorios y Opcionales

- `-s, --server <IP_DEL_SERVIDOR>`: Especifica la IP del servidor objetivo.
- `-u, --user <USUARIO>`: Nombre de usuario (opcional, requerido si no se usa `-n`).
- `-p, --password <CONTRASEÑA>`: Contraseña del usuario (opcional, requerido si no se usa `-n`).
- `-n, --nullsession`: Utilizar sesión nula (anónima).
- `-f, --function <FUNCION>`: Especifica la función a ejecutar.
- `-h, --help`: Muestra la ayuda y uso del script.

### Ejemplo de Uso

```bash
./script.sh -s 192.168.1.1 -u admin -p password -f enum_users
```




### Herramienta hecha en bash 
---



[![Instagram](https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/i_100_user/)
[![YouTube](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@User_user-lv4jh)


