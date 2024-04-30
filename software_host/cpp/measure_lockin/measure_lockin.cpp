

///// ====================== measure_lockin.cpp ======================================= /////
///// ================================================================================= /////
///// Programa en c++ para setear los parametros de la FPGA y obtener medidas de lockin /////
///// ================================================================================= /////
/*
	Debe ejecutarse en el micro de la FPGA, con la sintaxis:
		-> measure_lockin  sim_noise | N | frecuencia | fuente | modo | nombre_archivo 
		
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
#include "../fpga_driver/FPGA_de1soc.h"



using namespace std;


int main(int argc, char *argv[])
{
    // Verificar que se proporcionen los argumentos necesarios
    if ((argc != 7)&&(argc != 8) ){
        cerr << "Uso: measure_lockin sim_noise N frecuencia fuente modo nombre_archivo" << endl;
        return 1;
    }

    // Obtener los parámetros de la línea de comandos
    int sim_noise = atoi(argv[1]);
    int N = atoi(argv[2]);
    int f = atoi(argv[3]);
	int fuente = atoi(argv[4]);
	int modo = atoi(argv[5]);
	bool Covertir2volt = true;
    string nombre_archivo_salida = argv[6];
	
	FPGA_de1soc fpga;
	int f_clk = 64;	// En MHz
	int M = f_clk*1000000 / f;	// Ya no cumple muchas funciones...

	if (argc == 8)
	{
		f_clk = atoi(argv[7]);
	}
	
	
	//////////////////////////////////////////////////////////////////////////////////
	/////////////////// =============== Configuracion  ==============/////////////////
	//////////////////////////////////////////////////////////////////////////////////

	std::cout << "Iniciando configuracion.. " << std::endl;
	fpga.set_frec_clk(f_clk);
	double f_real = fpga.set_frec_dds_compiler(f,f_clk*1000000);
	
	// Fuente de los datos: --> { ADC_2308 = 0, ADC_HS = 1, SIM = 2  };
	fpga.set_parameter(fuente,0);
		
	// Puntos por ciclo	
	fpga.set_parameter(M,1);
	
	// Ciclos de promediacion CALI
	fpga.set_parameter(1,2);	// Largo filtro MA
	fpga.set_parameter(N,3);	// Promediacion coherente

	// Ruido en simulacion
	fpga.set_parameter(sim_noise,4);
		
	// Ciclos de promediacion LI
	fpga.set_parameter(N,6);
		
	// Modo de procesamiento --> { CALI = 0, LI = 1 };
	fpga.set_parameter(1,5);
	
	//////////////////////////////////////////////////////////////////////////////////
	/////////////////// ================== Calculos  ================/////////////////
	//////////////////////////////////////////////////////////////////////////////////


	std::cout << "Iniciando medidas... " << std::endl;
	fpga.Reiniciar();
	fpga.Comenzar();
		
	/////// Resultados LI /////
	std::cout << "\nResultados LI: " << std::endl;

	long long int X_li = fpga.leer_resultado_64_bit(0);
	long long int Y_li = fpga.leer_resultado_64_bit(1);
	int div_li = fpga.get_output_auxiliar(0);

	std::cout << "X: " << X_li << std::endl << "Y: " << Y_li << std::endl;
	std::cout << "Muestras promediadas: " << fpga.get_output_auxiliar(0) << std::endl;

	FPGA_de1soc::resultados results_li;
	if(f_clk == 64)
	{
		results_li = FPGA_de1soc::get_resultados_from_xy_64M (X_li,Y_li,div_li,Covertir2volt,f);
	}
	else
	{
		results_li = FPGA_de1soc::get_resultados_from_xy (X_li,Y_li,div_li,Covertir2volt);
	}

	std::cout << "r = " << results_li.r << std::endl;
	std::cout << "phi = " << results_li.phi << std::endl;

	/////// Resultados CALI /////
	fpga.set_parameter(0,5);
	std::cout << "\nResultados CALI: " << std::endl;
	
	long long int X_cali = fpga.leer_resultado_64_bit(0);
	long long int Y_cali = fpga.leer_resultado_64_bit(1);
	int div_cali = fpga.get_output_auxiliar(0);

	std::cout << "X: " << X_cali << std::endl << "Y: " << Y_cali << std::endl;
	std::cout << "Muestras promediadas: " << fpga.get_output_auxiliar(0) << std::endl;

	FPGA_de1soc::resultados results_cali;
	if(f_clk == 64)
	{
		results_cali = FPGA_de1soc::get_resultados_from_xy_64M (X_li,Y_li,div_li,Covertir2volt,f);
	}
	else
	{
		results_cali = FPGA_de1soc::get_resultados_from_xy (X_cali,Y_cali,div_cali,Covertir2volt);
	}

	std::cout << "r = " << results_cali.r << std::endl;
	std::cout << "phi = " << results_cali.phi << std::endl;
	
	
	////////////////////////////////////////////////////////////////////////////////////
	/////////////////// =============== Archivo salida  ===============/////////////////
	////////////////////////////////////////////////////////////////////////////////////


	ofstream archivo_salida(nombre_archivo_salida);
	if (!archivo_salida.is_open()) {
		cerr << "Error al abrir el archivo de salida." << endl;
		return 1;
	}

	FPGA_de1soc::resultados results = (modo == 0)? results_cali : results_li;
	
	// Escribe los valores de r y phi en el archivo de salida
	archivo_salida << "f = " << f_real << endl << "M = " << M << endl << "N = " << N << endl << endl;	
	archivo_salida << "x = " << results.x << endl << "y = " << results.y << endl << "r = " << results.r << endl << "phi = " << results.phi << endl;

	// Cierra el archivo de salida
	archivo_salida.close();

	fpga.Terminar();

    return 0;
}


