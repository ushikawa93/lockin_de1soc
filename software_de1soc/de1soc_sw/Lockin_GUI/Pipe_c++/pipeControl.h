/******************************************************************************
* Clase: pipeControl
* Archivo: pipeControl.h / pipeControl.cpp
* Autor: [Tu Nombre]
* Fecha: [Fecha Actual]
* Descripción:
*   Implementa la comunicación entre C++ y C# mediante FIFOs (pipes) en Linux.
*   Permite enviar y recibir valores de 32 y 64 bits usando los FIFOs:
*       - myfifo1 -> escribe C++ y lee C#
*       - myfifo2 -> escribe C# y lee C++
*
*   Funcionalidades principales:
*       - Enviar(int)        : envía un entero de 32 bits al FIFO.
*       - Enviar(long long)  : envía un entero de 64 bits al FIFO.
*       - Recibir32()        : recibe un entero de 32 bits desde el FIFO.
*       - Recibir64()        : recibe un entero de 64 bits desde el FIFO.
*
*   La clase se encarga de:
*       - Crear los FIFOs si no existen (mkfifo).
*       - Convertir los enteros a bytes y viceversa.
*       - Abrir, escribir/leer y cerrar los FIFOs en cada operación.
*
* Notas:
*   - La conversión de enteros asume sistema little-endian.
*   - No mantiene los FIFOs abiertos permanentemente, lo que simplifica el código
*     pero puede ser menos eficiente para muchas operaciones consecutivas.
*   - Para valores de 64 bits, se usa long long int.
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

class pipeControl
{

    public:
        pipeControl()
        {
            // Para enviar mensajes de 32 bits
            myfifo1 = "/tmp/myfifo1";
            mkfifo(myfifo1, 0666);  

            // Para recibir mensajes
            myfifo2 = "/tmp/myfifo2";
            mkfifo(myfifo2, 0666); 

            // Para enviar mensajes de 64 bits
            myfifo3 = "/tmp/myfifo3";
            mkfifo(myfifo3, 0666);  
        }

        void Enviar(int numero)
        {
            Enviar_int32(numero);
        }

        void Enviar(long long int numero)
        {
            Enviar_int64(numero);
        }

        int Recibir32()
        {
            return Recibir_int32();
        }

        long long int Recibir64()
        {
            return Recibir_int64();
        }

    private:

        /*
            myfifo1 -> Escribe c++ lee c# (32 bits)
            myfifo2 -> Escribe c# lee c++
            myfifo3 -> Escribe c++ lee c# (64 bits)
        */

        const char * myfifo1;
        const char * myfifo2;
        const char * myfifo3;
    
        void Enviar_int32(int numero)
        {
            char bytes [4];

            for (int i =0;i<4;i++){
                bytes[i] = (numero >> 8*i) & (0xFF);
            }
            Enviar(bytes,4,1);
        }

        void Enviar_int64(long long int numero)
        {
            char bytes [8];

            for (int i =0;i<8;i++){
                bytes[i] = (numero >> 8*i) & (0xFF);
            }
            Enviar(bytes,8,3);
        }

        void Enviar(char * bytes_to_send , int num_bytes , int fifo )
        {
            if(fifo == 1)
            {
                int fd;
                fd = open(myfifo1, O_WRONLY); 
                write(fd, bytes_to_send,num_bytes);    
                close(fd);
            }
            else if(fifo == 3)
            {
                int fd;
                fd = open(myfifo3, O_WRONLY); 
                write(fd, bytes_to_send,num_bytes);    
                close(fd);
            }
           
        }

        int Recibir_int32 ()
        {
            return Recibir(4);
        }

        int Recibir_int64 ()
        {
            return Recibir(8);
        }

        int Recibir(int num_bytes)
        {
            int fd = open (myfifo2, O_RDONLY);
            char array [num_bytes];
            read(fd,array,num_bytes);
            close(fd);

            int num = 0;
            for (int i = 0; i < num_bytes ; i++){
                num = num | (array[i] << 8*i);
            }

            return num;
        }


};