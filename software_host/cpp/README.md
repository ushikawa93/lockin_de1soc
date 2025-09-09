
# Programas en c++ para controlar la acción del Lockin

Estos programas se pueden llamar desde la linea de comandos del SoC, con argumentos que parametrizan la operación. Cada uno tiene un makefile para su compilación, o pueden compilarse todos juntos usando el shell script "make_all.sh".

## toggle_led

 -> Uso: toggle_led led_state
 
 Autoexplicativo... sirve para probar si llegan los msj del micro a la FPGA

## adquirir 

 -> Uso: adquirir N frecuencia ciclos2display nombre_archivo fifo2read

Genera un archivo de txt de nombre "nombre_archivo" en el se muestran "ciclos2display" ciclos de la señal guardada en el fifo "fifo2read" (1 o 2). 

Parametros adicionales: 	
	-> N: Ciclos de promediación coherente en la señal.
	-> frecuencia: Frecuencia de la señal generada en el DAC (en base a esta frecuencia tambien se hace la promediación).
	

## adquirir2

 -> Uso: adquirir2 N frecuencia ciclos2display nombre_archivo [sim_noise f_clk fuente](opcional)
 
 Genera un archivo de txt de nombre "nombre_archivo" en el se muestran "ciclos2display" ciclos de las señales guardadas en los fifos (1 y 2).

 Parametros adicionales: 	
	-> N: Ciclos de promediación coherente en la señal.
	-> frecuencia: Frecuencia de la señal generada en el DAC (en base a esta frecuencia tambien se hace la promediación).
		
 Opcionales:
	-> sim_noise: Ruido de la señal simulada
	-> f_clk: Frecuencia del reloj principal
	-> fuente: 0 adc_2308 | 1 adc_hs | 2 simulacion 
	

## barrido_en_f

 -> Uso: barrido_en_f f_clk N fuente modo f_inicial f_final f_step nombre_archivo corregir_fase sim_noise 
 
Calcula el Lock-in para el rango de frecuencias -> ["f_inicial","f_final"] con pasos dados por "f_step" y guarda los resultados en "nombre_archivo"

Parametros adicionales: 	
	-> f_clk: Frecuencia del reloj principal
	-> modo: 0 CALI | 1 LI 
	-> N: Ciclos de promediación coherente en la señal para CALI o de promedio movil para LI.
	-> frecuencia: Frecuencia de la señal generada en el DAC (en base a esta frecuencia tambien se hace la promediación).
	-> fuente: 0 adc_2308 | 1 adc_hs | 2 simulacion 
	-> corregir_fase: 1 para corregir efectos de la etapa analógica en la fase (retraso de la señal por el camino)
	-> sim_noise: Ruido de la señal simulada


## measure_lockin

 -> Uso: measure_lockin sim_noise N frecuencia fuente modo nombre_archivo [f_clk corregir_fase](opcional)
 
 Calcula el Lock-in en la "frecuencia" seleccionada. Guarda los resultados en "nombre_archivo".
 
 Parametros adicionales: 	
	-> modo: 0 CALI | 1 LI 
	-> N: Ciclos de promediación coherente en la señal para CALI o de promedio movil para LI.
	-> frecuencia: Frecuencia de la señal generada en el DAC (en base a esta frecuencia tambien se hace la promediación).
	-> fuente: 0 adc_2308 | 1 adc_hs | 2 simulacion 
	-> sim_noise: Ruido de la señal simulada
	
 Opcionales:
	-> f_clk: Frecuencia del reloj principal
	-> corregir_fase: 1 para corregir efectos de la etapa analógica en la fase (retraso de la señal por el camino)

