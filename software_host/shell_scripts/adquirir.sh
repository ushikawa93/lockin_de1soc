
#///// ========================== ADQUIRIR.SH ====================================== /////
#///// =================================================================================== /////
#/////     Scipt que utiliza el programa adquirir.c para adquirir datos de la FPGA   /////
#///// =================================================================================== /////
#
# Script para adquirir datos del ADC de la FPGA, guardarla en un archivo y enviarla de nuevo a la PC 

# Uso -> adquirir.sh  M | N | frecuencia | ciclos2display | nombre_archivo  | ip

# Uso del programa -> adquirir M | N | frecuencia | ciclos2display | nombre_archivo 


M=${1:-32}
N=${2:-1}
frecuencia=${3:-100000}
ciclos2display=${4:-4}
nombre_archivo=${5:-datos_test.dat}
ip=${6:-192.168.1.101}


scp -r ../program/adquirir root@$ip:/root/Documents/de1soc_sw/shell_scripts/

ssh root@$ip <<EOF

	cd /root/Documents/de1soc_sw/shell_scripts/adquirir/
	make
	./adquirir $M $N $frecuencia $ciclos2display $nombre_archivo
EOF

cd ../datos_adquiridos
scp root@$ip:/root/Documents/de1soc_sw/shell_scripts/adquirir/$nombre_archivo .
