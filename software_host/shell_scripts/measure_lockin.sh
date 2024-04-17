
#///// ========================== MEASURE_LOCKIN.SH ====================================== /////
#///// =================================================================================== /////
#/////     Scipt que utiliza el programa measure_lockin.c para adquirir datos de la FPGA   /////
#///// =================================================================================== /////
#
# Script para medir con el lockin en la FPGA, guardar resultados en un archivo y enviarlos de nuevo a la PC 

# Uso -> measure_lockin.sh  M | N | frecuencia | fuente | modo | NOMBRE_ARCHIVO_SALIDA | ip

# Uso del programa -> measure_lockin M | N | frecuencia | fuente | modo | NOMBRE_ARCHIVO_SALIDA 


M=${1:-32}
N=${2:-1}
frecuencia=${3:-100000}
fuente=${4:-1}
modo=${5:-0}
nombre_archivo=${6:-datos_test.dat}
ip=${7:-192.168.1.101}


scp -r ../program/measure_lockin root@$ip:/root/Documents/de1soc_sw/shell_scripts/
scp -r ../program/fpga_driver root@$ip:/root/Documents/de1soc_sw/shell_scripts/


ssh root@$ip <<EOF

	cd /root/Documents/de1soc_sw/shell_scripts/measure_lockin/
	make
	./measure_li $M $N $frecuencia $fuente $modo $nombre_archivo 
EOF

cd ../datos_adquiridos
scp root@$ip:/root/Documents/de1soc_sw/shell_scripts/measure_lockin/$nombre_archivo .

read -p "Presione cualquier tecla para salir..."