/*
 control_functions.h

 Funciones para dar la habilitación y el reset sin tocar los parametros directamente....


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

