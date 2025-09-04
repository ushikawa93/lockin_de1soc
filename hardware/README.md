# Efficient_lockin

## Hardware

Proyecto Lock-in en de1SoC con plataforma highspeed AD/DA

Este Proyecto toma una señal proveniente de alguna de las 3 opciones de origen de señal:

1) Señal provieniente de highspeed AD/DA
2) Señal proveniente de ADC LTC2308 (ADC integrado en la placa de1SoC)
3) Señal simulada con ruido configurable

Y realiza el Lock-in de dos formas distintas:

1) LI: Lock-in con filtro de media movil (MAF) de N_ma x N_ca ciclos de señal.
2) CA_LI: Promediación coherente de N_ca ciclos seguido de Lock-in con MAF de N_ma ciclos.

El top level file del módulo es efficient_lockin.v. 

### Parámetros configurables por Software

En este se pueden configurar algunos parámetros de la operación:

- fuente_procesamiento: Determina cuales son los datos que se procesan en el Lock-in	
- fuente_dac: Determina de donde salen los datos que van al DAC
- fuente_fifos: Determina de donde salen los datos que van a cada una de las 4 memorias FIFO:
  - fuente_fifo0_32bit
  - fuente_fifo1_32bit
  - fuente_fifo0_64bit
  - fuente_fifo1_64bit
- data_adc_hs: Determina el canal de operación del ADC Higspeed (actualmente se selecciona con un SW de la placa)

- Opciones para estos parámetros:
  - adc_2308 = 0
  - adc_hs = 1
  - simulacion = 2
  - procesada_1 = 3
  - procesada_2 = 4
  - avgd_signal = 5
  - dds_compiler_sen = 6
  - dds_compiler_cos = 7
  - referencia_seno = 8
  - referencia_coseno = 9
  - datos_procesamiento = 10
  - open = 11

El módulo incluye un puente lightweight axi bus para comunicación con el CPU de la DE1SoC (ARM-Cortex A9).

Si en cambio se quisiera controlar el sistema desde un procesador instanciado en las celdas lógicas de la FPGA, debe instanciarse el módulo correspondiente desde el QSYS (acualmente está comentado).

## Software 

En la carpeta software hay programas para controlar la operación del Lock-in desde el CPU de la de1SoC
Para ello en la FPGA debe estar cargado el bitstream "efficient_lockin_estable.rbf" disponible en software/Firmware. En esa carpeta hay también un pequeño programa en C++ para gestionar la carga de bitstreams en la plataforma. Este programa se vale de un shell script llamado set_bitstream.sh que también se puede usar para configurar el rbf deseado en la SoC-FPGA.

Recomiendo usar el programa lockin_consola. 
Este esta escrito en c# y utiliza pipes para comunicarse con la FPGA por medio de un driver escrito en c.
	-> Ejecutar con el shell script run_lia_consola.sh

También hay un programa (verion beta) que implementa una interfaz de usuario grafica (software/hps/LIA_GUI)

También estan disponibles las herramientas para controlar el diseño a través de un procesador NIOS (signal_procesing y signal_procesing_bsp). Esto puede ser útil para otras placas que no dispongan de CPU.

