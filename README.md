# lockin_de1soc
Detección Lock-in con DE1-SoC

# Carpeta Hardware
Hardware de la FPGA, realiza el Lock-in de dos formas distintas

1) LI: Lock-in con filtro de media movil (MAF) de N_ma x N_ca ciclos de señal.
2) CA_LI: Promediación coherente de N_ca ciclos seguido de Lock-in con MAF de N_ma ciclos.

Se puede parametrizar la operación de distintas maneras, por hw o por sw

## Solo parametrizable por HW (Necesario cambiar el archivo efficient_lockin.v)

.fuente_dac:	Determina de donde salen los datos que van a la FPGA
.fuente_fifos: Determina de donde salen los datos que van a cada una de las 4 memorias FIFO:
	*fuente_fifo0_32bit
	*fuente_fifo1_32bit
	*fuente_fifo0_64bit
	*fuente_fifo1_64bit
.data_adc_hs: Determina el canal de operación del ADC Higspeed (actualmente se usa un SW de la placa)

Opciones para estos parámetros:
.adc_2308 = 0;
.adc_hs = 1;
.simulacion = 2;
.procesada_1 = 3;
.procesada_2 = 4;
.avgd_signal = 5;
.dds_compiler_sen = 6;
.dds_compiler_cos = 7;
.referencia_seno = 8;
.referencia_coseno = 9;
.datos_procesamiento = 10;
.open = 11;

## Parametrizable por Software
EL uP del De1-SoC puede gestionar la operacion del sistema cambiando algunos parámetros:

.fuente_procesamiento: De donde salen los datos del procesamiento (.adc_2308 = 0;.adc_hs = 1;.simulacion = 2;)
.M: Cantidad de puntos por ciclo en modo de tabla de consulta directa
.N_ma_CALI: Cantidad de ciclos promediados en MA para el CALI
.N_ca_CALI: Cantidad de ciclos promediados coherentemente para CALI
.sim_noise: Bits de ruido para la simulacion
.seleccion_resultado: Determina si el resultado que se muestra es CALI o LI
.N_LI: Cantidad de ciclos promediados en MA para el LI
.delta_phase_ref: Incremento de fase para la referencia en modo dds
.delta_phase_dac: Incremento de fase para el dac en modo dds
.dds_in_data_sim: Determina como controlo las referencias y el DAC (1 dds, 0 tabla de consulta directa)
.led_test: Prende o apaga un led (util para disgnostico inicial)

# Carpeta software_de1soc
Software pensado para copiar en el uP de la FPGA y usarlo directamente ahi..

## Carpeta de1soc_sw

### Carpeta Firmware
Tiene el Firmware necesario para gestionar la FPGA desde el uP. 
Ejecutando el shell script set_firmware.sh con el archivo .rbf generado por quartus se setea el bitstream de la FPGA (es necesario reiniciar antes)
También hay algunos .rbf que están probados.

### Carpetas FIR_*
Usa la FPGA en un filtro FIR. Debe tener configurado el .rbf fir_filter
Tiene opciones para ejecutarlo desde una GUI o desde consola

### Carpetas lockin_*
Configura y usa la FPGA como lockin. Debe tener configurado el bitstream "lockin_estable.rbf"
Tambien tiene opciones para usarlo desde la consola o desde una GUI

### Carpetas *_test
Testeo de cosas preeliminares

## Carpeta python
Version preeliminar del software del lockin en python (en proceso)

## Carpeta web_server
Monta un servidor WEB en el uP de la FPGA para usar el Lock-in sin mucho conocimiento.
Habría que copiar todo lo que hay aca al directorio raiz del servido HTTP de uP y listo.
La FPGA debe tener configurada el lockin_estable.rbf para que esto funcione bien..
Este servidor se vale de archivos cpp que estan definidos en software_host, y deben copiarse a una carpeta apropiada y compilarse


# Carpeta software_host
Este software esta pensado para ejecutarse desde la compu HOST

## Shell scripts
Con estos scripts se puede adquirir, calcular el lockin y hacer barridos directamente desde la compu HOST a través de ssh
Primero hay que copiar todos los archivos de la carpeta cpp al de1soc (/root/Documents/de1soc_sw/cpp) y compilarlos con el make_all
Una vez que se hace eso ya deberían andar los scripts, con el bitstream lockin_estable.rbf
También se puede copiar fácil todo lo que es web_server al directorio necesario con sinc_web_server.sh

## Carpeta cpp
Archivos base para que la FPGA pueda ejecutar distintos programas del lockin. 
Con el shellscript sinc_cpp se pueden copiar a la FPGA, al directorio /root/Documents/de1soc_sw/cpp

## Python
Estos scripts usan los .sh a traves de process para automatizar la operación directamente desde la compu HOST.
Sería una alternativa a usar el Web server para usuarios mas especializados.




