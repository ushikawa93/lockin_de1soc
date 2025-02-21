


///// ====================== clock_delay_test.cpp ====================================================== /////
///// ================================================================================================== /////
///// Programa en c++ para probar el lockin a distintas frecuencias de clock y evaluar la etapa analógica/////
///// ================================================================================================== /////
/*
	Debe ejecutarse en el micro de la FPGA, con la sintaxis:
		
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

#define ref_with_dds_compiler 1

using namespace std;
double calcularPromedio(const double arreglo[], int longitud, double tolerancia) ;

int main(int argc, char *argv[])
{

    FPGA_de1soc fpga;
    string nombre_archivo_salida = "desfasajes.dat";

    //////////////////////////////////////////////////////////////////////////////////
	/////////////////// =============== Configuracion  ==============/////////////////
	//////////////////////////////////////////////////////////////////////////////////

	std::cout << "Iniciando configuracion.. " << std::endl;
	
	// Fuente de los datos: --> { ADC_2308 = 0, ADC_HS = 1, SIM = 2  };
	fpga.set_parameter(1,0);
	
	// Ciclos de promediacion CALI
	fpga.set_parameter(1,2);	// Largo filtro MA
	fpga.set_parameter(1,3);	// Promediacion coherente

	// Ruido en simulacion
	fpga.set_parameter(0,4);
		
	// Ciclos de promediacion LI
	fpga.set_parameter(1,6);
		
	// Modo de procesamiento --> { CALI = 0, LI = 1 };
	fpga.set_parameter(0,5);

    // Modo de generacion de señales --> { LU_Table = 0, DDS_compiler = 1 }
	fpga.set_parameter(ref_with_dds_compiler,9);


    /////////////////////////////////////////////////////////////////////////////////////
	/////////////////// ================== Calculos  ================ ///////////////////
	/////////////////////////////////////////////////////////////////////////////////////
	
    int M = 64;
    double f_clks [64];
    double fases [64];
    double desf_con_clk [64];
    double amplitudes [64];

    const int iteraciones = 20;

    
    for (int f_clk = 1 ; f_clk <= 64 ; f_clk++)
    {
        fpga.set_frec_clk(f_clk);       

        int f_signal = f_clk*1000000 / M;

        double f_real_dac = fpga.set_frec_dds_compiler_dac(f_signal,f_clk*1000000);	
	    double f_real_ref = fpga.set_frec_dds_compiler_ref(f_signal,f_clk*1000000);	

        std::cout << "Calculando f_clk: " << f_clk << "MHz... f señal: " << f_real_ref << std::endl;

        double f_clks_i [iteraciones];
        double fases_i [iteraciones];
        double desf_con_clk_i [iteraciones];
        double amplitudes_i [iteraciones];

        for (int iter = 0; iter < iteraciones; iter ++)
        {
            fpga.Reiniciar();
            fpga.Comenzar();

            long long int X = fpga.leer_resultado_64_bit(0);
            long long int Y = fpga.leer_resultado_64_bit(1);
            int div = fpga.get_output_auxiliar(0);

            FPGA_de1soc::resultados results = FPGA_de1soc::get_resultados_from_xy (X,Y,div,false);

            f_clks_i[iter] = f_clk;
            fases_i[iter] = results.phi;
            amplitudes_i[iter] = results.r;
            desf_con_clk_i[iter] = results.phi/(360/(float)M); 

        }        

        f_clks[f_clk-1] = calcularPromedio ( f_clks_i , iteraciones,1 );
        fases[f_clk-1] = calcularPromedio ( fases_i ,  iteraciones,1 );
        amplitudes[f_clk-1] = calcularPromedio ( amplitudes_i, iteraciones, 1 );
        desf_con_clk[f_clk-1] = calcularPromedio ( desf_con_clk_i ,iteraciones, 1 );  

        fpga.Terminar();
    }

    ofstream archivo_salida(nombre_archivo_salida);
	if (!archivo_salida.is_open()) {
		cerr << "Error al abrir el archivo de salida." << endl;
		return 1;
	}
    archivo_salida << "frec" <<  " " << "amplitud "  << "fase" << "Delay del clock" << std::endl;
    for (int i = 0; i < 64; ++i) 
    {
        archivo_salida << f_clks[i] <<  " " << amplitudes[i]  << ": " << fases[i] << " " << desf_con_clk[i] << std::endl;
    }

    archivo_salida.close();
     fpga.Comenzar();
}

double calcularPromedio(const double arreglo[], int longitud, double tolerancia) {
    // Calcular la media del arreglo
    double suma = 0.0;
    for (int i = 0; i < longitud; ++i) {
        suma += arreglo[i];
    }
    double media = suma / longitud;

    // Calcular la desviación estándar del arreglo
    double suma_cuadrados = 0.0;
    for (int i = 0; i < longitud; ++i) {
        suma_cuadrados += (arreglo[i] - media) * (arreglo[i] - media);
    }
    double desviacion_estandar = sqrt(suma_cuadrados / longitud);

    // Calcular el promedio ignorando los valores que se desvían significativamente de la media
    suma = 0.0;
    int conteo = 0;
    for (int i = 0; i < longitud; ++i) {
        if (fabs(arreglo[i] - media) <= tolerancia * desviacion_estandar) {
            suma += arreglo[i];
            ++conteo;
        }
    }

    // Evitar división por cero
    if (conteo == 0) {
        return 0.0; // o lanzar una excepción, según el caso
    }

    return suma / conteo;
}