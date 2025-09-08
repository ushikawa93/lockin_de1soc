/*
================================================================================
 Módulo de funciones de resultados
 Archivo: result_functions.h
--------------------------------------------------------------------------------
 Este archivo define un conjunto de funciones para acceder a los resultados 
 generados por el procesamiento en hardware. Se incluyen métodos para leer 
 datos desde FIFOs y desde registros de salida instantáneos.

 Funcionalidad principal:
   - Lectura de resultados de 32 bits desde FIFO.
   - Lectura de resultados de 64 bits desde FIFO.
   - Lectura directa de resultados instantáneos de 32 y 64 bits.

 Consideraciones:
   - Todas las funciones requieren que la señal de finalización (done) esté en 1
     antes de iniciar la lectura.
   - Los resultados se almacenan en buffers estáticos internos a cada función.

 Funciones disponibles:
   - leer_fifo_32_bit(addr): devuelve un puntero a un arreglo con 2048 resultados.
   - leer_fifo_64_bit(addr_low, addr_high): devuelve puntero a 2048 resultados 
     de 64 bits.
   - leer_resultado_32_bit(addr): lee un valor único de 32 bits.
   - leer_resultado_64_bit(addr_low, addr_high): lee un valor único de 64 bits.

 Uso típico:
   - int* datos32 = leer_fifo_32_bit(fifo_addr);
   - long long* datos64 = leer_fifo_64_bit(fifo_low, fifo_high);
   - int val32 = leer_resultado_32_bit(pio_addr);
   - long long val64 = leer_resultado_64_bit(pio_low, pio_high);

================================================================================
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

long long* leer_fifo_64_bit(unsigned int* fifo_down_addr,unsigned int* fifo_up_addr)
{
	long unsigned res_low,res_up;

	static long long resultados [2048] ;
	for(int i=0;i<2048;i++)
	{
		res_low = *(fifo_down_addr);
		res_up = *(fifo_up_addr);
		resultados[i] = (((long long) res_up ) << 32 )| res_low;

	}
	return resultados;
}


int leer_resultado_32_bit(int* pio_addr){
	return *pio_addr;
}

long long leer_resultado_64_bit(unsigned int* pio_down_addr,unsigned int* pio_up_addr){
	long unsigned res_low,res_up;
	res_low = *(pio_down_addr);
	res_up = *(pio_up_addr);
	return (((long long) res_up ) << 32 )| res_low;;

}
