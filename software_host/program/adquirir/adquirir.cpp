

///// ====================== adquirir.cpp ======================================= /////
///// ================================================================================= /////
///// Programa en c++ para setear los parametros de la FPGA y obtener medidas del ADC /////
///// ================================================================================= /////
/*
	Debe ejecutarse en el micro de la FPGA, con la sintaxis:
		-> adquirir M | N | frecuencia | ciclos2display | nombre_archivo 
		
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
    if (argc != 6) {
        cerr << "Uso: adquirir M N frecuencia ciclos2display nombre_archivo " << endl;
        return 1;
    }

    // Obtener los parámetros de la línea de comandos
    int M = atoi(argv[1]);
    int N = atoi(argv[2]);
    int f = atoi(argv[3]);
	int ciclos2display = atoi(argv[4]);
	int fuente = 2;
	int modo = 1;
    string nombre_archivo_salida = argv[5];

	FPGA_de1soc fpga;

	int f_clk = 64;	// En MHz

	M = f_clk*1000000  / f;	// Ya no lo obtengo de la linea de comandos (hay que cambiar despues eso)
	
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
		archivo_salida << fpga.LeerFIFO32individual(1) << ",";
    }     
	
	// Cierra el archivo de salida
	archivo_salida.close();
	
    return 0;
}


