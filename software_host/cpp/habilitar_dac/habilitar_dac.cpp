

///// ====================== habilitar_dac.cpp ======================================= /////
///// ================================================================================= /////
///// Programa en c++ para habilitar el dac a una frecuencia y dejarlo andando /////
///// ================================================================================= /////

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
	int f_dac = 100000;
	if(argc == 2)
	{
		f_dac = atoi(argv[1]);
	}
	int f_clk = 10;
	int M = f_clk*1000000  / f_dac;	

	// Modo de generacion de señales --> { LU_Table = 0, DDS_compiler = 1 }
	int dds_compiler = 1;

	///// ================================================================================= /////
	///// ============================ Configuracion ====================================== /////
	///// ================================================================================= /////

	FPGA_de1soc fpga;	
	
	std::cout << "Iniciando configuracion... " << std::endl;
	
	// Frecuencias de operacion (referencias dac y clock)
	double f_real_ref = fpga.setFrecuenciaReferencias( dds_compiler , f_dac , f_clk , M);
	double f_real_dac = fpga.setFrecuenciaDAC ( dds_compiler, f_dac , f_clk, M);
			
	// Fuente de los datos: --> { ADC_2308 = 0, ADC_HS = 1, SIM = 2  };
	fpga.set_parameter(1,0);
			
	// Puntos por ciclo	
	fpga.set_parameter(M,1);
		
	// Ciclos de promediacion CALI
	fpga.set_parameter(1,2);	// Largo filtro MA
	fpga.set_parameter(1,3);	// Promediacion coherente

	// Bits de ruido para simulacion
	fpga.set_parameter(0,4);

	// Modo de procesamiento --> { CALI = 0, LI = 1 };
	fpga.set_parameter(0,5);
		
	// Ciclos de promediacion LI
	fpga.set_parameter(1,6);		

	// Modo de generacion de señales --> { LU_Table = 0, DDS_compiler = 1 }
	fpga.set_parameter(dds_compiler,9);


	///// ================================================================================= /////
	///// ============================ Calculos =========================================== /////
	///// ================================================================================= /////

	std::cout << "Iniciando medidas... " << std::endl;

	fpga.Reiniciar();	
	fpga.Comenzar();

	std::cout << "Generando señal de" << " Hz \nPresione ENTER para terminar" << endl;

    while (true) {
        if (std::cin.get() == '\n') {
            // Se rompe el ciclo cuando se presiona ENTER.
            break;
        }
    }


	fpga.Terminar();

}