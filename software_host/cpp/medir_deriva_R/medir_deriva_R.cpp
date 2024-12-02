

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

#include "../fpga_driver/FPGA_de1soc.h"


using namespace std;


int main(int argc, char *argv[])
{
	///// ================================================================================= /////
	///// ============================ Seteo de parámetros ================================ /////
	///// ================================================================================= /////

 	int minutos = 30;  // Cambia este valor a la duración que desees
	string nombre_archivo_salida = "deriva_R.txt";	

	if(argc>2){
		minutos = atoi(argv[1]);
		nombre_archivo_salida = argv[2];
	}
	else if(argc>1){
		minutos = atoi(argv[1]);
	}
	// Definir el número de minutos
   



	/////// ========================== Parametros obligatorios ===================================== /////
    int sim_noise = 0;
    int N = 50000;
    int f = 100000;
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
	std::vector<int> t_values;
    std::vector<double> R_values;
	std::vector<double> PHI_values;


    // Calcular el número total de segundos
    int total_segundos = minutos * 60 * 2;
	
	///// ================================================================================= /////
	///// ============================ Calculos =========================================== /////
	///// ================================================================================= /////

	std::cout << "Iniciando medidas... " << std::endl;


	for (int i = 0; i < total_segundos; ++i) 
	{		
		fpga.Reiniciar();
		fpga.Comenzar();

		/////// ========================== Resultados LI ===================================== /////
		std::cout << "\nResultados LI: " << std::endl;

		long long int X_li = fpga.leer_resultado_64_bit(0);
		long long int Y_li = fpga.leer_resultado_64_bit(1);
		int div_li = fpga.get_output_auxiliar(0);

		std::cout << "X: " << X_li << std::endl << "Y: " << Y_li << std::endl;

		FPGA_de1soc::resultados results_li;
		if(corregir_fase)
		{
			results_li = FPGA_de1soc::get_resultados_from_xy (X_li,Y_li,div_li,Covertir2volt,f,f_clk);
		}
		else
		{
			results_li = FPGA_de1soc::get_resultados_from_xy (X_li,Y_li,div_li,Covertir2volt);
		}

		std::cout << "r = " << results_li.r * 1000 << std::endl;
		std::cout << "phi = " << results_li.phi << std::endl;

		R_values.push_back(results_li.r * 1000 ); 
		PHI_values.push_back(results_li.phi); 
		t_values.push_back(i);

		//std::this_thread::sleep_for(std::chrono::milliseconds(500));
	
	}	
	

	///// ================================================================================= /////
	///// ============================ Archivo salida ===================================== /////
	///// ================================================================================= /////

	ofstream archivo_salida(nombre_archivo_salida);
	if (!archivo_salida.is_open()) {
		cerr << "Error al abrir el archivo de salida." << endl;
		return 1;
	}

	for (size_t i = 0; i < t_values.size(); ++i) 
	{
       	archivo_salida << t_values[i] * 0.5 << " s: " << R_values[i] << std::endl;
    }

	// Cierra el archivo de salida
	archivo_salida.close();

	fpga.Terminar();

    return 0;
}


