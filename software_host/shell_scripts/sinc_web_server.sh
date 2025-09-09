#///// ========================== sinc_cpp.sh ====================================== /////
#///// ============================================================================= /////
#/////                  Scipt para enviar el web server a la FPGA                    /////
#///// ============================================================================= /////
#
#!/bin/bash

# Directorio de origen y destino
source_dir="../../software_de1soc/web_server"
remote_dir="/var/www/html"
script_file="sinc_web_server.sh"

# Destino en el servidor remoto
remote_user="root"
remote_ip="192.168.1.2"

# Ejecutar el comando rsync
rsync -av --exclude="$script_file" "$source_dir/" "$remote_user@$remote_ip:$remote_dir/"

#scp -r $source_dir/ $remote_user@$remote_ip:$remote_dir/


ssh $remote_user@$remote_ip "chmod 0644 /var/www/html/led_test/index.html /var/www/html/lockin/index.html; \
                             chmod 0777 /var/www/html /var/www/html/led_test /var/www/html/lockin; \
                             chmod 0755 /var/www/html /var/www/html/led_test /var/www/html/lockin; \
                             systemctl stop web_server; \
                             systemctl start web_server;"   


echo "¡Copia completada!"


