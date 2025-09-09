

///// ================================================================================== /////
///// ========================== adquirir.cpp (Programa base) ========================== /////
///// ================================================================================== /////
//
// Programa en C++ para configurar parámetros de la FPGA (DE1-SoC) y adquirir medidas del ADC.
//
// Uso:
//   adquirir N frecuencia ciclos2display nombre_archivo fifo2read [M modo_referencias]
//
// Parámetros obligatorios:
//   • N                -> Ciclos de promediación.
//   • frecuencia       -> Frecuencia de referencia en Hz.
//   • ciclos2display  -> Número de ciclos a mostrar/guardar.
//   • nombre_archivo   -> Archivo de salida (.csv).
//   • fifo2read        -> FIFO desde la cual leer los datos.
//
// Parámetros opcionales:
//   • M                -> Puntos por ciclo (si no se especifica, se calcula automáticamente).
//   • modo_referencias -> 0 = LUT, 1 = DDS compiler.
//
// Funcionalidad:
//   - Configura la frecuencia de las referencias y del DAC.
//   - Define fuente de datos (ADC, simulación, etc.).
//   - Ajusta parámetros de promediación coherente y lock-in.
//   - Ejecuta la captura de datos desde la FPGA.
//   - Escribe las muestras en el archivo de salida especificado.
//
// Notas:
//   • Debe ejecutarse en el microprocesador (uP) de la DE1-SoC.
//   • Requiere el driver `FPGA_de1soc` incluido en `../fpga_driver/FPGA_de1soc.h`.
//
///// ================================================================================== /////

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
    if ((argc != 6)&&(argc != 8)) {
        cerr << "Uso: adquirir N frecuencia ciclos2display nombre_archivo fifo2read [{M modo_referencias}]" << endl;
        return 1;
    }

	/////// ========================== Parametros fijos ===================================== /////	
	int fuente = 1;
	int modo = 1;
	int sim_noise = 0;
	int f_clk = 64;	// En MHz

	/////// ========================== Parametros obligatorios ===================================== /////
    int N = atoi(argv[1]);
    int f = atoi(argv[2]);
	int ciclos2display = atoi(argv[3]);
	string nombre_archivo_salida = argv[4];
	int fifo2read = atoi(argv[5]);

	/////// ========================== Parametros opcionales ===================================== /////
	int ref_with_dds_compiler = 1;
	int M = f_clk*1000000  / f;	

	if (argc == 8)
	{		
		M = atoi(argv[6]);
		ref_with_dds_compiler = atoi(argv[7]);
	}



	///// ================================================================================= /////
	///// ============================ Configuracion ====================================== /////
	///// ================================================================================= /////

	FPGA_de1soc fpga;	
	
	std::cout << "Iniciando configuracion... " << std::endl;

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

	// Modo de procesamiento --> { CALI = 0, LI = 1 };
	fpga.set_parameter(modo,5);
		
	// Ciclos de promediacion LI
	fpga.set_parameter(N,6);

	// Modo de generacion de señales --> { LU_Table = 0, DDS_compiler = 1 }
	fpga.set_parameter(ref_with_dds_compiler,9);



	

	///// ================================================================================= /////
	///// ============================ Calculos =========================================== /////
	///// ================================================================================= /////

	// Cálculos
	std::cout << "Iniciando medidas... " << std::endl;

	fpga.Reiniciar();	
	fpga.Comenzar();

	std::cout << "Muestras promediadas: " << fpga.get_output_auxiliar(0) << std::endl;
	


	///// ================================================================================= /////
	///// ============================ Archivo salida ===================================== /////
	///// ================================================================================= /////

	// Abre el archivo de salida para escritura
	ofstream archivo_salida(nombre_archivo_salida);
	if (!archivo_salida.is_open()) {
		cerr << "Error al abrir el archivo de salida." << endl;
		return 1;
	}
	for (int i=0;i<ciclos2display*M;i++)
    {           
		archivo_salida << fpga.LeerFIFO32individual(fifo2read) << ",";
    }     
	
	// Cierra el archivo de salida
	archivo_salida.close();
	
    return 0;
}


