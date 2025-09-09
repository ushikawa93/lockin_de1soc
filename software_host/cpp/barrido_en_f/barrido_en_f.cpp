///// ============================================================================================== /////
///// ============================== Barrido en frecuencia (Lock-In) ================================ /////
///// ============================================================================================== /////
//
// Programa en C++ para ejecutar en el micro de la FPGA DE1-SoC.
// Realiza un barrido de frecuencias en el lock-in, midiendo amplitud (r), fase (φ) y componentes X/Y.
// Permite evaluar la respuesta del sistema a distintas frecuencias.
//
// Funcionalidad principal:
//   • Configura la FPGA con los parámetros de reloj, N, fuente de datos y modo de referencia.
//   • Recorre un rango de frecuencias definido por (f_inicial → f_final, con paso f_step).
//   • Para cada frecuencia, obtiene X, Y, r y φ del lock-in.
//   • Registra los resultados en un archivo de salida con formato CSV.
//
// Uso:
//   ./barrido_en_f f_clk N fuente modo f_inicial f_final f_step nombre_archivo corregir_fase sim_noise [M ref_with_dds_compiler]
//
// Parámetros clave:
//   f_clk       -> Frecuencia de reloj (MHz)
//   N           -> Constante de tiempo (ciclos de promediación)
//   fuente      -> Fuente de datos {0=ADC_2308, 1=ADC_HS, 2=SIM}
//   modo        -> Procesamiento {0=CALI, 1=LI}
//   f_inicial   -> Frecuencia inicial del barrido (Hz)
//   f_final     -> Frecuencia final del barrido (Hz)
//   f_step      -> Incremento en frecuencia (Hz)
//   nombre_archivo -> Archivo CSV de salida
//   corregir_fase  -> (0/1) Aplica corrección de fase
//   sim_noise      -> Nivel de ruido en modo simulación
//   M, ref_with_dds_compiler (opcionales) -> Configuración fina de referencia
//
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
#include <vector>
#include <iomanip> 
#include <chrono>
#include <thread>
#include <chrono>

#include "../fpga_driver/FPGA_de1soc.h"


using namespace std;

int main(int argc, char *argv[])
{
	///// ================================================================================= /////
	///// ============================ Seteo de parámetros ================================ /////
	///// ================================================================================= /////


    // Verificar que se proporcionen los argumentos necesarios
    if ((argc != 11)&&(argc != 13)) {
        cerr << "Uso barrido_en_f f_clk N fuente modo f_inicial f_final f_step nombre_archivo corregir_fase sim_noise [{M modo_referencias}]" << endl;
        return 1;
    }

	/////// ========================== Parametros obligatorios ===================================== /////	
	int f_clk = atoi(argv[1]);
    int N = atoi(argv[2]);
	int fuente = atoi(argv[3]);
	int modo = atoi(argv[4]);
	int f_inicial = atoi(argv[5]);
	int f_final = atoi(argv[6]);
	int f_step = atoi(argv[7]);
    string nombre_archivo_salida = argv[8];
	bool corregir_fase = (atoi(argv[9])==1)? true:false;
	int sim_noise = atoi(argv[10]);

	/////// ========================== Parametros opcionales ===================================== /////
	int M = f_clk*1000000 / f_inicial;
	int ref_with_dds_compiler = 1;

	if(argc == 13)
	{
		M = atoi(argv[11]);
		ref_with_dds_compiler = atoi(argv[12]);
	}


	/////// ========================== Parametros fijos ===================================== /////	
	bool Covertir2volt = true;









	///// ================================================================================= /////
	///// ============================ Configuracion ====================================== /////
	///// ================================================================================= /////

	FPGA_de1soc fpga;

	std::cout << "Iniciando medidas... " << std::endl;
	
	
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


	int f;

	// Definir vectores para almacenar f, r y phi.
    std::vector<double> f_values;
    std::vector<double> r_values;
	std::vector<double> x_values;
    std::vector<double> y_values;
    std::vector<double> phi_values;
	

	for(f = f_inicial ; f <= f_final ; f = f+f_step)
	{
		// Frecuencias de operacion (referencias dac y clock)
		double f_real_ref = fpga.setFrecuenciaReferencias( ref_with_dds_compiler , f , f_clk , M);
		double f_real_dac = fpga.setFrecuenciaDAC ( ref_with_dds_compiler, f , f_clk, M);

		fpga.Reiniciar();
		std::this_thread::sleep_for(std::chrono::milliseconds(10));
		fpga.Comenzar();
		
		std::cout << "Resultados: " << std::endl;
		// Resultados
		long long int X = fpga.leer_resultado_64_bit(0);
		long long int Y = fpga.leer_resultado_64_bit(1);
		int div = fpga.get_output_auxiliar(0);

		FPGA_de1soc::resultados results_li;
		if(corregir_fase)
		{
			results_li = FPGA_de1soc::get_resultados_from_xy (X,Y,div,Covertir2volt,f,f_clk);
		}
		else
		{
			results_li = FPGA_de1soc::get_resultados_from_xy (X,Y,div,Covertir2volt);
		}
		
		

		std::cout << "f: " << f_real_ref << "		r = " << results_li.r << "		phi = " << results_li.phi << std::endl;

		f_values.push_back(f_real_ref); // Guardar el valor de f en el vector f_values.
        r_values.push_back(results_li.r); // Guardar el valor de r en el vector r_values.
        phi_values.push_back(results_li.phi); // Guardar el valor de phi en el vector phi_values.
		x_values.push_back(results_li.x);
		y_values.push_back(results_li.y); 

		fpga.Terminar();
	}
	
	


	///// ================================================================================= /////
	///// ============================ Archivo salida ===================================== /////
	///// ================================================================================= /////
	
	// Abre el archivo de salida para escritura
	ofstream archivo_salida(nombre_archivo_salida);
	if (!archivo_salida.is_open()) {
		cerr << "Error al abrir el archivo de salida." << endl;
		return 1;
	}

	archivo_salida << std::fixed << std::setprecision(6); 

	// Escribe los valores de r y phi en el archivo de salida
	archivo_salida << "Barrido en f -> f_inicial:" << f_inicial << ", f_final:" << f_final << ", step: " << f_step << std::endl;
	archivo_salida << "Parametros -> N:" << N << ", Modo:" << modo << ",	Fuente:" << fuente << endl;
	archivo_salida << "Formato -> f,x,y,r,phi" << endl << endl;

	for (size_t i = 0; i < f_values.size(); ++i) 
	{
       	archivo_salida << f_values[i] << "," << x_values[i] << "," << y_values[i] << "," << r_values[i] << "," << phi_values[i] << std::endl;
    }

	// Cierra el archivo de salida
	archivo_salida.close();

    return 0;
}


