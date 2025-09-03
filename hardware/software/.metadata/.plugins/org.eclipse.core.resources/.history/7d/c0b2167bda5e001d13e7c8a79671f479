/*
 * lockin_results.h
 *
 *  Funciones para calcular amplitud y fase de una
 *  transferencia a partir del X e Y
 *
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
