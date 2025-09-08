/*
================================================================================
 Módulo: parameters_control.c
--------------------------------------------------------------------------------
 Implementación de funciones para configurar y leer parámetros del sistema a 
 través de la interfaz mapeada en memoria.

 Funcionalidad:
   - Escritura de parámetros OUT[0..10] (valores de salida).
   - Lectura de parámetros IN[0..4] (valores de entrada).
   - Funciones genéricas (setParam) y específicas (setParamN / getParamN).

 Detalles de implementación:
   - Cada parámetro se accede como *(parameters_addr + offset).
   - Los offsets están definidos en "parameters_control.h" vía macros
     asociadas a DATA_OUT_x y DATA_IN_x.

 Funciones principales:
   - int setParam(int parametro, int value, int* parameters_addr)
       Configura el parámetro indicado (0..10) con el valor deseado.

   - int setParamN(int value, int* parameters_addr)
       Configura directamente el parámetro N con el valor especificado.
       (versiones disponibles: 0..10)

   - int getParamN(int* parameters_addr)
       Devuelve el valor leído de un parámetro de entrada.
       (versiones disponibles: 0..4)

 Ejemplo de uso:
   setParam3(42, parameters_addr);   // Configura el parámetro OUT_3
   int val = getParam1(parameters_addr); // Lee el valor del parámetro IN_1

 Notas:
   - La función setParam es útil para código genérico (cuando no se conoce el
     parámetro de antemano).
   - Las funciones setParamN y getParamN son más directas y rápidas.

================================================================================
*/



#include "parameters_control.h"


// Parametros de configuracion
// La base de cada parametro es Parameters + offset de c/u

int setParam(int parametro,int value,int* parameters_addr){
	switch(parametro){
	case 0:
			*(parameters_addr + PARAMETRO_OUT_0) = value;
		break;
	case 1:
			*(parameters_addr + PARAMETRO_OUT_1) = value;
			break;
	case 2:
			*(parameters_addr + PARAMETRO_OUT_2) = value;
			break;
	case 3:
			*(parameters_addr + PARAMETRO_OUT_3) = value;
			break;
	case 4:
			*(parameters_addr + PARAMETRO_OUT_4) = value;
			break;
	case 5:
			*(parameters_addr + PARAMETRO_OUT_5) = value;
			break;
	case 6:
			*(parameters_addr + PARAMETRO_OUT_6) = value;
			break;
	case 7:
			*(parameters_addr + PARAMETRO_OUT_7) = value;
			break;
	case 8:
			*(parameters_addr + PARAMETRO_OUT_8) = value;
			break;
	case 9:
			*(parameters_addr + PARAMETRO_OUT_9) = value;
			break;
	case 10:
			*(parameters_addr + PARAMETRO_OUT_10) = value;
			break;

	}
	return value;
}

int setParam0(int parametro,int* parameters_addr){
	*(parameters_addr + PARAMETRO_OUT_0) = parametro;
	return parametro;
}

int setParam1(int parametro,int* parameters_addr){
	*(parameters_addr + PARAMETRO_OUT_1) = parametro;
	return parametro;
}

int setParam2(int parametro,int* parameters_addr){
	*(parameters_addr + PARAMETRO_OUT_2) = parametro;
	return parametro;
}

int setParam3(int parametro,int* parameters_addr){
	*(parameters_addr + PARAMETRO_OUT_3) = parametro;
	return parametro;
}

int setParam4(int parametro,int* parameters_addr){
	*(parameters_addr + PARAMETRO_OUT_4) = parametro;
	return parametro;
}

int setParam5(int parametro,int* parameters_addr){
	*(parameters_addr + PARAMETRO_OUT_5) = parametro;
	return parametro;
}

int setParam6(int parametro,int* parameters_addr){
	*(parameters_addr + PARAMETRO_OUT_6) = parametro;
	return parametro;
}

int setParam7(int parametro,int* parameters_addr){
	*(parameters_addr + PARAMETRO_OUT_7) = parametro;
	return parametro;
}

int setParam8(int parametro,int* parameters_addr){
	*(parameters_addr + PARAMETRO_OUT_8) = parametro;
	return parametro;
}

int setParam9(int parametro,int* parameters_addr){
	*(parameters_addr + PARAMETRO_OUT_9) = parametro;
	return parametro;
}

int setParam10(int parametro,int* parameters_addr){
	*(parameters_addr + PARAMETRO_OUT_10) = parametro;
	return parametro;
}


int getParam0(int* parameters_addr){
	return *(parameters_addr + PARAMETRO_IN_0);
}

int getParam1(int* parameters_addr){
	return *(parameters_addr + PARAMETRO_IN_1);
}

int getParam2(int* parameters_addr){
	return *(parameters_addr + PARAMETRO_IN_2);
}

int getParam3(int* parameters_addr){
	return *(parameters_addr + PARAMETRO_IN_3);
}

int getParam4(int* parameters_addr){
	return *(parameters_addr + PARAMETRO_IN_4);
}




