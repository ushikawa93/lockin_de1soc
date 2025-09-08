"""
************************************************************************************
Módulo: FPGA_macros
Proyecto: LIA Python Interface
Autor: Matías Oliva
Fecha: 2025

Descripción:
------------
Constantes y macros para la interacción con la FPGA DE1-SoC desde Python, incluyendo:
- Direcciones de memoria mapeadas.
- Bases de registros de control y resultados.
- Parámetros configurables y entradas/salidas auxiliares.
- Límites y tamaño de buffers.

Notas:
------
- Ajustar las direcciones y offsets según la FPGA específica y el mapeo de memoria.
- Facilita agregar nuevas entradas, salidas y parámetros.
************************************************************************************
"""

# Macros para interaccion con la FPGA

# Estas son algunos macros que necesito para mapear la FPGA en memoria

ALT_LWFPGASLVS_OFST = 0xff200000
ALT_STM_OFST = 0xfc000000
HW_REGS_BASE = ( ALT_STM_OFST )
HW_REGS_SPAN = ( 0x04000000 )
HW_REGS_MASK = ( HW_REGS_SPAN - 1 )

# Direccion de memoria de la FPGA de todas las cosas que quiero acceder
ENABLE_BASE = 0x42170
RESET_BASE = 0x42180

FINALIZACION_BASE = 0x42160

N_parametros = 40
PARAMETERS_BASE = 0x41800
PARAMETERS_1_BASE = 0x41000
PARAMETERS_2_BASE = 0x40800
PARAMETERS_3_BASE = 0x40000

DIVISOR_CLOCK_BASE = 0x42190
PLL_RECONFIGURAR_BASE = 0x42000

FIFO0_32_BIT_BASE = 0x421a8
FIFO1_32_BIT_BASE = 0x421a0
RESULT0_32_BIT_BASE = 0x42110
RESULT1_32_BIT_BASE = 0x42100

FIFO0_64_BIT_DOWN_BASE = 0x421c0
FIFO0_64_BIT_UP_BASE = 0x421c8
FIFO1_64_BIT_DOWN_BASE = 0x421b0
FIFO1_64_BIT_UP_BASE = 0x421b8

RESULT0_64_BIT_DOWN_BASE = 0x42140
RESULT0_64_BIT_UP_BASE = 0x42150
RESULT1_64_BIT_DOWN_BASE = 0x42120
RESULT1_64_BIT_UP_BASE = 0x42130



# Entradas y salidas... lo dejo asi para que sea facil agregar mas si hace falta
DATA_IN_0 = 0x00
DATA_IN_1 = 0x10
DATA_IN_2 = 0x20
DATA_IN_3 = 0x30
DATA_IN_4 = 0x40
DATA_IN_5 = 0x50
DATA_IN_6 = 0x60
DATA_IN_7 = 0x70
DATA_IN_8 = 0x80
DATA_IN_9 = 0x90
DATA_IN_10 = 0xA0
DATA_IN_11 = 0xB0
DATA_IN_12 = 0xC0
DATA_IN_13 = 0xD0
DATA_IN_14 = 0xE0
DATA_IN_15 = 0xF0

DATA_OUT_0 = 0x01
DATA_OUT_1 = 0x11
DATA_OUT_2 = 0x21
DATA_OUT_3 = 0x31
DATA_OUT_4 = 0x41
DATA_OUT_5 = 0x51
DATA_OUT_6 = 0x61
DATA_OUT_7 = 0x71
DATA_OUT_8 = 0x81
DATA_OUT_9 = 0x91
DATA_OUT_10 = 0xA1
DATA_OUT_11 = 0xB1
DATA_OUT_12 = 0xC1
DATA_OUT_13 = 0xD1
DATA_OUT_14 = 0xE1
DATA_OUT_15 = 0xF1


# Aca conecto los parametros que quiero controlar a las I/O del mmaped
PARAMETER_0 = DATA_OUT_0				
PARAMETER_1 = DATA_OUT_1			
PARAMETER_2 = DATA_OUT_2				
PARAMETER_3 = DATA_OUT_3			
PARAMETER_4 = DATA_OUT_4			
PARAMETER_5 = DATA_OUT_5			
PARAMETER_6 = DATA_OUT_6		
PARAMETER_7 = DATA_OUT_7		
PARAMETER_8 = DATA_OUT_8		
PARAMETER_9 = DATA_OUT_9		

SALIDA_AUX_0 = DATA_IN_10
SALIDA_AUX_1 = DATA_IN_11
SALIDA_AUX_2 = DATA_IN_12
SALIDA_AUX_3 = DATA_IN_13
SALIDA_AUX_4 = DATA_IN_14

# Limites de parametros reconfigurables
MAX_FREC_CLK = 65
MIN_FREC_CLK = 1

# Tamaño del buffer de muestras crudas
BUFFER_SIZE_RAW = 2048
