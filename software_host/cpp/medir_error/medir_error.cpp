

///// ====================== measure_lockin.cpp ======================================= /////
///// ================================================================================= /////
///// Programa en c++ para setear los parametros de la FPGA y obtener medidas de lockin /////
///// ================================================================================= /////
/*
	Debe ejecutarse en el micro de la FPGA, con la sintaxis:
		-> measure_lockin sim_noise N frecuencia fuente modo nombre_archivo [f_clk corregir_fase](opcional)
		
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
#include <algorithm>
#include <cmath>
#include <numeric> // Para std::accumulate

#include "../fpga_driver/FPGA_de1soc.h"


using namespace std;


int main(int argc, char *argv[])
{
	///// ================================================================================= /////
	///// ============================ Seteo de parámetros ================================ /////
	///// ================================================================================= /////


	string nombre_archivo_salida = "ruido.txt";	
    int N = 50000;
    int iteraciones = 100;
    int f = 100000;

    if(argc>4){
        N = atoi(argv[1]);
        iteraciones = atoi(argv[2]);
		f = atoi(argv[3]);
		nombre_archivo_salida = argv[4];          
    }
	else if(argc>3){
		N = atoi(argv[1]);
        iteraciones = atoi(argv[2]);
		f = atoi(argv[3]);      
	}
    else if(argc>2)
    {
        N = atoi(argv[1]);
		iteraciones = atoi(argv[2]);
    }
	else if(argc>1){
		N = atoi(argv[1]);
	}
  



	/////// ========================== Parametros obligatorios ===================================== /////
    int sim_noise = 0;   
	int fuente = 1;
	int modo = 1;	
	bool corregir_fase = false;
	int f_clk = 20;	// En MHz
	int M = f_clk*1000000 / f;
	int ref_with_dds_compiler = 1; 
	bool Covertir2volt = true;


	///// ================================================================================= /////
	///// ============================ Configuracion ====================================== /////
	///// ================================================================================= /////

	FPGA_de1soc fpga;	

	std::cout << "Iniciando configuracion.. " << std::endl;

	// Frecuencias de operacion (referencias dac y clock)
	double f_real_ref = fpga.setFrecuenciaReferencias( ref_with_dds_compiler , f , f_clk , M);
	double f_real_dac = fpga.setFrecuenciaDAC ( ref_with_dds_compiler, f , f_clk, M);

	// Fuente de los datos: --> { ADC_2308 = 0, ADC_HS = 1, SIM = 2  };
	fpga.set_parameter(fuente,0);
		
	// Puntos por ciclo	
	fpga.set_parameter(M,1);
	
	// Ciclos de promediacion CALI
	fpga.set_parameter(1,2);	// Largo filtro MA
	fpga.set_parameter(N,3);	// Promediacion coherente

	// Ruido en simulacion
	fpga.set_parameter(sim_noise,4);

	// Modo de procesamiento --> { CALI = 0, LI = 1 }; // Primero veo con LI despues con CALI y exporto el que me pide arriba!
	fpga.set_parameter(1,5);
		
	// Ciclos de promediacion LI
	fpga.set_parameter(N,6);		

	// Modo de generacion de señales --> { LU_Table = 0, DDS_compiler = 1 }
	fpga.set_parameter(ref_with_dds_compiler,9);


	// Definir vectores para almacenar R...
    std::vector<double> R_values;

	
	///// ================================================================================= /////
	///// ============================ Calculos =========================================== /////
	///// ================================================================================= /////

	std::cout << "Iniciando medidas... " << std::endl;


	for (int i = 0; i < iteraciones; ++i) 
	{		
		fpga.Reiniciar();
		fpga.Comenzar();

		/////// ========================== Resultados LI ===================================== /////
		//std::cout << "\nResultados LI: " << std::endl;

		long long int X_li = fpga.leer_resultado_64_bit(0);
		long long int Y_li = fpga.leer_resultado_64_bit(1);
		int div_li = fpga.get_output_auxiliar(0);

		//std::cout << "X: " << X_li << std::endl << "Y: " << Y_li << std::endl;

		FPGA_de1soc::resultados results_li;
		if(corregir_fase)
		{
			results_li = FPGA_de1soc::get_resultados_from_xy (X_li,Y_li,div_li,Covertir2volt,f,f_clk);
		}
		else
		{
			results_li = FPGA_de1soc::get_resultados_from_xy (X_li,Y_li,div_li,Covertir2volt);
		}

		//std::cout << "r = " << results_li.r * 1000 << std::endl;
		//std::cout << "phi = " << results_li.phi << std::endl;

		R_values.push_back(results_li.r * 1000 ); 	
	}	

	

	///// ================================================================================= /////
	///// ============================ Archivo salida ===================================== /////
	///// ================================================================================= /////

	ofstream archivo_salida(nombre_archivo_salida);
	if (!archivo_salida.is_open()) {
		cerr << "Error al abrir el archivo de salida." << endl;
		return 1;
	}

	for (size_t i = 0; i < R_values.size(); ++i) 
	{
       	archivo_salida << R_values[i] << ", " ;
    }
    archivo_salida << std::endl;

        // Calcular el máximo y mínimo
    double max_val = *std::max_element(R_values.begin(), R_values.end());
    double min_val = *std::min_element(R_values.begin(), R_values.end());

    // Calcular la media
    double mean = std::accumulate(R_values.begin(), R_values.end(), 0.0) / R_values.size();

    // Calcular la desviación estándar
    double variance = std::accumulate(R_values.begin(), R_values.end(), 0.0,
        [mean](double sum, double val) {
            return sum + (val - mean) * (val - mean);
        }) / R_values.size();
    
    double std_dev = std::sqrt(variance);

    std::cout << std::endl << "Media: " << mean << std::endl;
    std::cout << "Maximo: " << max_val << std::endl;
    std::cout << "Minimo: " << min_val << std::endl;
    std::cout << "Desviacion estandar: " << std_dev << std::endl;

    archivo_salida << std::endl << "Media: " << mean << std::endl;
    archivo_salida << "Maximo: " << max_val << std::endl;
    archivo_salida << "Minimo: " << min_val << std::endl;
    archivo_salida << "Desviacion estandar: " << std_dev << std::endl;

	// Cierra el archivo de salida
	archivo_salida.close();

	fpga.Terminar();

    return 0;
}


