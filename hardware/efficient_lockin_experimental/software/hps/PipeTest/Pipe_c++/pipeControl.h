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
            // Para enviar mensajes 
            myfifo1 = "/tmp/myfifo1";
            mkfifo(myfifo1, 0666);  

            // Para recibir mensajes
            myfifo2 = "/tmp/myfifo2";
            mkfifo(myfifo2, 0666); 
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
            myfifo1 -> Escribe c++ lee c#
            myfifo2 -> Escribe c# lee c++
        */

        const char * myfifo1;
        const char * myfifo2;
    
        void Enviar_int32(int numero)
        {
            char bytes [4];

            for (int i =0;i<4;i++){
                bytes[i] = (numero >> 8*i) & (0xFF);
            }
            Enviar(bytes,4);
        }

        void Enviar_int64(long long int numero)
        {
            char bytes [8];

            for (int i =0;i<8;i++){
                bytes[i] = (numero >> 8*i) & (0xFF);
            }
            Enviar(bytes,8);
        }

        void Enviar(char * bytes_to_send , int num_bytes )
        {
            int fd;
            fd = open(myfifo1, O_WRONLY); 
            write(fd, bytes_to_send,num_bytes);    
            close(fd);
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