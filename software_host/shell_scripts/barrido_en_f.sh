
#///// ========================== MEASURE_LOCKIN.SH ====================================== /////
#///// =================================================================================== /////
#/////     Scipt que utiliza el programa barrido_en_f.c para adquirir datos de la FPGA   /////
#///// =================================================================================== /////
#
# Script para medir con el lockin en la FPGA en varias frecuencias, guardar resultados en un archivo y enviarlos de nuevo a la PC 

# Uso -> barrido_en_f f_clk | N | fuente | modo | f_inicial | f_final | f_step | nombre_archivo  | corregir_fase | ip

# Uso del programa -> barrido_en_f f_clk | N | fuente | modo | f_inicial | f_final | f_step | nombre_archivo  | corregir_fase


f_clk=${1:-32}
N=${2:-1}
fuente=${3:-1}
modo=${4:-0}
f_inicial=${5:-10000}
f_final=${6:-20000}
f_step=${7:-5000}
nombre_archivo=${8:-datos_test.dat}
corregir_fase=${9,-1}
sim_noise=${10,-1}
ip=${11:-192.168.1.101}


scp -r ../cpp/barrido_en_f root@$ip:/root/Documents/de1soc_sw/cpp/
scp -r ../cpp/fpga_driver root@$ip:/root/Documents/de1soc_sw/cpp/


ssh root@$ip <<EOF

	cd /root/Documents/de1soc_sw/cpp/barrido_en_f/
	make
	./barrido_f $f_clk $N $fuente $modo $f_inicial $f_final $f_step $nombre_archivo $corregir_fase $sim_noise
EOF

#cd ../datos_adquiridos
scp root@$ip:/root/Documents/de1soc_sw/cpp/barrido_en_f/$nombre_archivo ../datos_adquiridos/$nombre_archivo

read -p "Presione cualquier tecla para salir..."
