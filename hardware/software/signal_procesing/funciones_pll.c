
#include <stdio.h>
#include "funciones_pll.h"

//--------------- Funcion para setear el divisor del reloj -------------------------------//
int setClockDivider (int divisor_deseado,int*clk_divider_addr){
	if( (divisor_deseado > 0) ){
		*clk_divider_addr = divisor_deseado;
	}
	else{
		*clk_divider_addr = 1;
	}
}


//--------------- Funcion para configurar todo abstrayendome de como se hace -------------------------------//
double configurar_pll(int frec_deseada,int*pll_reconfig){
	struct Pll_parameters pll = calculatePll_parameters(frec_deseada,50);

	setM(pll.M,pll_reconfig);
	setN(pll.N,pll_reconfig);
	setC(pll.C,0,pll_reconfig);

	return (double)50 * (double)pll.M/((double)pll.N*(double)pll.C);

}


//--------------- Funciones para cambiar parametros del PLL -------------------------------//
//-------------------- Fout = M/ (N*C0) * Fin ---------------------------------------------//

void setM(int M,int*pll_reconfig){

	// El PLL tiene el divisor del VCO activado (divide en dos la salida del fvco y no se como sacarlo)
	// por eso le mando M a el high_count y el low count!
	int low_count = M;
	int high_count = M;

	int code_mult = ((high_count & 0b11111111) << 8) | (low_count & 0b11111111);

	*(pll_reconfig) = 1;						//1:Polling mode 0:WaitRequestMode
	*(pll_reconfig + 4) = code_mult;

	*(pll_reconfig + 2) = 1;					//Start register
	while(*(pll_reconfig+1) == 0) {}			//Status reg -> 0:busy; 1:ready
	*(pll_reconfig + 2) = 0;					//Stop register

}

void setN(int N,int*pll_reconfig){
	// El PLL tiene el divisor del VCO activado (divide en dos la salida del fvco y no se como sacarlo)
	// por eso le mando M a el high_count y el low count!
	int low_count = N;
	int high_count = N;

	int code_div = ((high_count & 0b11111111) << 8) | (low_count & 0b11111111);

	*(pll_reconfig) = 1;						//1:Polling mode 0:WaitRequestMode
	*(pll_reconfig + 3) = code_div;

	*(pll_reconfig + 2) = 1;					//Start register
	while(*(pll_reconfig+1) == 0) {}			//Status reg -> 0:busy; 1:ready
	*(pll_reconfig + 2) = 0;					//Stop register

}

void setC(int C, int counter_number,int*pll_reconfig){

	int low_count;
	int high_count;

	if(C%2==0){
		low_count = C/2;
		high_count = C/2;
	}
	else
	{
		low_count = C/2+1;
		high_count = C/2;
	}

	int c_address = counter_number;

	int code_pll = ((c_address & 0b11111) << 18) | ((high_count & 0b11111111) << 8) | (low_count & 0b11111111);

	*(pll_reconfig) = 1;						//1:Polling mode 0:WaitRequestMode
	*(pll_reconfig + 5) = (code_pll);

	*(pll_reconfig + 2) = 1;					//Start register
	while(*(pll_reconfig+1) == 0) {}			//Status reg -> 0:busy; 1:ready
	*(pll_reconfig + 2) = 0;					//Stop register
}



void setMNC(int M, int N, int C, int counter_number, int* pll_reconfig)
{
	// El PLL tiene el divisor del VCO activado (divide en dos la salida del fvco y no se como sacarlo)
		// por eso le mando M a el high_count y el low count!
		int low_count = M;
		int high_count = M;

		int code_mult = ((high_count & 0b11111111) << 8) | (low_count & 0b11111111);

		low_count = N;
		high_count = N;

		int code_div = ((high_count & 0b11111111) << 8) | (low_count & 0b11111111);

		if(C%2==0){
			low_count = C/2;
			high_count = C/2;
		}
		else
		{
			low_count = C/2+1;
			high_count = C/2;
		}

		int c_address = counter_number;

		int code_pll = ((c_address & 0b11111) << 18) | ((high_count & 0b11111111) << 8) | (low_count & 0b11111111);

		*(pll_reconfig) = 1;						//1:Polling mode 0:WaitRequestMode
		*(pll_reconfig + 3) = code_div;
		*(pll_reconfig + 4) = code_mult;
		*(pll_reconfig + 5) = code_pll;

		*(pll_reconfig + 2) = 1;					//Start register
		while(*(pll_reconfig+1) == 0) {}			//Status reg -> 0:busy; 1:ready
		*(pll_reconfig + 2) = 0;					//Stop register

}

//--------------- Funcion para calcular parametros del PLL segun f_deseada -------------------------------//
//------------------------------- Fout = M/ (N*C0) * Fin -------------------------------------------------//
//--------------- Asegura que -> fvco = (fin * M/N) este en rango -> [300;1600]MHz -----------------------//
//--------------- Asegura que -> fpfd = fin/N este en rango -> [5;325]MHz --------------------------------//

struct Pll_parameters calculatePll_parameters(int frec_deseada,int frec_referencia){

	struct Pll_parameters pll;

	double frec_normalizada = (double)frec_deseada / (double)frec_referencia;

	double vco_out=6;
	double min_dif=1;
	double vco_out_final=6;
	double C_posible;

	while(vco_out<=30)
	{
		C_posible = vco_out/frec_normalizada;
		if( C_posible - ((int)C_posible) == 0)
		{
			pll.C = C_posible;
			vco_out_final=vco_out;
			break;
		}
		else
		{
			int C_posible_redondeado = (int)C_posible;
			double dif = C_posible - C_posible_redondeado;
			if(dif<min_dif){
				pll.C=C_posible_redondeado;
				min_dif=dif;
				vco_out_final=vco_out;
			}
		}
		vco_out=vco_out+0.5;

	}
	if( vco_out_final - (int)vco_out_final ==0){
		pll.M=vco_out_final;
		pll.N=1;
	}
	else
	{
		pll.M=2*vco_out_final;
		pll.N=2;
	}

	return pll;
}
