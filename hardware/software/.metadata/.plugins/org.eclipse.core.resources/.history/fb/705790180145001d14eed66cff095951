/*
  result_functions.h

  Define funciones para leer los resultados del procesamiento
  Hay funciones para leer los resultados de los FIFOS de 64 bits y de 32 bits y las salidas instantanteas
  (TODO) Todas requieren que la entrada de finalizacion este en 1

*/


int* leer_fifo_32_bit(int* fifo_addr)
{
	static int resultados [2048] ;
	for(int i=0;i<2048;i++)
	{
		int muestra = *fifo_addr;
		resultados[i] = muestra;
	}
	return resultados;
}

int leer_resultado(int* pio_addr){
	return *pio_addr;
}
