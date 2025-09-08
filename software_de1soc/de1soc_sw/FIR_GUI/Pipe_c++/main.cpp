/******************************************************************************
* Programa: main.cpp
* Autor: Matías Oliva
* Fecha: 2025
* Descripción:
*   Programa principal que corre en Linux y se comunica con C# a través de FIFOs
*   (pipes) para controlar la FPGA DE1-SoC. Recibe comandos desde C# y ejecuta 
*   las operaciones correspondientes en la FPGA, incluyendo:
*       - Reinicio (RST)
*       - Inicio de adquisición/procesamiento (START)
*       - Configuración del clock (SET_CLK)
*       - Configuración de parámetros (SET_PARAM)
*       - Lectura de parámetros (GET_PARAM)
*       - Lectura de FIFOs (RD_FIFO)
*       - Terminación del programa (TERMINATE)
*
*   Comunicación con C#:
*       - myfifo1: escribe C++ y lee C# 
*       - myfifo2: escribe C# y lee C++
*
*   La aplicación implementa un loop principal que espera comandos, decodifica
*   su tipo y ejecuta la acción correspondiente sobre la FPGA mediante la clase
*   FPGA_de1soc. La lectura/escritura de FIFOs se realiza usando la clase 
*   pipeControl.
*
* Enumeraciones:
*   - COMANDOS: RST, START, SET_CLK, SET_PARAM, GET_PARAM, RD_FIFO, ERROR, TERMINATE
*   - FIFO_DIRECTION: F0_32, F1_32, F0_64, F1_64, ERR
*
* Funciones auxiliares:
*   - DecodeComando(int value) -> COMANDOS: convierte un entero recibido de C#
*     al comando correspondiente.
*   - Decode_fifo_direction(int value) -> FIFO_DIRECTION: convierte un entero 
*     recibido de C# al FIFO correspondiente.
*
* Notas:
*   - Cada operación que involucra un FIFO abre, lee/escribe y cierra el FIFO
*     para simplicidad de implementación.
*   - Para lectura de FIFO de 64 bits se usa long long int.
*   - Se asume que el sistema es little-endian.
*   - La constante CLEAR_CONSOLE permite limpiar la consola (ANSI escape codes).
*   - N_CRUDOS define la cantidad de muestras crudas a procesar.
*   - RAW_FIFO_DEPTH define la profundidad de los FIFOs de la FPGA.
******************************************************************************/


#include <iostream>
#include <fstream>
#include <string>
#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>

#include "FPGA_de1soc.h"
#include "filters.h"
#include "pipeControl.h"

#define CLEAR_CONSOLE "\033[2J\033[1;1H"  // Mandando este valor a cout limpio la pantalla
#define N_CRUDOS 512
#define RAW_FIFO_DEPTH 8192

using namespace std;

// Comandos para controlar la cosa
enum COMANDOS { RST , START, SET_CLK, SET_PARAM, GET_PARAM, RD_FIFO , ERROR , TERMINATE = 99};
enum FIFO_DIRECTION {  F0_32, F1_32, F0_64, F1_64  , ERR };

// Para convertir enteros en los enumerables
COMANDOS DecodeComando(int value);
FIFO_DIRECTION Decode_fifo_direction(int value);


int main()
{    


    bool terminate = false;

    // C# me manda enteros de 32 bits. Cada una es una instruccion. Una o mas instrucciones son un comando
        // RST -> Reinicia todo ( rst = 1)
        // START -> Empieza a adquirir y procesar (enable = 1)
        // SET_CLK VALUE -> Setea el clock al valor en value (en kHz)
        // SET_PARAM OFFSET VALUE -> Setea VALUE en el parametro OFFSET
        // GET_PARAM OFFSET -> Obtiene el parametro en OFFSET
        // RD_FIFO NUM -> Lee el FIFO NUM que es del tipo enum FIFO_DIRECTION (son 4 fifos 2 de 32b y 2 de 64b)
        // TERMINATE -> Finaliza el programa

    // Inicializa los pipes y deja todo preparado para recibir desde C#
    pipeControl PipeControl;

    // Funciones para comunicacion con FPGA
    FPGA_de1soc fpga;   
    //fpga.set_clk_from_frec(65000);
    
    while(!terminate)
    {
        // Me quedo esperando a que venga algun comando desde C#
        COMANDOS command = DecodeComando ( PipeControl.Recibir32() );  // Conversion implicita ?
       
        switch (command)
        {
        case RST:
        {
            fpga.Reiniciar();
            break;
        }
        
        case START:
        {
            fpga.Comenzar();
            break;
        }

        case SET_CLK:
        {
            int value = PipeControl.Recibir32();
            fpga.set_clk_from_frec(value);
            break;
        }

        case SET_PARAM:
        {
            int offset = PipeControl.Recibir32();
            int value = PipeControl.Recibir32();
            fpga.set_parameter(value,offset);
            break;    
        }

        case GET_PARAM:
        {
            int offset = PipeControl.Recibir32();
            int value = fpga.get_parameter(offset);
            PipeControl.Enviar(value);
            break;    
        }

        case RD_FIFO:
        {
            FIFO_DIRECTION num = Decode_fifo_direction ( PipeControl.Recibir32() );
            int N = PipeControl.Recibir32() ;

            switch (num)
            {
            case F0_32:
            {   
                for (int i=0;i<N;i++)
                {
                    PipeControl.Enviar(fpga.LeerFIFO32individual(0));   
                }                            
                break;
            }
            case F1_32:
            {
                for (int i=0;i<N;i++)
                {
                    PipeControl.Enviar(fpga.LeerFIFO32individual(1));   
                }            
                break;
            }

            case F0_64:
            {
                long long int value = fpga.LeerFIFO64individual(0);
                PipeControl.Enviar(value);
                break;
            }
            case F1_64:
            {
                long long int value = fpga.LeerFIFO64individual(1);
                PipeControl.Enviar(value);
                break;
            }
            default:
                break;
            }
            break;    
        }
        case TERMINATE:
        {
            fpga.Reiniciar();
            terminate = true;
            break;    
        }            

        default:        
            break;
        }      
    }
   

    return 0;
}

 // RST -> Reinicia todo ( rst = 1)
        // START -> Empieza a adquirir y procesar (enable = 1)
        // SET_CLK VALUE -> Setea el clock al valor en value (en kHz)
        // SET_PARAM OFFSET VALUE -> Setea VALUE en el parametro OFFSET
        // GET_PARAM OFFSET -> Obtiene el parametro en OFFSET
        // RD_FIFO NUM -> Lee el FIFO NUM que es del tipo enum FIFO_DIRECTION (son 4 fifos 2 de 32b y 2 de 64b)
        // TERMINATE -> Finaliza el programa

COMANDOS DecodeComando(int value)
{
    switch(value)
    {
        case 0:
            return RST;break;
        case 1:
            return START;break;
        case 2:
            return SET_CLK;break;
        case 3:
            return SET_PARAM;break;
        case 4:
            return GET_PARAM;break;
        case 5:
            return RD_FIFO;break;
        case 99:
            return TERMINATE;break;
        default:
            return ERROR;break;

    }
}

FIFO_DIRECTION Decode_fifo_direction(int value)
{
    switch(value)
    {
        case 0:
            return F0_32;break;
        case 1:
            return F1_32;break;
        case 2:
            return F0_64;break;
        case 3:
            return F1_64;break;
        default:
            return ERR;break;

    }
}
