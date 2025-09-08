/*
================================================================================
 Módulo de parámetros configurables
 Archivo: parametros.h
--------------------------------------------------------------------------------
 Este archivo define un conjunto de macros y funciones para vincular los 
 parámetros de configuración del sistema con las señales de entrada/salida 
 (I/O) expuestas por el módulo `mmaped_macros.h`.

 Funcionalidad principal:
   - Asociar parámetros lógicos a direcciones físicas de I/O.
   - Proveer funciones para setear y leer parámetros de manera directa.
   - Simplificar la reconfiguración en tiempo real desde software.

 Definiciones incluidas:
   - PARAMETRO_OUT_[0..10]: parámetros de salida (DATA_OUT).
   - PARAMETRO_IN_[0..4]: parámetros de entrada (DATA_IN).

 Funciones disponibles:
   - setParam(parametro, value, addr): escribe un valor en un parámetro.
   - setParamN(...): versiones simplificadas para parámetros 0 a 10.
   - getParamN(...): versiones simplificadas para parámetros de entrada 0 a 4.

 Uso típico:
   - Llamar a setParamX(valor, base_addr) para configurar un parámetro.
   - Llamar a getParamX(base_addr) para leer un parámetro de entrada.

 Ejemplo:
   setParam3(42, parameters_addr);   // Configura el parámetro OUT_3 con valor 42
   int val = getParam1(parameters_addr); // Lee el parámetro IN_1

================================================================================
*/


#include "mmaped_macros.h"

// Aca conecto los parametros que quiero controlar a las I/O del mmaped
#define PARAMETRO_OUT_0 DATA_OUT_0				//DATA OUT
#define PARAMETRO_OUT_1 DATA_OUT_1			//DATA OUT
#define PARAMETRO_OUT_2 DATA_OUT_2				//DATA OUT
#define PARAMETRO_OUT_3 DATA_OUT_3		//DATA OUT
#define PARAMETRO_OUT_4 DATA_OUT_4				//DATA OUT
#define PARAMETRO_OUT_5 DATA_OUT_5				//DATA OUT
#define PARAMETRO_OUT_6 DATA_OUT_6			//DATA OUT
#define PARAMETRO_OUT_7 DATA_OUT_7				//DATA OUT
#define PARAMETRO_OUT_8	DATA_OUT_8				//DATA OUT
#define PARAMETRO_OUT_9	DATA_OUT_9				//DATA OUT
#define PARAMETRO_OUT_10 DATA_OUT_10				//DATA OUT

#define PARAMETRO_IN_0 DATA_IN_11		//DATA IN
#define PARAMETRO_IN_1 DATA_IN_12		//DATA IN
#define PARAMETRO_IN_2 DATA_IN_13		//DATA IN
#define PARAMETRO_IN_3 DATA_IN_14		//DATA IN
#define PARAMETRO_IN_4 DATA_IN_15		//DATA IN

// Parametros de configuracion

int setParam(int parametro,int value,int* parameters_addr);
int setParam0(int parametro,int* parameters_addr);
int setParam1(int parametro,int* parameters_addr);
int setParam2(int parametro,int* parameters_addr);
int setParam3(int parametro,int* parameters_addr);
int setParam4(int parametro,int* parameters_addr);
int setParam5(int parametro,int* parameters_addr);
int setParam6(int parametro,int* parameters_addr);
int setParam7(int parametro,int* parameters_addr);
int setParam8(int parametro,int* parameters_addr);
int setParam9(int parametro,int* parameters_addr);
int setParam10(int parametro,int* parameters_addr);


int getParam0(int* parameters_addr);
int getParam1(int* parameters_addr);
int getParam2(int* parameters_addr);
int getParam3(int* parameters_addr);
int getParam4(int* parameters_addr);



