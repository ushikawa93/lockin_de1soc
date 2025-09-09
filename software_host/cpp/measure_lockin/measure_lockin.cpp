///// ============================================================================================== /////
///// ================================== measure_lockin.cpp ========================================= /////
///// ============================================================================================== /////
/////
///// Programa en C++ para configurar la FPGA DE1-SoC y obtener mediciones con el lock-in digital.
/////
///// Objetivo:
/////   • Setear parámetros de adquisición y procesamiento en la FPGA.
/////   • Medir señales procesadas en los dos modos disponibles:
/////        - Lock-in (LI).
/////        - Promedio coherente seguido de Lock-in (CALI).
/////   • Guardar los resultados en un archivo de salida con amplitud y fase.
/////
///// Uso:
/////   measure_lockin sim_noise N frecuencia fuente modo nombre_archivo
/////                 [f_clk corregir_fase {M modo_referencias}]
/////
/////   Parámetros obligatorios:
/////     sim_noise       : Nivel de ruido en simulación.
/////     N               : Número de ciclos de promediación.
/////     frecuencia      : Frecuencia de la señal de referencia.
/////     fuente          : Fuente de datos {0=ADC_2308, 1=ADC_HS, 2=SIM}.
/////     modo            : Modo de salida {0=CALI, 1=LI}.
/////     nombre_archivo  : Archivo donde se guardan los resultados.
/////
/////   Parámetros opcionales:
/////     f_clk           : Frecuencia del clock principal en MHz (default=64).
/////     corregir_fase   : Aplicar corrección de fase (1=Sí, 0=No, default=1).
/////     M               : Puntos por ciclo (default = f_clk*1e6 / f).
/////     modo_referencias: Generación de señales {0=LU_Table, 1=DDS_compiler}.
/////
///// Flujo general:
/////   1. Inicializa la FPGA y configura parámetros de operación.
/////   2. Ajusta frecuencias de referencia y DAC mediante DDS Compiler o LUT.
/////   3. Ejecuta medidas en modo Lock-in (LI) y Calibración (CALI).
/////   4. Calcula amplitud (r) y fase (phi), con opción de corrección de fase.
/////   5. Exporta resultados a archivo de texto.
/////
///// Dependencias:
/////   - `FPGA_de1soc.h`
/////
///// ============================================================================================== /////

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
	///// ================================================================================= /////
	///// ============================ Seteo de parámetros ================================ /////
	///// ================================================================================= /////

    // Verificar que se proporcionen los argumentos necesarios
    if ((argc != 7)&&(argc != 8) && (argc != 9) && (argc != 11) ){
        cerr << "Uso: measure_lockin sim_noise N frecuencia fuente modo nombre_archivo [f_clk corregir_fase {M modo_referencias}](opcional)" << endl;
        return 1;
    }

	/////// ========================== Parametros obligatorios ===================================== /////
    int sim_noise = atoi(argv[1]);
    int N = atoi(argv[2]);
    int f = atoi(argv[3]);
	int fuente = atoi(argv[4]);
	int modo = atoi(argv[5]);	
    string nombre_archivo_salida = argv[6];
	
	/////// ========================== Parametros opcionales ===================================== /////
	bool corregir_fase = true;
	int f_clk = 64;	// En MHz
	int M = f_clk*1000000 / f;
	int ref_with_dds_compiler = 1;
		
	if (argc == 8)
	{
		f_clk = atoi(argv[7]);
	}
	else if (argc == 9)
	{
		f_clk = atoi(argv[7]);
		corregir_fase = (atoi(argv[8]) == 1)? true:false;
	}
	else if(argc == 11)
	{
		f_clk = atoi(argv[7]);
		corregir_fase = (atoi(argv[8]) == 1)? true:false;
		M = atoi(argv[9]);
		ref_with_dds_compiler = atoi(argv[10]);
	}

	/////// ========================== Parametros fijos ===================================== /////
	if(fuente == 2 ){corregir_fase = false;}
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





	///// ================================================================================= /////
	///// ============================ Calculos =========================================== /////
	///// ================================================================================= /////

	std::cout << "Iniciando medidas... " << std::endl;
	fpga.Reiniciar();
	fpga.Comenzar();
		
	/////// ========================== Resultados LI ===================================== /////
	std::cout << "\nResultados LI: " << std::endl;

	long long int X_li = fpga.leer_resultado_64_bit(0);
	long long int Y_li = fpga.leer_resultado_64_bit(1);
	int div_li = fpga.get_output_auxiliar(0);

	std::cout << "X: " << X_li << std::endl << "Y: " << Y_li << std::endl;
	std::cout << "Muestras promediadas: " << fpga.get_output_auxiliar(0) << std::endl;

	FPGA_de1soc::resultados results_li;
	if(corregir_fase)
	{
		results_li = FPGA_de1soc::get_resultados_from_xy (X_li,Y_li,div_li,Covertir2volt,f,f_clk);
	}
	else
	{
		results_li = FPGA_de1soc::get_resultados_from_xy (X_li,Y_li,div_li,Covertir2volt);
	}

	std::cout << "r = " << results_li.r << std::endl;
	std::cout << "phi = " << results_li.phi << std::endl;

	/////// ========================= Resultados CALI ==================================== /////
	fpga.set_parameter(0,5);
	std::cout << "\nResultados CALI: " << std::endl;
	
	long long int X_cali = fpga.leer_resultado_64_bit(0);
	long long int Y_cali = fpga.leer_resultado_64_bit(1);
	int div_cali = fpga.get_output_auxiliar(0);

	std::cout << "X: " << X_cali << std::endl << "Y: " << Y_cali << std::endl;
	std::cout << "Muestras promediadas: " << fpga.get_output_auxiliar(0) << std::endl;

	FPGA_de1soc::resultados results_cali;
	if(corregir_fase)
	{
		results_cali = FPGA_de1soc::get_resultados_from_xy (X_li,Y_li,div_li,Covertir2volt,f,f_clk);
	}
	else
	{
		results_cali = FPGA_de1soc::get_resultados_from_xy (X_cali,Y_cali,div_cali,Covertir2volt);
	}

	std::cout << "r = " << results_cali.r << std::endl;
	std::cout << "phi = " << results_cali.phi << std::endl;
	



	
	

	///// ================================================================================= /////
	///// ============================ Archivo salida ===================================== /////
	///// ================================================================================= /////

	ofstream archivo_salida(nombre_archivo_salida);
	if (!archivo_salida.is_open()) {
		cerr << "Error al abrir el archivo de salida." << endl;
		return 1;
	}

	FPGA_de1soc::resultados results = (modo == 0)? results_cali : results_li;
	
	// Escribe los valores de r y phi en el archivo de salida
	archivo_salida << "f = " << f_real_ref << endl << "M = " << M << endl << "N = " << N << endl << endl;	
	archivo_salida << "x = " << results.x << endl << "y = " << results.y << endl << "r = " << results.r << endl << "phi = " << results.phi << endl;

	// Cierra el archivo de salida
	archivo_salida.close();

	fpga.Terminar();

    return 0;
}


