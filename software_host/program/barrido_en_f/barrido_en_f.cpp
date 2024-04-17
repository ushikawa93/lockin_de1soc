

///// ====================== barrido_en_f.cpp ======================================= /////
///// ================================================================================= /////
///// Programa en c++ para testear el lockin a varias frecuencias distintas				 /////
///// ================================================================================= /////
/*
	Debe ejecutarse en el micro de la FPGA, con la sintaxis:
		-> barrido_en_f M | N | fuente | modo | f_inicial | f_final | f_step | nombre_archivo 
		
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

#include "fpga_driver/FPGA_de1soc.h"


using namespace std;


int main(int argc, char *argv[])
{
    // Verificar que se proporcionen los argumentos necesarios
    if (argc != 9) {
        cerr << "Uso barrido_en_f M N fuente modo f_inicial f_final f_step nombre_archivo" << endl;
        return 1;
    }

    // Obtener los parámetros de la línea de comandos
    int M = atoi(argv[1]);
    int N = atoi(argv[2]);
	int fuente = atoi(argv[3]);
	int modo = atoi(argv[4]);
	int f_inicial = atoi(argv[5]);
	int f_final = atoi(argv[6]);
	int f_step = atoi(argv[7]);
    string nombre_archivo_salida = argv[8];


	FPGA_de1soc fpga;

	std::cout << "Iniciando medidas... " << std::endl;
	
	// Configuracion...

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
	int f;

	// Definir vectores para almacenar f, r y phi.
    std::vector<double> f_values;
    std::vector<double> r_values;
	std::vector<double> x_values;
    std::vector<double> y_values;
    std::vector<double> phi_values;

	for(f = f_inicial ; f <= f_final ; f = f+f_step)
	{
		double f_real = fpga.set_clk_from_frec_and_M(f,M);
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

		std::cout << "f: " << f_real << "		r = " << r << "		phi = " << phi << std::endl;

		f_values.push_back(f_real); // Guardar el valor de f en el vector f_values.
        r_values.push_back(r); // Guardar el valor de r en el vector r_values.
        phi_values.push_back(phi); // Guardar el valor de phi en el vector phi_values.
		x_values.push_back(x);
		y_values.push_back(y);

		//std::this_thread::sleep_for(std::chrono::seconds(1)); // Al parecer no es necesario
 
	}

	
	
	// Escribo archivo de salida:
	
		// Abre el archivo de salida para escritura
		ofstream archivo_salida(nombre_archivo_salida);
		if (!archivo_salida.is_open()) {
			cerr << "Error al abrir el archivo de salida." << endl;
			return 1;
		}

	    archivo_salida << std::fixed << std::setprecision(6); 

		// Escribe los valores de r y phi en el archivo de salida
		archivo_salida << "Barrido en f -> f_inicial:" << f_inicial << ", f_final:" << f_final << ", step: " << f_step << std::endl;
		archivo_salida << "Parametros -> M:" << M << ",	N:" << N << ", Modo:" << modo << ",	Fuente:" << fuente << endl;
		archivo_salida << "Formato -> f,x,y,r,phi" << endl << endl;

		for (size_t i = 0; i < f_values.size(); ++i) 
		{
        	archivo_salida << f_values[i] << "," << x_values[i] << "," << y_values[i] << "," << r_values[i] << "," << phi_values[i] << std::endl;
    	}

		// Cierra el archivo de salida
		archivo_salida.close();

    return 0;
}


