/*
================================================================================
 Módulo de reconfiguración del PLL
 Archivo: PLL.h
--------------------------------------------------------------------------------
 Este archivo define las funciones necesarias para controlar y reconfigurar el
 PLL integrado en el SoC-FPGA. Permite ajustar la frecuencia de salida en tiempo
 de ejecución a partir de una frecuencia de referencia conocida.

 Elementos principales:
 
   **Estructura Pll_parameters:**
     - Contiene los valores M, N y C que definen la relación de división/multiplicación.
     - Fórmula base: Fout = (M / (N * C0)) * Fin

   **Funciones de configuración directa:**
     - configurar_pll(): función de alto nivel que recibe la frecuencia deseada 
       en MHz y calcula automáticamente los parámetros necesarios.
     - setClockDivider(): configura un divisor externo de clock.

   **Funciones de bajo nivel (parámetros internos del PLL):**
     - setM(), setN(), setC(): setean individualmente cada parámetro.
     - setMNC(): permite setear M, N y C al mismo tiempo.
     
   **Cálculo automático de parámetros:**
     - calculatePll_parameters(): obtiene M, N y C adecuados según la frecuencia 
       deseada y la de referencia, asegurando que:
         - fvco = (Fin * M / N) ? [300, 1600] MHz
         - fpfd = (Fin / N) ? [5, 325] MHz

 Uso recomendado:
   - Llamar a configurar_pll(frec_deseada, *pll_reconfig) para ajustar el PLL 
     sin preocuparse por los detalles internos. El segundo parámetro es un puntero
     a la dirección de memoria donde esta el pll

================================================================================
*/


class PLL
{
	private:
		void setM(int M, volatile unsigned long* pll_reconfig);
		void setN(int N, volatile unsigned long* pll_reconfig);
		void setC(int C,int counter_number, volatile unsigned long* pll_reconfig);
		void setMNC(int M, int N, int C, int counter_number, volatile unsigned long* pll_reconfig);
		struct Pll_parameters{ int M, N, C;};
		struct Pll_parameters calculatePll_parameters(int frec_deseada,int frec_referencia);
		
	public:
		double configurar_pll(int frec_deseada,volatile unsigned long* pll_reconfig);
};


//--------------- Funcion para configurar todo abstrayendome de como se hace -------------------------------//
//---------- Solo recibe la frecuencia deseada, y un puntero adonde estan los parametros del PLL -----------//

double PLL::configurar_pll(int frec_deseada,volatile unsigned long*pll_reconfig){

	struct Pll_parameters pll = calculatePll_parameters(frec_deseada,50);

	setM(pll.M,pll_reconfig);
	setN(pll.N,pll_reconfig);
	setC(pll.C,0,pll_reconfig);

	// Devuelvo la frecuencia lograda (no siempre es exactamente la que quiero)
	return (double)50 * (double)pll.M/((double)pll.N*(double)pll.C);

}


//--------------- Funciones para cambiar parametros del PLL -------------------------------//
//-------------------- Fout = M/ (N*C0) * Fin ---------------------------------------------//

void PLL::setM(int M,volatile unsigned long*pll_reconfig){

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

void PLL::setN(int N,volatile unsigned long*pll_reconfig){
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

void PLL::setC(int C, int counter_number,volatile unsigned long*pll_reconfig){

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



void PLL::setMNC(int M, int N, int C, int counter_number, volatile unsigned long* pll_reconfig)
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

struct PLL::Pll_parameters PLL::calculatePll_parameters(int frec_deseada,int frec_referencia){

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
