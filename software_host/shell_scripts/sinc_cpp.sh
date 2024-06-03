
#!/bin/bash

# Directorio de origen y destino
source_dir="../cpp"
remote_dir="/root/Documents/de1soc_sw/cpp"
script_file="sinc_cpp.sh"

# Destino en el servidor remoto
remote_user="root"
remote_ip="192.168.1.2"

# Ejecutar el comando rsync
rsync -av --exclude="$script_file" "$source_dir/" "$remote_user@$remote_ip:$remote_dir/"
echo "¡Copia completada!"


