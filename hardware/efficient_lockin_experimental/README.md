# Efficient_lockin

## Hardware

Proyecto Lock-in en de1SoC con plataforma highspeed AD/DA

Este Proyecto toma una señal proveniente de alguna de las 3 opciones de origen de señal:

1) Señal provieniente de highspeed AD/DA
2) Señal proveniente de ADC LTC2308 (ADC integrado en la placa de1SoC)
3) Señal simulada

Y realiza el Lock-in de dos formas distintas:

1) LI: Lock-in con filtro de media movil (MAF) de N_ma x N_ca ciclos de señal.
2) CA_LI: Promediación coherente de N_ca ciclos seguido de Lock-in con MAF de N_ma ciclos.

## Software 

En la carpeta software hay programas para controlar la operación del Lock-in desde el CPU de la de1SoC
Para ello en la FPGA debe estar cargado el bitstream "efficient_lockin_estable.rbf" disponible en software/Firmware

Recomiendo usar el programa lockin_consola. 
Este esta escrito en c# y utiliza pipes para comunicarse con la FPGA por medio de un driver escrito en c.
	-> Ejecutar con el shell script run_lia_consola.sh

También hay un programa (verion beta) que implementa una interfaz de usuario grafica (software/hps/LIA_GUI)

También estan disponibles las herramientas para controlar el diseño a través de un procesador NIOS (signal_procesing y signal_procesing_bsp). Esto puede ser útil para otras placas que no dispongan de CPU.

