

///// ====================== barrido_en_f.cpp ======================================= /////
///// ================================================================================= /////
///// Programa en c++ para testear el lockin a varias frecuencias distintas				 /////
///// ================================================================================= /////
/*
	Debe ejecutarse en el micro de la FPGA, con la sintaxis:
		-> calcular_dep f_clk N fuente f_dac f_inicial f_final f_step nombre_archivo iteraciones sim_noise
		
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

	///// ================================================================================= /////
	///// ============================ Seteo de parámetros ================================ /////
	///// ================================================================================= /////

    // Verificar que se proporcionen los argumentos necesarios
    if ((argc != 11)&&(argc != 13)) {
        cerr << "Uso calcular_dep f_clk N fuente f_dac f_inicial f_final f_step nombre_archivo iteraciones sim_noise [{M modo_referencias}]" << endl;
        return 1;
    }

	/////// ========================== Parametros obligatorios ===================================== /////	

	int f_clk = atoi(argv[1]);
    int N = atoi(argv[2]);
	int fuente = atoi(argv[3]);
	int f_dac = atoi(argv[4]);
	int f_inicial = atoi(argv[5]);
	int f_final = atoi(argv[6]);
	int f_step = atoi(argv[7]);
    string nombre_archivo_salida = argv[8];	
	int iteraciones = atoi(argv[9]);
	int sim_noise = atoi(argv[10]);


	/////// ========================== Parametros opcionales ===================================== /////
	int M = f_clk*1000000 / f_inicial;
	int ref_with_dds_compiler = 1;

	if(argc == 13)
	{
		M = atoi(argv[11]);
		ref_with_dds_compiler = atoi(argv[12]);
	}


	/////// ========================== Parametros fijos ===================================== /////	
	bool Covertir2volt = true;
	int modo = 1;
  

  


	///// ================================================================================= /////
	///// ============================ Configuracion ====================================== /////
	///// ================================================================================= /////

	FPGA_de1soc fpga;	

	std::cout << "Iniciando medidas... " << std::endl;
	

	// Fuente de los datos: --> { ADC_2308 = 0, ADC_HS = 1, SIM = 2  };
	fpga.set_parameter(fuente,0);

	// Puntos por ciclo	
	fpga.set_parameter(M,1);

	// Ciclos de promediacion CALI
	fpga.set_parameter(1,2);	// Largo filtro MA
	fpga.set_parameter(N,3);	// Promediacion coherente

	// Ruido en simulacion
	fpga.set_parameter(sim_noise,4);

	// Modo de procesamiento --> { CALI = 0, LI = 1 };
	fpga.set_parameter(modo,5);
		
	// Ciclos de promediacion LI
	fpga.set_parameter(N,6);
		
	// Modo de generacion de señales --> { LU_Table = 0, DDS_compiler = 1 }
	fpga.set_parameter(ref_with_dds_compiler,9);





	///// ================================================================================= /////
	///// ============================ Calculos =========================================== /////
	///// ================================================================================= /////

	// Definir vectores para almacenar f, r y phi.
    std::vector<double> f_values;
    std::vector<double> mean_r_values;
    std::vector<double> std_r_values;

	double f_real_dac = fpga.setFrecuenciaDAC ( ref_with_dds_compiler, f_dac , f_clk, M);


	for (int f = f_inicial; f < f_final; f=f+f_step)
	{

		// Frecuencias de operacion (referencias dac y clock)
		double f_real_ref = fpga.setFrecuenciaReferencias( ref_with_dds_compiler , f , f_clk , M);
	
		std::cout << "Calculando f: " << f << std::endl;	

		std::vector<double> r_values;

		for(int j = 0; j< iteraciones; j++)
		{
			fpga.Reiniciar();
			fpga.Comenzar();

			long long int X_li = fpga.leer_resultado_64_bit(0);//std::cout << "tick: " << std::endl;
			long long int Y_li = fpga.leer_resultado_64_bit(1);//std::cout << "tick: " << std::endl;
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


		f_values.push_back(f_real_ref);
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
	archivo_salida << "DEP -> f_inicial:" << f_inicial << ", f_final:" << f_final;
	archivo_salida << "Parametros -> Fuente: " << fuente << ", Ruido:" << sim_noise << ", Frec clk: " << f_clk << ", Iteraciones: " << iteraciones << endl;
	archivo_salida << "Formato -> f,mean_r,std_r" << endl << endl;
	
	for (size_t i = 0; i < mean_r_values.size(); ++i) 
	{
       	archivo_salida << f_values[i] << "," << mean_r_values[i] << "," << std_r_values[i] << std::endl;
    }

	// Cierra el archivo de salida
	archivo_salida.close();

    return 0;
}


