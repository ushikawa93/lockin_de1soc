///// ============================================================================================== /////
///// ========================== Barrido de constantes de tiempo (Lock-In) ========================== /////
///// ============================================================================================== /////
//
// Programa en C++ para ejecutar en el micro de la FPGA DE1-SoC.
// Realiza un barrido sobre distintos valores de N (constante de tiempo del lock-in)
// con el fin de estimar el nivel de ruido resultante.
//
// Funcionalidad principal:
//   • Configura la FPGA con parámetros de frecuencia, fuente de datos y modo de referencia.
//   • Para cada N entre N_inicial y N_final, ejecuta múltiples iteraciones del lock-in.
//   • Calcula la media y desviación estándar de la amplitud (r).
//   • Guarda los resultados en un archivo de salida con formato CSV.
//
// Uso:
//   ./barrido_cte_tiempo frec N_inicial N_final iteraciones fuente sim_ruido nombre_archivo_salida f_clk [M ref_with_dds_compiler]
//
// Parámetros clave:
//   frec                -> Frecuencia de referencia (Hz)
//   N_inicial, N_final  -> Rango de barrido en N
//   iteraciones         -> Número de repeticiones por N
//   fuente              -> Fuente de datos {0=ADC_2308, 1=ADC_HS, 2=SIM}
//   sim_ruido           -> Nivel de ruido (si fuente=SIM)
//   nombre_archivo_salida -> Archivo CSV de resultados
//   f_clk               -> Frecuencia de reloj en MHz
//   M, ref_with_dds_compiler (opcionales) -> Configuración fina de la referencia
//
///// ============================================================================================== /////

#include <iostream>
#include <fstream>
#include <string>
#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>
#include <cmath>
#include <vector>
#include <iomanip> 
#include <chrono>
#include <thread>
#include <chrono>

#include "../fpga_driver/FPGA_de1soc.h"

using namespace std;

int main(int argc, char *argv[])
{

	///// ================================================================================= /////
	///// ============================ Seteo de parámetros ================================ /////
	///// ================================================================================= /////

	// Verificar que se proporcionen los argumentos necesarios
    if ((argc != 9) && (argc != 11)) {
        cerr << "Uso barrido_cte_tiempo frec N_inicial N_final iteraciones fuente sim_ruido nombre_archivo_salida f_clk [{M modo_referencias}]" << endl;
        return 1;
    }


	/////// ========================== Parametros obligatorios ===================================== /////	
	int frec = atoi(argv[1]);
	int N_inicial = atoi(argv[2]);
	int N_final = atoi(argv[3]);
	int iteraciones = atoi(argv[4]);
	int fuente = atoi(argv[5]);
	int sim_ruido = atoi(argv[6]);
	string nombre_archivo_salida = argv[7];
	int f_clk =  atoi(argv[8]);

	/////// ========================== Parametros opcionales ===================================== /////
	int M = f_clk*1000000 / frec;
	int ref_with_dds_compiler = 1;

	if(argc == 11)
	{
		M = atoi(argv[9]);
		ref_with_dds_compiler = atoi(argv[10]);
	}

	/////// ========================== Parametros fijos ===================================== /////	
	int modo = 1;
	bool Covertir2volt = true;
 
 


	
	///// ================================================================================= /////
	///// ============================ Configuracion ====================================== /////
	///// ================================================================================= /////

	FPGA_de1soc fpga;	

	std::cout << "Iniciando configuracion... " << std::endl;

	// Frecuencias de operacion (referencias dac y clock)
	double f_real_ref = fpga.setFrecuenciaReferencias( ref_with_dds_compiler , frec , f_clk , M);
	double f_real_dac = fpga.setFrecuenciaDAC ( ref_with_dds_compiler, frec , f_clk, M);

	// Fuente de los datos: --> { ADC_2308 = 0, ADC_HS = 1, SIM = 2  };
	fpga.set_parameter(fuente,0);

	// Puntos por ciclo	
	fpga.set_parameter(M,1);

	// Ruido en simulacion
	fpga.set_parameter(sim_ruido,4);		
		
	// Modo de procesamiento --> { CALI = 0, LI = 1 };
	fpga.set_parameter(modo,5);

	// Modo de generacion de señales --> { LU_Table = 0, DDS_compiler = 1 }
	fpga.set_parameter(ref_with_dds_compiler,9);



	///// ================================================================================= /////
	///// ============================ Calculos =========================================== /////
	///// ================================================================================= /////
	

	// Definir vectores para almacenar f, r y phi.
    std::vector<double> N_values;
    std::vector<double> mean_r_values;
    std::vector<double> std_r_values;

	for (int i = N_inicial; i < N_final; i ++)
	{

		std::cout << "Calculando N: " << i << std::endl;

		// Ciclos de promediacion LI
		fpga.set_parameter(i,6);

		// Ciclos de promediacion CALI
		fpga.set_parameter(1,2);
		fpga.set_parameter(i,3);

		std::vector<double> r_values;

		for(int j = 0; j< iteraciones; j++)
		{
			//std::cout << "tick: " << std::endl;
			fpga.Reiniciar();
			//std::this_thread::sleep_for(std::chrono::milliseconds(10));
			fpga.Comenzar();
			//std::cout << "tick: " << std::endl;

			long long int X_li = fpga.leer_resultado_64_bit(0);//std::cout << "tick: " << std::endl;
			long long int Y_li = fpga.leer_resultado_64_bit(1);//std::cout << "tick: " << std::endl;
			int div_li = fpga.get_output_auxiliar(0);

			FPGA_de1soc::resultados results_li = FPGA_de1soc::get_resultados_from_xy (X_li,Y_li,div_li,Covertir2volt);
			r_values.push_back(results_li.r);
			//std::cout << "tick: " << std::endl;

			fpga.Terminar();

		}

		// Calcular la media
		double sum = 0.0;
		for (double value : r_values)
		{
			sum += value;
		}
		double mean = sum / r_values.size();

		// Calcular la desviación estándar
		double variance = 0.0;
		for (double value : r_values)
		{
			variance += (value - mean) * (value - mean);
		}
		double stdev = std::sqrt(variance / r_values.size());


		N_values.push_back(i);
		mean_r_values.push_back(mean);
		std_r_values.push_back(stdev);

	}




	///// ================================================================================= /////
	///// ============================ Archivo salida ===================================== /////
	///// ================================================================================= /////
	
	// Abre el archivo de salida para escritura
	ofstream archivo_salida(nombre_archivo_salida);
	if (!archivo_salida.is_open()) {
		cerr << "Error al abrir el archivo de salida." << endl;
		return 1;
	}
	
	archivo_salida << std::fixed << std::setprecision(12); 

	// Escribe los valores de mean r y std r en el archivo de salida
	archivo_salida << "Barrido de ctes de tiempo -> N_inicial:" << N_inicial << ", N_final:" << N_final;
	archivo_salida << "Parametros -> f: " << f_real_ref << ",	Fuente: " << fuente << ", Ruido:" << sim_ruido << ", Frec clk: " << f_clk << ", Iteraciones: " << iteraciones << endl;
	archivo_salida << "Formato -> N,mean_r,std_r" << endl << endl;
	
	for (size_t i = 0; i < mean_r_values.size(); ++i) 
	{
       	archivo_salida << N_values[i] << "," << mean_r_values[i] << "," << std_r_values[i] << std::endl;
    }
		
	// Cierra el archivo de salida
	archivo_salida.close();
	
	return 0;

}


