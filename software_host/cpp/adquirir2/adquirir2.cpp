

///// ====================== adquirir.cpp ======================================= /////
///// ================================================================================= /////
///// Programa en c++ para setear los parametros de la FPGA y obtener medidas del ADC /////
///// ================================================================================= /////
/*
	Debe ejecutarse en el micro de la FPGA, con la sintaxis:
		-> adquirir sim_noise | N | frecuencia | ciclos2display | nombre_archivo 
		
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
    if ((argc != 6)&&(argc != 7)&&(argc != 8)) {
        cerr << "Uso: adquirir sim_noise N frecuencia ciclos2display nombre_archivo " << endl;
        return 1;
    }

    // Obtener los parámetros de la línea de comandos
    int sim_noise = atoi(argv[1]);
    int N = atoi(argv[2]);
    int f = atoi(argv[3]);
	int ciclos2display = atoi(argv[4]);
	string nombre_archivo_salida = argv[5];

	int fuente = 1;
	int modo = 1;	
	
	int f_clk = 64;	// En MHz

	if (argc == 7)
	{
		f_clk = atoi(argv[6]);
	}
	else if (argc == 8)
	{		
		f_clk = atoi(argv[6]);
		fuente = atoi(argv[7]);
	}

	
	int M = f_clk*1000000  / f;	// Ya no lo obtengo de la linea de comandos (hay que cambiar despues eso)


	FPGA_de1soc fpga;	
	
	std::cout << "Iniciando configuracion... " << std::endl;
	
	// Configuracion...
	fpga.set_frec_clk(f_clk);
	double f_real = fpga.set_frec_dds_compiler(f,f_clk*1000000);	
			
	// Fuente de los datos: --> { ADC_2308 = 0, ADC_HS = 1, SIM = 2  };
	fpga.set_parameter(fuente,0);
			
	// Puntos por ciclo	
	fpga.set_parameter(M,1);
		
	// Ciclos de promediacion CALI
	fpga.set_parameter(1,2);	// Largo filtro MA
	fpga.set_parameter(N,3);	// Promediacion coherente

	// Bits de ruido para simulacion
	fpga.set_parameter(sim_noise,4);
		
	// Ciclos de promediacion LI
	fpga.set_parameter(N,6);
		
	// Modo de procesamiento --> { CALI = 0, LI = 1 };
	fpga.set_parameter(modo,5);
	
	// Cálculos
	std::cout << "Iniciando medidas... " << std::endl;

	fpga.Reiniciar();	
	fpga.Comenzar();

	std::cout << "Muestras promediadas: " << fpga.get_output_auxiliar(0) << std::endl;
	
	// Abre el archivo de salida para escritura
	ofstream archivo_salida(nombre_archivo_salida);
	if (!archivo_salida.is_open()) {
		cerr << "Error al abrir el archivo de salida." << endl;
		return 1;
	}
	
	

	for (int i=0;i<ciclos2display*M;i++)
    {           
		archivo_salida << fpga.LeerFIFO32individual(0);
		if (i < ciclos2display * M - 1) {
			archivo_salida << ",";
		}
    }   

	archivo_salida << endl;

	for (int i=0;i<ciclos2display*M;i++)
    {           
		archivo_salida << fpga.LeerFIFO32individual(1);
		if (i < ciclos2display * M - 1) {
			archivo_salida << ",";
		}
    }     

	// Cierra el archivo de salida
	archivo_salida.close();


	fpga.Terminar();
	
    return 0;
}

