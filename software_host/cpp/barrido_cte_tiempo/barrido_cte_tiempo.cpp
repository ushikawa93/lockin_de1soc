

///// ====================== barrido_cte_tiempo.cpp ============================================== /////
///// ============================================================================================ /////
///// Programa en c++ para hacer calculos de lock-in con distintos N y estimar el ruido resultante /////
///// ============================================================================================ /////
/*
	Debe ejecutarse en el micro de la FPGA, con la sintaxis:
		-> 
		
*/

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

	// Verificar que se proporcionen los argumentos necesarios
    if (argc != 8) {
        cerr << "Uso barrido_cte_tiempo frec N_inicial N_final iteraciones fuente sim_ruido nombre_archivo_salida" << endl;
        return 1;
    }

	FPGA_de1soc fpga;	

	std::cout << "Iniciando configuracion... " << std::endl;

	int f_clk = 64;
	int frec = atoi(argv[1]);
	int M = f_clk*1000000  / frec;	

	int N_inicial = atoi(argv[2]);
	int N_final = atoi(argv[3]);

	int iteraciones = atoi(argv[4]);
	int fuente = atoi(argv[5]);

	int sim_ruido = atoi(argv[6]);

	string nombre_archivo_salida = argv[7];

	int modo = 1;
	bool Covertir2volt = false;
	
	// Configuracion...
	fpga.set_frec_clk(f_clk);
	double f_real = fpga.set_frec_dds_compiler(frec,f_clk*1000000);	
			
	// Fuente de los datos: --> { ADC_2308 = 0, ADC_HS = 1, SIM = 2  };
	fpga.set_parameter(fuente,0);
			
	// Puntos por ciclo	
	fpga.set_parameter(M,1);			

	// Ruido en simulacion
	fpga.set_parameter(sim_ruido,4);				
		
	// Modo de procesamiento --> { CALI = 0, LI = 1 };
	fpga.set_parameter(modo,5);

	// Definir vectores para almacenar f, r y phi.
    std::vector<double> N_values;
    std::vector<double> mean_r_values;
    std::vector<double> std_r_values;

	for (int i = N_inicial; i < N_final; i ++)
	{
		system("clear");
		std::cout << "Calculando N= " << i << std::endl;

		// Ciclos de promediacion LI
		fpga.set_parameter(i,6);

		std::vector<double> r_values;

		for(int j = 1; j< iteraciones; j++)
		{
			fpga.Reiniciar();
			fpga.Comenzar();

			long long int X_li = fpga.leer_resultado_64_bit(0);
			long long int Y_li = fpga.leer_resultado_64_bit(1);
			int div_li = fpga.get_output_auxiliar(0);

			FPGA_de1soc::resultados results_li = FPGA_de1soc::get_resultados_from_xy (X_li,Y_li,div_li,Covertir2volt);
			r_values.push_back(results_li.r);

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

	// Escribo archivo de salida:
	
		// Abre el archivo de salida para escritura
		ofstream archivo_salida(nombre_archivo_salida);
		if (!archivo_salida.is_open()) {
			cerr << "Error al abrir el archivo de salida." << endl;
			return 1;
		}

	    archivo_salida << std::fixed << std::setprecision(6); 

		// Escribe los valores de mean r y std r en el archivo de salida
		archivo_salida << "Barrido de ctes de tiempo -> N_inicial:" << N_inicial << ", N_final:" << N_final;
		archivo_salida << "Parametros -> f: " << frec << ",	Fuente: " << fuente << ", Ruido:" << sim_ruido << ", Frec clk: " << f_clk << ", Iteraciones: " << iteraciones << endl;
		archivo_salida << "Formato -> N,mean_r,std_r" << endl << endl;

		for (size_t i = 0; i < mean_r_values.size(); ++i) 
		{
        	archivo_salida << N_values[i] << "," << mean_r_values[i] << "," << std_r_values[i] << std::endl;
    	}

		// Cierra el archivo de salida
		archivo_salida.close();
		
}


