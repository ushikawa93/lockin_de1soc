
#///// ========================== MEASURE_LOCKIN.SH ====================================== /////
#///// =================================================================================== /////
#/////     Scipt que utiliza el programa barrido_en_f.c para adquirir datos de la FPGA   /////
#///// =================================================================================== /////
#
# Script para medir con el lockin en la FPGA en varias frecuencias, guardar resultados en un archivo y enviarlos de nuevo a la PC 

# Uso -> barrido_en_f M | N | fuente | modo | f_inicial | f_final | f_step | nombre_archivo | ip

# Uso del programa -> barrido_en_f M | N | fuente | modo | f_inicial | f_final | f_step | nombre_archivo  


M=${1:-32}
N=${2:-1}
fuente=${3:-1}
modo=${4:-0}
f_inicial=${5:-10000}
f_final=${6:-20000}
f_step=${7:-5000}
nombre_archivo=${8:-datos_test.dat}
ip=${9:-192.168.1.101}


scp -r ../program/barrido_en_f root@$ip:/root/Documents/de1soc_sw/shell_scripts/

ssh root@$ip <<EOF

	cd /root/Documents/de1soc_sw/shell_scripts/barrido_en_f/
	make
	./barrido_f $M $N $fuente $modo $f_inicial $f_final $f_step $nombre_archivo 
EOF

#cd ../datos_adquiridos
scp root@$ip:/root/Documents/de1soc_sw/shell_scripts/barrido_en_f/$nombre_archivo .
