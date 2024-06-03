
#///// ========================== ADQUIRIR.SH ====================================== /////
#///// =================================================================================== /////
#/////     Scipt que utiliza el programa adquirir.c para adquirir datos de la FPGA   /////
#///// =================================================================================== /////
#
# Script para adquirir datos del ADC de la FPGA, guardarla en un archivo y enviarla de nuevo a la PC 

# Uso: adquirir N frecuencia ciclos2display nombre_archivo fifo2read


N=${1:-1}
frecuencia=${2:-100000}
ciclos2display=${3:-4}
nombre_archivo=${4:-datos_test.dat}
fifo2read=${5:-0}
ip=${6:-192.168.1.101}

scp -r ../cpp/adquirir root@$ip:/root/Documents/de1soc_sw/cpp/
scp -r ../cpp/fpga_driver root@$ip:/root/Documents/de1soc_sw/cpp/

ssh root@$ip <<EOF

	cd /root/Documents/de1soc_sw/cpp/adquirir/
	make
	./adquirir $N $frecuencia $ciclos2display $nombre_archivo $fifo2read
EOF

cd ../datos_adquiridos
scp root@$ip:/root/Documents/de1soc_sw/cpp/adquirir/$nombre_archivo .

#read -p "Presione cualquier tecla para salir..."