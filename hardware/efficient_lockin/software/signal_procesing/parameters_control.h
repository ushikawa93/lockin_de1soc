/*****************************************************
 * MACROS PARA MODIFICAR FACIL EL TEMA DE LOS PARAMETROS
*****************************************************/

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



