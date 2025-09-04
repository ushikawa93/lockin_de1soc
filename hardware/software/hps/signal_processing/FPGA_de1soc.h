/*
================================================================================
 Clase de control avanzada de la FPGA DE1-SoC
 Archivo: FPGA_de1soc.h
--------------------------------------------------------------------------------
 Esta clase encapsula el manejo completo de la FPGA, incluyendo:
   - Control de parámetros configurables (DATA_OUT) y lectura de resultados (DATA_IN).
   - Manejo de FIFOs de 32 y 64 bits.
   - Configuración de la frecuencia de muestreo y el PLL interno.
   - Secuencias de inicio, cálculo y finalización de operaciones.
   - Conversión de valores de ADC a voltaje.

Funcionalidad principal:
   - Inicializar la FPGA con parámetros por defecto.
   - Setear parámetros de forma individual o masiva.
   - Configurar reloj y divisor de clock.
   - Iniciar, calcular y terminar operaciones.
   - Leer resultados desde FIFOs o registros instantáneos (32/64 bits).

Definiciones incluidas:
   - FIFO y buffers locales de 32 y 64 bits.
   - Arreglo de parámetros y macros de salida.
   - Métodos privados para control de flujo (Iniciar, Reset, Esperar).
   - Métodos públicos para control de la FPGA, parámetros y resultados.

Funciones disponibles:
   - Comenzar(), Calcular(), Terminar(): secuencias de control de la FPGA.
   - set_parameter(index, value): configura un parámetro individual.
   - set_N_parametros(N, array): configura varios parámetros a la vez.
   - set_frec_clk(value), set_divisor_clock(value), set_clk_from_frec(value): control de reloj.
   - get_parameter(index): consulta valor de un parámetro.
   - leer_FIFO_32_bit(fifo), leer_resultado_32_bit(fifo): lectura de datos de 32 bits.
   - leer_FIFO_64_bit(fifo), leer_resultado_64_bit(fifo): lectura de datos de 64 bits.

Uso típico:
   FPGA_de1soc fpga;
   fpga.set_parameter(3, 42);           // Configura parámetro OUT_3
   fpga.set_clk_from_frec(1000000);     // Ajusta frecuencia de muestreo a 1 MHz
   fpga.Comenzar();                      // Inicia operación
   fpga.Calcular();                      // Espera a que finalice el cálculo
   int val = fpga.leer_resultado_32_bit(0);  // Lee resultado FIFO 0 32 bits

================================================================================
*/


#include "FPGA_IO_simple.h"
#include "FPGA_macros.h"
#include <cstdlib>
#include <cmath>

//using namespace std;

class FPGA_de1soc {

	private:
	
		// Arreglos con los datos
		int fifo0_32_bit[BUFFER_SIZE_RAW];	
		int fifo1_32_bit[BUFFER_SIZE_RAW];	

		long long fifo0_64_bit[BUFFER_SIZE_RAW];
		long long fifo1_64_bit[BUFFER_SIZE_RAW];

		int parameters [N_parametros];
		int PARAM_MACROS_ARRAY [10] = {PARAMETER_0,PARAMETER_1,PARAMETER_2,PARAMETER_3,PARAMETER_4,PARAMETER_5,PARAMETER_6,PARAMETER_7,PARAMETER_8,PARAMETER_9};

		int frec_clk,div_clk;
		bool calculos_disponibles;
		FPGA_IO_simple fpga;

		//--------------- Funciones de control -------------------------------//
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
		
		// Funcion para transformar "cuentas" del ADC en valores de tensión
		double toVolt_ADC_HS(double tension)
        {
            double factor_conversion_a_volt = 1.93/(7423); //Medido con osciloscopio				
            return tension * factor_conversion_a_volt;            
        }       
		
		
	public:	

		//--------------- Funciones de control -------------------------------//
		void Comenzar()
		{
			Reset();	
			Iniciar();
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


		//--------------- Funciones de parámetros -------------------------------//
		// Inicializo la FPGA con 0s por defecto:
		
		FPGA_de1soc(){
			int zero_arr[N_parametros] = { 0 }; 
			set_N_parametros (N_parametros , zero_arr ); 	
			calculos_disponibles=false;	
		}
		
		void set_N_parametros (int N, int* paramters_array)
		{
			for (int i = 0; i< N; i++)
			{
				set_parameter( *(paramters_array + i) , i  );
			}
		}


		// Setters de cada parametro configurable de la FPGA	
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

		void set_frec_clk (int frec_clk_i) 
		{
			frec_clk=frec_clk_i;
			fpga.ConfigurarPll ( frec_clk );	
		}

		void set_divisor_clock (int div_clk_i) 
		{
			div_clk=div_clk_i;
			fpga.WriteFPGA ( DIVISOR_CLOCK_BASE, 0,  div_clk );	
		}

		
		// Setea la frec de muestreo (cambia frec_clk y divisor del clock)
		// es medio bruto el algoritmo asi, estaria bueno optimizarlo un poco
		void set_clk_from_frec (int frecuencia)
		{
			double frec,divisor;
			
			double min_divisor=1;
			double max_divisor=100000;
			
			double min_error = 10000000;
            double frec_final = 1;
			double divisor_final = 1;
			int ready_flag = 0;
			
			for (frec = 1; frec <= 65; frec = frec + 1)
            {
				for(divisor = min_divisor; divisor <= max_divisor; divisor++)
				{
					double error = std::abs(frecuencia - frec * 1000000 / (divisor));
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

		// Geters para que el programa ppal consulte el estado de la FPGA	
		int get_parameter(int parameter_index)
		{
			return (parameters[parameter_index]);
		}

		//------------------------ Funciones de resultados -------------------------------//
		// Devuelve un puntero al arreglo que tiene guardado los datos de los FIFO de 32 bits
		int * leer_FIFO_32_bit(int fifo)
		{			
			if(calculos_disponibles)
			{
				int indice;
				for(indice=0; indice < BUFFER_SIZE_RAW; indice++)
				{
					if(fifo==0)
					{
						int sample = (int)fpga.ReadFPGA( FIFO0_32_BIT_BASE,0 );
						fifo0_32_bit[indice] = sample;	
					}
					else if(fifo=1)
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
			}
			return 0;		
		}		

		int leer_resultado_32_bit(int fifo)
		{
			if(calculos_disponibles){
				if(fifo == 0)
				{
					return (int)fpga.ReadFPGA( FIFO0_32_BIT_BASE,0 );
				}
				else
				{
					return (int)fpga.ReadFPGA( FIFO1_32_BIT_BASE,0 );
				}
				
			}
			return 0;			
		}


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

		long long leer_resultado_64_bit(int fifo)
		{
			if(calculos_disponibles)
			{
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
			return 0;
		}

};
