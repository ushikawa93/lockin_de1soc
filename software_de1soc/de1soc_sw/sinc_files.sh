#scp -r ../de1soc_sw root@192.168.1.2:/root/Documents

#!/bin/bash

# Verificar si se proporcionó un argumento
if [ $# -eq 0 ]; then
    echo "Uso: $0 <nombre_subcarpeta> (o all para copiar todo)"
    exit 1
fi



# Directorio de origen
if [ "$1" = "all" ]; then
    source_dir="../de1soc_sw"
	remote_dir="/root/Documents"
else
    source_dir="../de1soc_sw/$1"
	remote_dir="/root/Documents/de1soc_sw"
fi

# Verificar si el directorio de origen existe
if [ ! -d "$source_dir" ]; then
    echo "La subcarpeta '$1' no existe en '../de1soc_sw'."
    exit 1
fi

# Destino en el servidor remoto
remote_user="root"
remote_ip="192.168.1.2"


# Ejecutar el comando scp
scp -r "$source_dir" "$remote_user@$remote_ip:$remote_dir"

echo "¡Copia completada!"