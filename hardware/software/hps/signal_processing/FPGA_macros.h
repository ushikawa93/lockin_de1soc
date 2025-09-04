/*
================================================================================
 Macros para interacción con FPGA
 Archivo: mmaped_macros.h
--------------------------------------------------------------------------------
 Este archivo define las direcciones de memoria mapeadas (memory-mapped) para
 acceder a los registros y FIFOs de la FPGA desde software, así como los 
 parámetros de entrada y salida.

 Funcionalidad principal:
   - Mapear direcciones físicas de la FPGA a punteros en C.
   - Definir macros para parámetros de configuración y resultados.
   - Establecer límites de frecuencia y tamaño de buffers.
   - Facilitar la extensión de entradas/salidas según se requiera.

Definiciones incluidas:
   - Bases de memoria: ENABLE_BASE, RESET_BASE, FINALIZACION_BASE, etc.
   - Parámetros de configuración: PARAMETERS_BASE y variantes.
   - Punteros a FIFOs y registros de resultados de 32 y 64 bits.
   - Macros de entradas y salidas: DATA_IN_[0..15], DATA_OUT_[0..15].
   - Parámetros auxiliares: SALIDA_AUX_[0..4], PARAMETER_[0..9].
   - Límites de frecuencia de reloj: MAX_FREC_CLK, MIN_FREC_CLK.
   - Tamaño de buffers: BUFFER_SIZE_RAW.

Uso típico:
   - Acceder a registros usando punteros: int* enable_ptr = (int*)ENABLE_BASE;
   - Leer/Escribir parámetros usando los macros de DATA_IN/DATA_OUT.
   - Ajustar límites de frecuencia y tamaño de buffer según necesidad del sistema.

================================================================================
*/


// Estas son algunos macros que necesito para mapear la FPGA en memoria
#define ALT_LWFPGASLVS_OFST 0xff200000
#define ALT_STM_OFST 0xfc000000
#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )

// Direccion de memoria de la FPGA de todas las cosas que quiero acceder
#define ENABLE_BASE 0x42170
#define RESET_BASE 0x42180

#define FINALIZACION_BASE 0x42160

#define N_parametros 40
#define PARAMETERS_BASE 0x41800
#define PARAMETERS_1_BASE 0x41000
#define PARAMETERS_2_BASE 0x40800
#define PARAMETERS_3_BASE 0x40000

#define DIVISOR_CLOCK_BASE 0x42190
#define PLL_RECONFIGURAR_BASE 0x42000

#define FIFO0_32_BIT_BASE 0x421a8
#define FIFO1_32_BIT_BASE 0x421a0
#define RESULT0_32_BIT_BASE 0x42110
#define RESULT1_32_BIT_BASE 0x42100

#define FIFO0_64_BIT_DOWN_BASE 0x421c0
#define FIFO0_64_BIT_UP_BASE 0x421c8
#define FIFO1_64_BIT_DOWN_BASE 0x421b0
#define FIFO1_64_BIT_UP_BASE 0x421b8

#define RESULT0_64_BIT_DOWN_BASE 0x42140
#define RESULT0_64_BIT_UP_BASE 0x42150
#define RESULT1_64_BIT_DOWN_BASE 0x42120
#define RESULT1_64_BIT_UP_BASE 0x42130


// Aca conecto los parametros que quiero controlar a las I/O del mmaped
#define PARAMETER_0 DATA_OUT_0				//DATA OUT
#define PARAMETER_1 DATA_OUT_1			//DATA OUT
#define PARAMETER_2 DATA_OUT_2				//DATA OUT
#define PARAMETER_3 DATA_OUT_3			//DATA OUT
#define PARAMETER_4 DATA_OUT_4					//DATA OUT
#define PARAMETER_5 DATA_OUT_5				//DATA OUT
#define PARAMETER_6 DATA_OUT_6		//DATA OUT
#define PARAMETER_7 DATA_OUT_7				//DATA OUT
#define PARAMETER_8 DATA_OUT_8				//DATA OUT
#define PARAMETER_9 DATA_OUT_9				//DATA OUT

#define SALIDA_AUX_0 DATA_IN_11
#define SALIDA_AUX_1 DATA_IN_12
#define SALIDA_AUX_2 DATA_IN_13
#define SALIDA_AUX_3 DATA_IN_14
#define SALIDA_AUX_4 DATA_IN_15


// Entradas y salidas... lo dejo asi para que sea facil agregar mas si hace falta
#define DATA_IN_0 0x00
#define DATA_IN_1 0x10
#define DATA_IN_2 0x20
#define DATA_IN_3 0x30
#define DATA_IN_4 0x40
#define DATA_IN_5 0x50
#define DATA_IN_6 0x60
#define DATA_IN_7 0x70
#define DATA_IN_8 0x80
#define DATA_IN_9 0x90
#define DATA_IN_10 0xA0
#define DATA_IN_11 0xB0
#define DATA_IN_12 0xC0
#define DATA_IN_13 0xD0
#define DATA_IN_14 0xE0
#define DATA_IN_15 0xF0

#define DATA_OUT_0 0x01
#define DATA_OUT_1 0x11
#define DATA_OUT_2 0x21
#define DATA_OUT_3 0x31
#define DATA_OUT_4 0x41
#define DATA_OUT_5 0x51
#define DATA_OUT_6 0x61
#define DATA_OUT_7 0x71
#define DATA_OUT_8 0x81
#define DATA_OUT_9 0x91
#define DATA_OUT_10 0xA1
#define DATA_OUT_11 0xB1
#define DATA_OUT_12 0xC1
#define DATA_OUT_13 0xD1
#define DATA_OUT_14 0xE1
#define DATA_OUT_15 0xF1

// Limites de parametros reconfigurables
#define MAX_FREC_CLK 65
#define MIN_FREC_CLK 1

// Tamaño del buffer de muestras crudas
#define BUFFER_SIZE_RAW 2048
