
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




