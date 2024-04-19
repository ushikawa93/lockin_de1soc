
#!/bin/bash

# Directorio de origen y destino
source_dir="$PWD"
remote_dir="/var/www/html"
script_file="sinc_web_server.sh"

# Destino en el servidor remoto
remote_user="root"
remote_ip="192.168.0.2"

# Ejecutar el comando rsync
#rsync -av --exclude="$script_file" "$source_dir/" "$remote_user@$remote_ip:$remote_dir/"

scp -r $source_dir/ $remote_user@$remote_ip:$remote_dir/


#ssh $remote_user@$remote_ip chmod 0644 /var/www/html/index.html
#ssh $remote_user@$remote_ip chmod 0777 /var/www/html
#ssh $remote_user@$remote_ip chmod 0755 /var/www/html

echo "¡Copia completada!"


