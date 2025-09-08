/*
================================================================================
 Programa principal de demostración de filtros FIR en FPGA
 Archivo: main.cpp
--------------------------------------------------------------------------------
 Este programa permite interactuar con la FPGA DE1-SoC para:
   - Configurar filtros FIR Pasa-Bajos y Pasa-Altos.
   - Ajustar la frecuencia de muestreo y la frecuencia de corte.
   - Enviar los coeficientes a la FPGA y ejecutar el filtrado.
   - Mostrar información sobre el filtro aplicado y su frecuencia de corte.

Funcionalidad principal:
   - Lectura de parámetros de usuario desde consola.
   - Configuración de la FPGA mediante la clase FPGA_de1soc.
   - Selección de filtros mediante la clase filters.
   - Ciclo de demostración interactivo hasta que el usuario decida salir.

Definiciones incluidas:
   - CLEAR_CONSOLE: Macro para limpiar la consola.
   - N_CRUDOS: Cantidad de muestras a procesar.
   - RAW_FIFO_DEPTH: Profundidad del FIFO de datos crudos.
   - Uso de clases FPGA_de1soc y filters para manejo de hardware y filtros.

Uso típico:
   - Ejecutar el programa.
   - Ingresar la frecuencia de muestreo (en kHz).
   - Seleccionar tipo de filtro: 0 = Pasa Bajos, 1 = Pasa Altos.
   - Ingresar frecuencia de corte deseada (en porcentaje relativo a f_s/2).
   - Observar el filtrado y repetir hasta salir con 0.

================================================================================
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
