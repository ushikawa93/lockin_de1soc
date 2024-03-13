

///// ====================== measure_lockin.cpp ======================================= /////
///// ================================================================================= /////
///// Programa en c++ para setear los parametros de la FPGA y obtener medidas de lockin /////
///// ================================================================================= /////
/*
	Debe ejecutarse en el micro de la FPGA, con la sintaxis:
		-> measure_lockin M | N | frecuencia | fuente | modo | nombre_archivo 
		
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

#include "FPGA_de1soc.h"


using namespace std;


int main(int argc, char *argv[])
{
    // Verificar que se proporcionen los argumentos necesarios
    if (argc != 7) {
        cerr << "Uso: measure_lockin M N frecuencia fuente modo nombre_archivo" << endl;
        return 1;
    }

    // Obtener los parámetros de la línea de comandos
    int M = atoi(argv[1]);
    int N = atoi(argv[2]);
    int f = atoi(argv[3]);
	int fuente = atoi(argv[4]);
	int modo = atoi(argv[5]);
    string nombre_archivo_salida = argv[6];


	FPGA_de1soc fpga;

	std::cout << "Iniciando medidas... " << std::endl;
	
	// Configuracion...
		fpga.set_clk_from_frec_and_M(f,M);

		// Prender led:
		//fpga.set_parameter(1,9);
		
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
	fpga.Reiniciar();
	fpga.Comenzar();
	
	std::cout << "Resultados: " << std::endl;
	// Resultados
	long long int X = fpga.leer_resultado_64_bit(0);
	long long int Y = fpga.leer_resultado_64_bit(1);
	
	double r, phi, x, y;
    double amplitud_ref = 32767;
	int div = M*N;

    x = (double)X / div;
    y = (double)Y / div;
	
	r = sqrt(pow(x, 2) + pow(y, 2)) * 2 / amplitud_ref;
    phi = atan2(y, x) * 180 / 3.1415;

    std::cout << "r = " << r << std::endl;
    std::cout << "phi = " << phi << std::endl;
	
	// Escribo archivo de salida:
	
		// Abre el archivo de salida para escritura
		ofstream archivo_salida(nombre_archivo_salida);
		if (!archivo_salida.is_open()) {
			cerr << "Error al abrir el archivo de salida." << endl;
			return 1;
		}

		// Escribe los valores de r y phi en el archivo de salida
		archivo_salida << "f = " << f << endl;
		archivo_salida << "M = " << M << endl;
		archivo_salida << "N = " << N << endl << endl;
		
		archivo_salida << "x = " << x << endl;
		archivo_salida << "y = " << y << endl;
		archivo_salida << "r = " << r << endl;
		archivo_salida << "phi = " << phi << endl;

		// Cierra el archivo de salida
		archivo_salida.close();

    return 0;
}


