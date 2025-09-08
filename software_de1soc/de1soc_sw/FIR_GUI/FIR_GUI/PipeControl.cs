/*
    PipeControl - Gestión de comunicación con la FPGA vía Named Pipes

    Descripción:
    ------------
    Esta clase administra la comunicación bidireccional entre C# y C++ usando
    named pipes en Linux. Se encarga de enviar comandos y datos hacia la FPGA
    y recibir respuestas o datos procesados desde ella.

    Funcionamiento:
    ---------------
    - Se crean dos hilos separados:
        * managePipe1: Lee datos desde el pipe "/tmp/myfifo1" (C++ escribe, C# lee)
        * managePipe2: Escribe datos en el pipe "/tmp/myfifo2" (C# escribe, C++ lee)
    - Se utilizan dos colas internas:
        * datos_a_enviar: Cola de enteros pendientes de envío al pipe.
        * datos_recibidos: Cola de enteros recibidos del pipe.
    - Los métodos Recibir y RecibirN bloquean la ejecución hasta que haya datos
      disponibles.
    - Los métodos Enviar y Enviar_int32/64 permiten enviar datos enteros de 32
      o 64 bits al pipe correspondiente.
    - El método Terminate aborta ambos hilos y cierra la comunicación.

    Notas:
    ------
    - Los hilos controlan el acceso mediante flags block_read y block_write
      para evitar colisiones durante la lectura/escritura de las colas.
    - Se emplean sleeps cortos (10 ms) para evitar saturar la CPU en el loop
      de escritura.
    - Actualmente, las funciones de 64 bits no se usan en la lógica principal,
      pero están implementadas para posibles FIFOs de 64 bits.
    - Los pipes se asumen creados en "/tmp/myfifo1" y "/tmp/myfifo2".
*/


using System;
using System.IO;
using System.IO.Pipes;
using System.Text;
using System.Threading;
using System.Collections.Generic;


namespace FIR_GUI
{
    public class PipeControl
    {
        /*
            myfifo1 -> Escribe c++ lee c#
            myfifo2 -> Escribe c# lee c++
         */


        Thread thread1, thread2;

        Queue<int> datos_a_enviar;
        Queue<int> datos_recibidos;
        bool block_read;
        bool block_write;

        public PipeControl()
        {
            datos_a_enviar = new Queue<int>();
            datos_recibidos = new Queue<int>();

            block_read = false;
            block_write = false;

            thread1 = new Thread(new ThreadStart(managePipe1));
            thread1.Start();

            thread2 = new Thread(new ThreadStart(managePipe2));
            thread2.Start();
        }

        public void Terminate()
        {
            thread1.Abort();
            thread2.Abort();
        }

        public int Recibir()
        {
            while (datos_recibidos.Count == 0) { }
            block_read = true;
            int dato = datos_recibidos.Dequeue();
            block_read = false;
            return dato;
        }
        
        public List<int> RecibirN(int N)
        {
            while (datos_recibidos.Count < N) { }
            block_read = true;
            List <int> datos = new List<int>();
            for (int i = 0; i < N; i++)
            {
                datos.Add(datos_recibidos.Dequeue());
            }
            block_read = false;
            return datos;
        }
        
        public void Enviar(int dato)
        {
            block_write = true;
            datos_a_enviar.Enqueue(dato);
            block_write = false;
            return;
        }

        private void managePipe1()
        {
            NamedPipeClientStream client;

            string fifo_name1 = "/tmp/myfifo1";
            client = new NamedPipeClientStream(".", fifo_name1, PipeDirection.In);
            client.Connect();

            while (true)
            {
                if (!block_read)
                {
                    int dato = Recibir_int32(client);
                    if(dato != 0)
                    {
                        datos_recibidos.Enqueue(dato);
                    }
                }
                
            }
        }


        private void managePipe2()
        {
            NamedPipeClientStream client;
            string fifo_name2 = "/tmp/myfifo2";
            client = new NamedPipeClientStream(".", fifo_name2, PipeDirection.Out);
            client.Connect();

            while (true)
            {
                if ((datos_a_enviar.Count != 0)&&(!block_write))
                {
                    Enviar_int32(client, datos_a_enviar.Dequeue());
                    Thread.Sleep(10);
                }
            }
        }

        private int Recibir_int32(NamedPipeClientStream client)
        {
            byte[] buffer = new byte[4];
            client.Read(buffer, 0, 4);
            return (BitConverter.ToInt32(buffer, 0));

        }

        private void Enviar_int32(NamedPipeClientStream client, int numero)
        {

            byte[] buffer = BitConverter.GetBytes(numero);
            client.Write(buffer, 0, buffer.Length);

        }

        private long Recibir_int64(NamedPipeClientStream client)
        {
            byte[] buffer = new byte[8];
            client.Read(buffer, 0, 8);
            return (BitConverter.ToInt64(buffer, 0));
        }

        private void Enviar_int64(NamedPipeClientStream client, long numero)
        {
            byte[] buffer = BitConverter.GetBytes(numero);
            client.Write(buffer, 0, buffer.Length);
        }


    }
}
