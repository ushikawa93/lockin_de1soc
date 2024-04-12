
/* 
	Programa principal
*/

#include <iostream>
#include <fstream>
#include <string>
#include "FPGA_de1soc.h"
#include "filters.h"


#define CLEAR_CONSOLE "\033[2J\033[1;1H"  // Mandando este valor a cout limpio la pantalla
#define N_CRUDOS 512
#define RAW_FIFO_DEPTH 8192

using namespace std;


int main(int argc, char *argv[]) 
{
    FPGA_de1soc fpga;
    filters filtros;

    int x = 1;

    while ( x != 0)
    {
        
        int w, low_high,f_sampling;
        std::cout << CLEAR_CONSOLE;
        std::cout << "---- Bienvenido a la demostracion de filtros FIR en FPGA ----" << std::endl;

        std::cout << "Ingrese frecuencia de muestreo en kHz: " << std::endl;
        std::cin >> f_sampling;

        fpga.set_clk_from_frec(f_sampling*1000);   

        std::cout << "Tipo de filtro: Ingrese 0 -> Filtro Pasa Bajos \n                        1 -> Filtro Pasa Altos" << std::endl;
        std::cin >> low_high;
        string caracteristica_filtro = (low_high == 0)? "Pasa Bajos "    :   "Pasa Altos ";
        std::cout << "Ingrese frecuencia de corte deseada: " << std::endl;
        std::cin >> w;

        int* filtro_usado = filtros.getfiltro(w,low_high);
        fpga.set_N_parametros(33,filtro_usado);   

        fpga.Comenzar();

        float f_corte = (float)w/100 * (float)f_sampling /2; 
        std::cout << "Filtrando...." << std::endl ;
        std::cout << "\nFiltro actual: " << caracteristica_filtro <<  "Frecuencia de corte: " <<  f_corte << " kHz" <<endl;

        std::cout << "Ingrese 0 para salir o cualquier otra tecla para probar otro filtro ";
        std::cin >> x;

        fpga.Terminar();
        std::cout << CLEAR_CONSOLE;
    }


}
