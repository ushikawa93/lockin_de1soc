/****************************************************************************************
 *  Proyecto:      Control y Lectura de Resultados Lock-in en FPGA
 *  Archivo:       main.c
 *
 *  Descripción:
 *  --------------------------------------------------------------------
 *  Este programa configura y controla el procesamiento lock-in en FPGA.
 *  - Configura el PLL y divisores de clock.
 *  - Define parámetros reconfigurables de procesamiento (M, N_ma, N_ca, N_LI, etc).
 *  - Maneja señales de habilitación, reset y finalización.
 *  - Lee datos desde FIFOs de 32 y 64 bits.
 *  - Calcula resultados de amplitud y fase del lock-in y CA-lockin.
 *
 *  Funciones principales:
 *      - configurar_pll()
 *      - setClockDivider()
 *      - setParam()
 *      - Reset(), setEnable(), waitForFin()
 *      - leer_fifo_32_bit(), leer_fifo_64_bit()
 *      - leer_resultado_64_bit()
 *      - amplitud_lockin(), fase_lockin()
 *
 *  Funciones auxiliares:
 *      - imprimir_buffer_32bit()
 *      - imprimir_buffer_64bit()
 *
 *  Autor:      Matías Oliva
 *  Fecha:      2025
 ****************************************************************************************/


#include <stdio.h>
#include "funciones_pll.h"
#include "parameters_control.h"
#include "system.h"
#include "control_functions.h"
#include "result_functions.h"
#include "lockin_results.h"

void imprimir_buffer_32bit(int N_datos,int* puntero_a_buffer);
void imprimir_buffer_64bit(int N_datos,long long* puntero_a_buffer);

// Punteros a posiciones de memoria que me interesan
int* pll_ptr = (int*)PLL_RECONFIGURAR_BASE;
int* clk_divider_ptr = (int*)DIVISOR_CLOCK_BASE;
int* parameters_ptr = (int*)PARAMETERS_BASE;
int* parameters_1_ptr = (int*)PARAMETERS_1_BASE;
int* parameters_2_ptr = (int*)PARAMETERS_2_BASE;
int* parameters_3_ptr = (int*)PARAMETERS_3_BASE;

int* enable_ptr = (int*)ENABLE_BASE;
int* reset_ptr = (int*) RESET_BASE;
int* finish_ptr = (int*) FINALIZACION_BASE;

int* fifo0_32_bit_ptr = (int*)FIFO0_32_BIT_BASE;
int* result0_32_bit = (int*)RESULT0_32_BIT_BASE;

int* fifo1_32_bit_ptr = (int*)FIFO1_32_BIT_BASE;
int* result1_32_bit = (int*)RESULT1_32_BIT_BASE;

unsigned int* fifo0_64_bit_down_ptr = (unsigned int*)FIFO0_64_BIT_DOWN_BASE;
unsigned int* fifo0_64_bit_up_ptr = (unsigned int*)FIFO0_64_BIT_UP_BASE;
unsigned int* result0_64_bit_down = (unsigned int*)RESULT0_64_BIT_DOWN_BASE;
unsigned int* result0_64_bit_up = (unsigned int*)RESULT0_64_BIT_UP_BASE;

unsigned int* fifo1_64_bit_down_ptr = (unsigned int*)FIFO1_64_BIT_DOWN_BASE;
unsigned int* fifo1_64_bit_up_ptr = (unsigned int*)FIFO1_64_BIT_UP_BASE;
unsigned int* result1_64_bit_down = (unsigned int*)RESULT1_64_BIT_DOWN_BASE;
unsigned int* result1_64_bit_up = (unsigned int*)RESULT1_64_BIT_UP_BASE;

int main()
{
	int M = 32;
	int N_ma = 1;
	int N_ca = 1;
	int N_LI = 1;
	int sim_noise = 6;
	int fuente = 2; //-> 0 adc_2308 // 1 adc_hs // 2 simulacion
	int div = M*N_ma*N_ca;

	int f	= 64;	//En MHZ
	int div_clk = 1; // Si queremos f_muestreo menor a 1MHz
	int pts_to_print = 256;

	configurar_pll(f,pll_ptr);
	setClockDivider(div_clk ,clk_divider_ptr);


	 // Parametros reconfigurables
	 //.parameter_out_0				(fuente_procesamiento), -> 0 adc_2308 // 1 adc_hs // 2 simulacion
	 //.parameter_out_1				(M),
	 //.parameter_out_2				(N_ma),
	 //.parameter_out_3				(N_ca),
	 //.parameter_out_4				(sim_noise),
	 //.parameter_out_9				(led_test),

	setParam(0,fuente,parameters_ptr);
	setParam(1,M,parameters_ptr);
	setParam(2,N_ma,parameters_ptr);
	setParam(3,N_ca,parameters_ptr);
	setParam(4,sim_noise,parameters_ptr);
	setParam(6,N_LI,parameters_ptr);
	setParam(9,0,parameters_ptr);


	Reset(enable_ptr,reset_ptr);
	setEnable(enable_ptr);
	waitForFin(finish_ptr);

	printf("\n\nResultados FIFO 0 32 bits: \n");
	imprimir_buffer_32bit(pts_to_print,leer_fifo_32_bit( fifo0_32_bit_ptr) );

	printf("\n\nResultados FIFO 0 64 bits: \n");
	imprimir_buffer_64bit(pts_to_print,leer_fifo_64_bit(fifo0_64_bit_down_ptr,fifo0_64_bit_up_ptr));

	printf("\n\nResultados FIFO 1 64 bits: \n");
	imprimir_buffer_64bit(pts_to_print,leer_fifo_64_bit(fifo1_64_bit_down_ptr,fifo1_64_bit_up_ptr));
	
	setParam(5,1,parameters_ptr);

	long long salida_fase = leer_resultado_64_bit(fifo0_64_bit_down_ptr,fifo0_64_bit_up_ptr);
	long long salida_cuad = leer_resultado_64_bit(fifo1_64_bit_down_ptr,fifo1_64_bit_up_ptr);

	printf("Resultados Lockin");
	printf("\n\nRes Fase: %lld \nRes Cuad: %lld",salida_fase,salida_cuad);

	float R = amplitud_lockin(salida_fase,salida_cuad,div);
	float phi = fase_lockin(salida_fase,salida_cuad,div);
	printf("\n\nAmplitud: %f \nFase: %f\n\n",R,phi);

	printf("Resultados CA-Lockin");
	setParam(5,0,parameters_ptr);
	salida_fase = leer_resultado_64_bit(fifo0_64_bit_down_ptr,fifo0_64_bit_up_ptr);
	salida_cuad = leer_resultado_64_bit(fifo1_64_bit_down_ptr,fifo1_64_bit_up_ptr);

	printf("\n\nRes Fase: %lld \nRes Cuad: %lld",salida_fase,salida_cuad);

	R = amplitud_lockin(salida_fase,salida_cuad,div);
	phi = fase_lockin(salida_fase,salida_cuad,div);
	printf("\n\nAmplitud: %f \nFase: %f\n\n",R,phi);

	return 0;
}


void imprimir_buffer_32bit(int N_datos,int* puntero_a_buffer){
	for(int i=0;i<N_datos;i++){
		printf("%d, ",(*(puntero_a_buffer+i)));
	}
}

void imprimir_buffer_64bit(int N_datos,long long* puntero_a_buffer){
	for(int i=0;i<N_datos;i++){
		printf("%lld, ",(*(puntero_a_buffer+i)));
	}
}

