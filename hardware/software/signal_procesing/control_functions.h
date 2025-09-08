/*
================================================================================
 Módulo de funciones de control
 Archivo: control_functions.h
--------------------------------------------------------------------------------
 Este archivo define un conjunto de funciones simples para manejar señales 
 básicas de control en el sistema, sin necesidad de escribir directamente en 
 los registros. 

 Funcionalidad principal:
   - Habilitación y deshabilitación del sistema.
   - Generación de reset controlado.
   - Lectura del estado de finalización de procesos.
   - Espera activa hasta que finalice un procesamiento.

 Funciones disponibles:
   - setEnable(): habilita el sistema.
   - unsetEnable(): deshabilita el sistema.
   - Reset(): aplica un reset breve asegurando la deshabilitación previa.
   - getFin(): devuelve el estado de la señal de finalización.
   - waitForFin(): bloquea la ejecución hasta que se active la señal de fin.

 Uso recomendado:
   - Llamar a setEnable() para iniciar procesamiento.
   - Si es necesario reiniciar, usar Reset().
   - Consultar el avance con getFin() o esperar finalización con waitForFin().

================================================================================
*/


void setEnable(int* enable_ptr){
	*enable_ptr = 1;
}

void unsetEnable(int* enable_ptr){
	*enable_ptr = 0;
}

void Reset(int*enable_ptr,int*reset_ptr){
	*enable_ptr = 0;
	*reset_ptr = 1;
	*reset_ptr = 0;
}

int getFin(int* finish_ptr){
	return *finish_ptr;
}

void waitForFin(int *finish_ptr){
	while (*finish_ptr == 0){}
}

