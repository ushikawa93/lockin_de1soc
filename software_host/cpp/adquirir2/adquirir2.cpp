
///// ================================================================================== /////
///// ========================= adquirir2.cpp (Programa base) ========================== /////
///// ================================================================================== /////
//
// Programa en C++ para configurar parámetros de la FPGA (DE1-SoC) y adquirir medidas del ADC.
// Es una versión extendida de `adquirir.cpp`, con más parámetros opcionales.
//
// Uso:
//   adquirir2 N frecuencia ciclos2display nombre_archivo 
//             [sim_noise f_clk fuente {M modo_referencias}]
//
// Parámetros obligatorios:
//   • N                -> Ciclos de promediación.
//   • frecuencia       -> Frecuencia de referencia en Hz.
//   • ciclos2display  -> Número de ciclos a mostrar/guardar.
//   • nombre_archivo   -> Archivo de salida (.csv).
//
// Parámetros opcionales (en orden):
//   • sim_noise        -> Bits de ruido para simulación (default = 0).
//   • f_clk            -> Frecuencia de reloj en MHz (default = 64).
//   • fuente           -> Fuente de datos {0 = ADC_2308, 1 = ADC_HS, 2 = SIM} (default = 1).
//   • M                -> Puntos por ciclo (usado si modo_referencias = 0).
//   • modo_referencias -> {0 = LUT, 1 = DDS compiler} (default = 1).
//
// Funcionalidad:
//   - Configura la frecuencia de las referencias y del DAC.
//   - Ajusta parámetros de promediación coherente (CALI) y lock-in (LI).
//   - Permite elegir la fuente de datos (ADC o simulación).
//   - Inicia la adquisición de datos en la FPGA.
//   - Guarda los resultados en archivo CSV, con dos bloques separados:
//       • Primer bloque: datos de FIFO0.
//       • Segundo bloque: datos de FIFO1.
//
// Notas:
//   • Debe ejecutarse en el microprocesador (uP) de la DE1-SoC.
//   • Requiere el driver `FPGA_de1soc` (`../fpga_driver/FPGA_de1soc.h`).
//   • Finaliza limpiamente llamando a `fpga.Terminar()`.
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
    if ((argc != 6)&&(argc != 7)&&(argc != 8)&&(argc != 10)) {
        cerr << "Uso: adquirir2 N frecuencia ciclos2display nombre_archivo [sim_noise f_clk fuente {M modo_referencias}](opcional)  " << endl;
        return 1;
    }

	/////// ========================== Parametros obligatorios ===================================== /////
    int N = atoi(argv[1]);
    int f = atoi(argv[2]);
	int ciclos2display = atoi(argv[3]);
	string nombre_archivo_salida = argv[4];

	/////// ========================== Parametros opcionales ===================================== /////
	int sim_noise = 0;
	int f_clk = 64;	// En MHz
	int fuente = 1;
	int M = f_clk*1000000  / f;	
	int ref_with_dds_compiler = 1;


	if(argc == 6)
	{
		sim_noise = atoi(argv[5]);
	}
	else if (argc == 7)
	{
		sim_noise = atoi(argv[5]);
		f_clk = atoi(argv[6]);
	}
	else if (argc == 8)
	{	
		sim_noise = atoi(argv[5]);
		f_clk = atoi(argv[6]);
		fuente = atoi(argv[7]);
	}
	else if (argc == 10)
	{
		sim_noise = atoi(argv[5]);
		f_clk = atoi(argv[6]);
		fuente = atoi(argv[7]);
		ref_with_dds_compiler = atoi(argv[9]);

		if(ref_with_dds_compiler == 0)
		{
			M = atoi(argv[8]);
		}		
	}
	
	

	/////// ========================== Parametros fijos ===================================== /////	
	int modo = 1;	

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

	// Bits de ruido para simulacion
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


