/*
================================================================================
 Módulo de cálculo de resultados Lock-in
 Archivo: lockin_results.h
--------------------------------------------------------------------------------
 Este archivo define funciones para calcular amplitud y fase de una señal a 
 partir de las componentes en cuadratura (X e Y) obtenidas del lock-in digital.

 Funcionalidad principal:
   - Normalización de resultados dividiendo por un factor de escala.
   - Cálculo de amplitud normalizada respecto a una referencia.
   - Cálculo de fase en grados a partir de atan(Y/X).

 Parámetros clave:
   - amplitud_ref: constante de referencia usada para normalizar amplitud.
   - div: factor de escala que depende de M, N_LIA y N_PROMC.

 Funciones disponibles:
   - amplitud_lockin(X, Y, div): devuelve la amplitud normalizada.
   - fase_lockin(X, Y, div): devuelve la fase en grados.

 Fórmulas:
   - Amplitud = 2 * sqrt((X/div)² + (Y/div)²) / amplitud_ref
   - Fase     = atan(Y/X) * (180 / π)

 Ejemplo de uso:
   div = M * N_LIA * N_PROMC;
   long long X = leer_resultado_64_bit(result0_64_bit_down, result0_64_bit_up);
   long long Y = leer_resultado_64_bit(result1_64_bit_down, result1_64_bit_up);

   printf("Amplitud: %f\n", amplitud_lockin(X, Y, div));
   printf("Fase: %f\n", fase_lockin(X, Y, div));

================================================================================
*/

#include "math.h"
int amplitud_ref = 32767;


float amplitud_lockin(long long X, long long Y,int div){
	long double X_1= X/div;
	long double Y_1= Y/div;
	return sqrt(X_1*X_1+Y_1*Y_1)*2/amplitud_ref;
}

float fase_lockin(long long X, long long Y,int div){
	long double X_1= X/div;
	long double Y_1= Y/div;
	return (atan(Y_1/X_1))*180/3.1415;

}

