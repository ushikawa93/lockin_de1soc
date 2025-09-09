///// ============================================================================================== /////
///// =================================== FPGA_de1soc.h / .cpp ===================================== /////
///// ============================================================================================== /////
/////
///// Clase en C++ que implementa la lógica de control de la FPGA DE1-SoC para el lock-in.
/////
///// Objetivo:
/////   • Encapsular el acceso a la FPGA a través de la clase `FPGA_IO_simple`.
/////   • Facilitar el manejo de parámetros, generación de señales, configuración de clocks,
/////     y lectura de resultados sin que el usuario interactúe con registros bajos directamente.
/////
///// Funcionalidad principal:
/////   • Control del flujo de cálculo en la FPGA (iniciar, resetear, esperar, finalizar).
/////   • Configuración de parámetros de operación:
/////        - Selección de fuente de datos.
/////        - Ciclos de promediación.
/////        - Modo de procesamiento (CALI / LI).
/////        - Control de LEDs y salidas auxiliares.
/////   • Manejo de clocks:
/////        - Configuración de frecuencia base (PLL).
/////        - Divisor de clock.
/////        - Compatibilidad con DDS Compiler para generación de referencias y DAC.
/////   • Generación de señales:
/////        - Modo DDS (alta resolución).
/////        - Modo directo por división de clock.
/////   • Lectura de resultados:
/////        - FIFOs de 32 y 64 bits.
/////        - Resultados acumulados X, Y.
/////        - Conversión a módulo/fase (estructura `resultados`).
/////   • Corrección de fase:
/////        - Tabla de desfasajes empírica para cada frecuencia de clock (1–64 MHz).
/////
///// Estructura `resultados`:
/////   - x : componente en fase
/////   - y : componente en cuadratura
/////   - r : amplitud normalizada (o en volt si se solicita)
/////   - phi : fase en grados (con corrección opcional de clock)
/////
///// Notas:
/////   - Se recomienda usar DDS Compiler para generación precisa de señales.
/////   - Los métodos `set_clk_from_frec...` se mantienen por compatibilidad,
/////     pero se consideran obsoletos frente al DDS Compiler.
/////   - La tabla de `get_desfasaje(f_clk)` debe actualizarse si se recalibra
/////     la respuesta analógica del sistema.
/////
///// Dependencias:
/////   - `FPGA_IO_simple.h`
/////   - `FPGA_macros.h`
/////
///// ============================================================================================== /////



#include "FPGA_IO_simple.h"
#include "FPGA_macros.h"
#include <cstdlib>
#include <cmath>

#define amplitud_ref 32767;


//using namespace std;

class FPGA_de1soc {

	///// ================================================================================= /////
	///// ======================= Atributos y funciones privadas ========================== /////
	///// ================================================================================= /////
	private:
	
		/////// ==================== Arreglos con los datos  ==================== /////	

		int fifo0_32_bit[BUFFER_SIZE_RAW];	
		int fifo1_32_bit[BUFFER_SIZE_RAW];	

		long long fifo0_64_bit[BUFFER_SIZE_RAW];
		long long fifo1_64_bit[BUFFER_SIZE_RAW];

		/////// ==================== Arreglos con los parametros  ==================== /////	
		int parameters [N_parametros];
		int PARAM_MACROS_ARRAY [10] = {PARAMETER_0,PARAMETER_1,PARAMETER_2,PARAMETER_3,PARAMETER_4,PARAMETER_5,PARAMETER_6,PARAMETER_7,PARAMETER_8,PARAMETER_9};
		int SALIDAS_AUX_ARRAY [5] = {SALIDA_AUX_0,SALIDA_AUX_1,SALIDA_AUX_2,SALIDA_AUX_3,SALIDA_AUX_4 };

		/////// ==================== Atributos generales  ==================== /////	
		int frec_clk,div_clk;
		bool calculos_disponibles;

		/////// ============ La comunicacion con la fpga esta definida aca abajo  ================ /////	
		FPGA_IO_simple fpga;

		/////// ============ Funciones de control  ================ /////	

		// Funciones para controlar el flujo de datos en la FPGA. Las hago privadas para que
		// el usuario no interactue directamente con ellas
		void Iniciar()
		{
			fpga.WriteFPGA(ENABLE_BASE, 0 , 1);
		}
		void Reset()
		{
			fpga.WriteFPGA(ENABLE_BASE, 0, 0);
			fpga.WriteFPGA(RESET_BASE , 0, 1);
			fpga.WriteFPGA(RESET_BASE , 0, 0);
		}
		void Esperar()
		{
			while (fpga.ReadFPGA(FINALIZACION_BASE,0) == 0){}
		}
		

	///// ================================================================================= /////
	///// ======================= Atributos y funciones publicas ========================== /////
	///// ================================================================================= /////		
	public:	

		
		/////// ===================  Constructor  ================ /////
		/////// ================================================== /////

		// Inicializo la FPGA con 0s por defecto:
		
		FPGA_de1soc(){
			int zero_arr[N_parametros] = { 0 }; 
			set_N_parametros (N_parametros , zero_arr ); 	
			calculos_disponibles=false;	
		}
		
		/////// ============  Funciones de control  ================ /////	
		/////// ==================================================== /////
		
		void Comenzar()
		{
			Iniciar();
		}
		void Reiniciar()
		{
			Reset();
		}
		void Calcular()
		{
			Reset();	
			Iniciar();
			Esperar();
			calculos_disponibles=true;
		}
		void Terminar()
		{
			Reset();
			calculos_disponibles=false;
		}


		
		/////// ============  Funciones de parámetros  ================ /////	
		/////// ======================================================= /////
		
		

		/////// ============  Setters de cada parametro configurable de la FPGA  ================ /////
		void set_parameter(int value,int parameter_index){

			parameters[parameter_index] = value;

			// Cada interfaz parameters recibe hasta 10 parametros, por eso tengo 4 para setear 40 cosas
			if ( (parameter_index >= 0) &&(parameter_index < 10) )
			{				
				fpga.WriteFPGA (PARAMETERS_BASE,PARAM_MACROS_ARRAY[parameter_index],parameters[parameter_index]);
			}
			else if ( (parameter_index >= 10) &&(parameter_index < 20) )
			{
				fpga.WriteFPGA (PARAMETERS_1_BASE,PARAM_MACROS_ARRAY[parameter_index-10],parameters[parameter_index]);
			}
			else if ( (parameter_index >= 20) &&(parameter_index < 30) )
			{
				fpga.WriteFPGA (PARAMETERS_2_BASE,PARAM_MACROS_ARRAY[parameter_index-20],parameters[parameter_index]);
			}
			else if ( (parameter_index >= 30) &&(parameter_index < 40) )
			{
				fpga.WriteFPGA (PARAMETERS_3_BASE,PARAM_MACROS_ARRAY[parameter_index-30],parameters[parameter_index]);
			}
		}


		/////// ============  Setter de muchos parametros juntos  ================ /////
		void set_N_parametros (int N, int* paramters_array)
		{
			for (int i = 0; i< N; i++)
			{
				set_parameter( *(paramters_array + i) , i  );
			}
		}

		/////// ============  Geters para que el programa ppal consulte el estado de la FPGA  ================ /////
		int get_parameter(int parameter_index)
		{
			return (parameters[parameter_index]);
		}

		int get_output_auxiliar(int parameter_index)
		{
			return fpga.ReadFPGA(PARAMETERS_BASE,SALIDAS_AUX_ARRAY[parameter_index]);
		}		

		/////// ============  Controla LED  ================ /////
		void switchLED(int state)
		{
			set_parameter(state,9);
		}



		
		/////// ============  Funciones de clocks  ==================== /////	
		/////// ======================================================= /////

		/////// ============  Setea CLK  ================ /////
		// La frecuencia debe estar en MHz!
		void set_frec_clk (int frec_clk_i) 
		{
			frec_clk=frec_clk_i;
			fpga.ConfigurarPll ( frec_clk );	
		}

		////// ============  Setea div clock  ================ /////
		void set_divisor_clock (int div_clk_i) 
		{
			div_clk=div_clk_i;
			fpga.WriteFPGA ( DIVISOR_CLOCK_BASE, 0,  div_clk );	
		}		



		/////// ============  Funciones de dds compilers  ================ /////	
		/////// ========================================================== /////

		/////// ============  Setea frec de referencias en modo dds  ================ /////
		float set_frec_dds_compiler_ref(float f_deseada,float f_clk)
		{
			int B = 27; // Bits del acumulador de fase
			int delta_phase = f_deseada * pow(2,B)/(f_clk);	// Parametro para el dds compiler!
			// DDS compiler incremento de fase
			set_parameter(delta_phase,7);

			return (f_clk*delta_phase / pow(2,B));
		}

		/////// ============  Setea frec de dac en modo dds  ================ /////
		float set_frec_dds_compiler_dac(float f_deseada,float f_clk)
		{
			int B = 27; // Bits del acumulador de fase
			int delta_phase = f_deseada * pow(2,B)/(f_clk);	// Parametro para el dds compiler!
			// DDS compiler incremento de fase
			set_parameter(delta_phase,8);

			return (f_clk*delta_phase / pow(2,B));
		}





		/////// ============  Funciones de resultados  ================ /////	
		/////// ======================================================= /////

		/////// ============  Estructura resultados  ================ /////
		struct resultados {
        	double x, y, r, phi;
    	};

		/////// ============  Leer FIFOS 32 bits  ================ /////
		// Devuelve un puntero al arreglo que tiene guardado los datos de los FIFO de 32 bits
		int * leer_FIFO_32_bit(int fifo)
		{				
				int indice;
				for(indice=0; indice < BUFFER_SIZE_RAW; indice++)
				{
					if(fifo==0)
					{
						int sample = (int)fpga.ReadFPGA( FIFO0_32_BIT_BASE,0 );
						fifo0_32_bit[indice] = sample;	
					}
					else if(fifo==1)
					{
						int sample = (int)fpga.ReadFPGA( FIFO1_32_BIT_BASE,0 );
						fifo1_32_bit[indice] = sample;	
					}
					
				}
				if(fifo==0)
				{
					return fifo0_32_bit;
				}
				else
				{
					return fifo1_32_bit;
				}
			return 0;		
		}		


		/////// ============  Leer Resultados 32 bits  ================ /////
		int leer_resultado_32_bit(int fifo)
		{
			Esperar();
				if(fifo == 0)
				{
					return (int)fpga.ReadFPGA( RESULT0_32_BIT_BASE,0 );
				}
				else
				{
					return (int)fpga.ReadFPGA( RESULT1_32_BIT_BASE,0 );
				}			
		}

		/////// ============  Leer FIFOS 64 bits  ================ /////
		long long * leer_FIFO_64_bit(int fifo)
		{	
			if(calculos_disponibles)
			{
				int indice;
				for(indice=0; indice < BUFFER_SIZE_RAW; indice++)
				{
					if(fifo==0)
					{
						long long res_up = fpga.ReadFPGA( FIFO0_64_BIT_UP_BASE,0 );		
						long long res_low = fpga.ReadFPGA( FIFO0_64_BIT_DOWN_BASE,0 );			
						fifo0_64_bit[indice] =  (res_up << 32) | res_low ;
					}
					else if(fifo=1)
					{
						long long res_up = fpga.ReadFPGA( FIFO1_64_BIT_UP_BASE,0 );		
						long long res_low = fpga.ReadFPGA( FIFO1_64_BIT_DOWN_BASE,0 );			
						fifo0_64_bit[indice] =  (res_up << 32) | res_low ;
					}
					
				}

				if(fifo==0)
				{
					return fifo0_64_bit;
				}
				else
				{
					return fifo0_64_bit;
				}
			}
			return 0;			
		}		
		
		/////// ============  Leer Resultados 64 bits  ================ /////
		long long leer_resultado_64_bit(int fifo)
		{
			Esperar();
				if(fifo == 0)
				{
					long long res_up = fpga.ReadFPGA( RESULT0_64_BIT_UP_BASE,0 );		
					long long res_low = fpga.ReadFPGA( RESULT0_64_BIT_DOWN_BASE,0 );			
					return (res_up << 32) | res_low ;
				}
				else
				{
					long long res_up = fpga.ReadFPGA( RESULT1_64_BIT_UP_BASE,0 );		
					long long res_low = fpga.ReadFPGA( RESULT1_64_BIT_DOWN_BASE,0 );			
					return (res_up << 32) | res_low ;
				}			
		}

		
		/////// ============  Leer ultimo valor de FIFO 32 bits  ================ /////
		int LeerFIFO32individual(int fifo)
		{
			if(fifo == 0)
			{
				return (int)fpga.ReadFPGA( FIFO0_32_BIT_BASE,0 );
			}
			else
			{
				return (int)fpga.ReadFPGA( FIFO1_32_BIT_BASE,0 );
			}
		}

		/////// ============  Leer ultimo valor de FIFO 64 bits  ================ /////
		long long int LeerFIFO64individual(int fifo)
		{
			if(fifo == 0)
			{
				long long res_up = fpga.ReadFPGA( FIFO0_64_BIT_UP_BASE,0 );		
				long long res_low = fpga.ReadFPGA( FIFO0_64_BIT_DOWN_BASE,0 );			
				return (res_up << 32) | res_low ;
			}
			else
			{
				long long res_up = fpga.ReadFPGA( FIFO1_64_BIT_UP_BASE,0 );		
				long long res_low = fpga.ReadFPGA( FIFO1_64_BIT_DOWN_BASE,0 );			
				return (res_up << 32) | res_low ;
			}
		}






		/////// ============  Funciones de resultados Estaticas  ================ /////	
		/////// ================================================================= /////

		/////// ============  Funcion para transformar "cuentas" del ADC en valores de tensión  ================ /////	
		static double cuentas2volt(double cuentas) 
		{
			double factor = 125e-6;	// Medido empíricamente
			return factor * cuentas;
   		}

		/////// ============  Convierte x,y en objeto de tipo resultados  ================ /////
		static resultados get_resultados_from_xy (long long int X, long long int Y, int div, bool convert2volt)
		{
			resultados result;

			result.x = (double)X / div;
			result.y = (double)Y / div;
			
			result.r = sqrt(pow(result.x, 2) + pow(result.y, 2)) * 2 / amplitud_ref;
			result.phi = atan2(result.y, result.x) * 180 / 3.1415;

			if(convert2volt){
				result.r = cuentas2volt(result.r);
			}

			return result;

		}		

		/////// ============  Convierte x,y en objeto de tipo resultados corrigiendo fase ================ /////
		static resultados get_resultados_from_xy (long long int X, long long int Y, int div, bool convert2volt, int f, int f_clk)
		{
			int M = (double)f_clk*1000000 / f;

			float correccion_fase = get_desfasaje(f_clk) * 360 / (float)M;

			resultados result;

			result.x = (double)X / div;
			result.y = (double)Y / div;
			
			result.r = sqrt(pow(result.x, 2) + pow(result.y, 2)) * 2 / amplitud_ref;
			result.phi = atan2(result.y, result.x) * 180 / 3.1415 - correccion_fase;

			if(convert2volt){
				result.r = cuentas2volt(result.r);
			}

			return result;

		}


		// Medidos empíricamente, es cuantos ciclos de reloj se desfasa la señal para cada frecuencia del clock!
		static double get_desfasaje(int f_clk)
		{
			if (f_clk <1 || f_clk > 64){return 1;}

			double desfasajes [64]= {    0.00021904, -0.000352334, -0.00417584, 0.00825695, 0.0172617, -0.0129016,
										-0.0275598, -0.0446989, 0.0666098, 0.0556357, -0.0625196, -0.0286357,
										-0.0306936, -0.155561, -0.135655, -0.109491, -0.0254541, 0.117017, 0.238627,
										0.186582, 0.0237678, 0.0199821, 0.0302326, 0.0235692, -0.00306756, -0.0516347,
										-0.130975, -0.243543, -0.362178, -0.479231, -0.571257, -0.642422, -0.690277,
										-0.72263, -0.737825, -0.748777, -0.761161, -0.783811, -0.831092, -0.920886,
										-1.03199, -1.08487, -1.05856, -1.00044, -0.960705, -0.944474, -0.943235,
										-0.954533, -0.973869, -0.995993, -1.02962, -1.06285, -1.0985, -1.13623,
										-1.1744, -1.22326, -1.25324, -1.29196, -1.33044, -1.36949, -1.41127,
										-1.45294, -1.47838, -1.50672};
			return desfasajes[f_clk-1];
		}


		


		/////// ============  Funciones de clock a una frecuencia determinada  ================ /////	
		/////// =============================================================================== /////

		// OBSOLETO si genero las ondas sinusoidales con el DDS compliler
		// Setea la frec de la onda sinusoidal generada para el lockin (cambia frec_clk y divisor del clock... necesita saber M)
		// frecuencia debe estar en Hz
		double set_clk_from_frec_and_M (int frecuencia, int M)
		{
			int frec,divisor;
			
			double min_divisor=1;
			double max_divisor=1000;
			
			double min_error = 10000000;
            int frec_final = 1;
			int divisor_final = 1;
			int ready_flag = 0;
			
			for (frec = 1; frec <= 65; frec = frec + 1)
            {
				for(divisor = min_divisor; divisor <= max_divisor; divisor++)
				{
					double error = std::abs(frecuencia - (double)frec * 1000000 / (double)(M*divisor));
					if (error == 0)
					{
						ready_flag=1;
						frec_final = frec;
						divisor_final = divisor;	
						break;						
					}					
					else if (error < min_error)
					{
						min_error = error;
						frec_final = frec;
						divisor_final = divisor;						
					}
				}
				if(ready_flag==1)
				{
					break;
				}
            }
			
			set_frec_clk(frec_final);
			set_divisor_clock(divisor_final);

			return (double)frec_final*1000000/(M*divisor_final);
		}

		// OBSOLETO si genero las ondas sinusoidales con el DDS compliler
		// Setea la frec de muestreo (cambia frec_clk y divisor del clock)
		// frecuencia debe estar en Hz 
		void set_clk_from_frec (int frecuencia)
		{
			int frec,divisor;
			
			double min_divisor=1;
			double max_divisor=1000;
			
			double min_error = 10000000;
            int frec_final = 1;
			int divisor_final = 1;
			int ready_flag = 0;
			
			for (frec = 1; frec <= 65; frec = frec + 1)
            {
				for(divisor = min_divisor; divisor <= max_divisor; divisor++)
				{
					double error = std::abs(frecuencia - (double)frec * 1000000 / (double)(divisor));
					if (error == 0)
					{
						ready_flag=1;
						frec_final = frec;
						divisor_final = divisor;	
						break;						
					}					
					else if (error < min_error)
					{
						min_error = error;
						frec_final = frec;
						divisor_final = divisor;						
					}
				}
				if(ready_flag==1)
				{
					break;
				}
            }
			
			set_frec_clk(frec_final);
			set_divisor_clock(divisor_final);
		}








		/////// ============  Funciones de generacion de señales y manejo de clks ================ /////	
		/////// ================================================================================== /////


		/////// ============  Setea frecuencia de referencias ================ /////		
		// Funciona sin importar como quiera generar las señales DDS o directo con CLK

		double setFrecuenciaReferencias(int metodo, int frecuencia, int f_clk, int M)
		{
			// metodo = 1 es con dds compiler. Sino directamente dvidiendo el clk en M puntos

			if(metodo == 1)
			{
				set_frec_clk(f_clk);
				set_divisor_clock(1);
				return set_frec_dds_compiler_ref(frecuencia,f_clk*1000000);						
			}
			else
			{
				return set_clk_from_frec_and_M(frecuencia,M);
			}
		}

		/////// ============  Setea frecuencia de DAC ================ /////		
		// Funciona sin importar como quiera generar las señales DDS o directo con CLK

		double setFrecuenciaDAC(int metodo, int frecuencia, int f_clk, int M)
		{
			// metodo = 1 es con dds compiler. Sino directamente dvidiendo el clk en M puntos
			// Si metodo == 0 no hay forma de generar un DAC de frecuencia distinta a la referencia
			
			if(metodo == 1)
			{
				set_frec_clk(f_clk);
				set_divisor_clock(1);
				return set_frec_dds_compiler_dac(frecuencia,f_clk*1000000);						
			}
			else
			{
				return set_clk_from_frec_and_M(frecuencia,M);
			}
		}

};
