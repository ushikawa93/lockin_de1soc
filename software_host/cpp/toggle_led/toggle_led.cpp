///// ============================================================================================== /////
///// ================================== toggle_led.cpp ============================================ /////
///// ============================================================================================== /////
/////
///// Programa en C++ para controlar los LEDs de la FPGA DE1-SoC.
/////
///// Objetivo:
/////   • Encender o apagar un LED de la placa desde el microprocesador.
/////
///// Uso:
/////   toggle_led estado
/////
/////   Parámetros:
/////     estado : Valor entero {0 = OFF, 1 = ON}.
/////
///// Flujo general:
/////   1. Inicializa la interfaz con la FPGA.
/////   2. Envía el comando para modificar el estado del LED.
/////   3. Termina la ejecución.
/////
///// Dependencias:
/////   - `FPGA_de1soc.h`
/////
///// Nota:
/////   Este programa es usado por el servidor web para probar el LED de usuario.
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
    
	FPGA_de1soc fpga;
	fpga.switchLED(atoi(argv[1]));	

    return 0;
}


