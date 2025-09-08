/*
================================================================================
 Clase PipeControl
================================================================================
 Propósito:
 ----------
 Manejar la comunicación entre el programa en C# y el proceso en C++ mediante 
 tres pipes nombrados en Linux (/tmp/myfifo1, /tmp/myfifo2, /tmp/myfifo3).

 Estructura de los pipes:
 ------------------------
 - myfifo1 → escribe C++ / lee C#   (32 bits)
 - myfifo2 → escribe C# / lee C++
 - myfifo3 → escribe C++ / lee C#   (64 bits)

 Funcionalidades principales:
 ----------------------------
 - Inicializa tres hilos (thread1, thread2, thread3) que administran cada pipe.
 - Encolar y desencolar datos de 32 y 64 bits en forma segura.
 - Enviar y recibir datos en bloques (N valores) o de a uno.
 - Manejar el cierre ordenado de los hilos con Terminate().

 Uso:
 ----
 Se crea una instancia de PipeControl, que automáticamente lanza los hilos 
 de comunicación.  
 Métodos públicos como Enviar(), Recibir32(), Recibir64() y sus variantes con N
 se utilizan para transferir datos entre C# y C++.

 Notas:
 ------
 - block_async se usa como flag para evitar condiciones de carrera.
 - Hay un tiempo de espera máximo (timeoutSeconds) para la recepción de datos
   de 64 bits.
================================================================================
*/


using System;
using System.IO;
using System.IO.Pipes;
using System.Text;
using System.Threading;
using System.Collections.Generic;
using System.Diagnostics;


namespace lockin_consola
{
    public class PipeControl
    {
        /*
            myfifo1 -> Escribe c++ lee c#   (32 bits)
            myfifo2 -> Escribe c# lee c++
            myfifo3 -> Escribe c++ lee c#   (64 bits)
         */


        Thread thread1, thread2, thread3;

        Queue<int> datos_a_enviar;
        Queue<int> datos_recibidos32;
        Queue<long> datos_recibidos64;
        bool block_async;        
        bool is_running;

        static int timeoutSeconds = 10;

        public PipeControl()
        {
            datos_a_enviar = new Queue<int>();
            datos_recibidos32 = new Queue<int>();
            datos_recibidos64 = new Queue<long>();

            block_async = false;           
            is_running = true;

            thread1 = new Thread(new ThreadStart(managePipe1));
            thread1.Start();

            thread2 = new Thread(new ThreadStart(managePipe2));
            thread2.Start();

            thread3 = new Thread(new ThreadStart(managePipe3));
            thread3.Start();
        }

        public void Terminate()
        {
            is_running = false;
            Thread.Sleep(100);
            thread1.Abort();
            thread2.Abort();
            thread3.Abort();
        }      
        
        public int Recibir32()
        {
            while (datos_recibidos32.Count == 0) { }
            block_async = true;
            int dato = (int)datos_recibidos32.Dequeue();
            block_async = false;
            Thread.Sleep(10);
            return dato;
        }

        public List<int> Recibir32_N(int N)
        {
            while (datos_recibidos32.Count < N) { }
            block_async = true;
            List<int> datos = new List<int>();
            for (int i = 0; i < N; i++)
            {
                datos.Add((int)datos_recibidos32.Dequeue());
            }
            block_async = false;
            Thread.Sleep(10);
            return datos;
        }

        public long Recibir64()
        {
            var stopwatch = new Stopwatch();
            stopwatch.Start();
            while (datos_recibidos64.Count == 0)
            {
                // Verifica si se ha superado el tiempo de espera
                if (stopwatch.Elapsed.TotalSeconds >= timeoutSeconds)
                {
                    Console.WriteLine("Se ha alcanzado el tiempo de espera.");
                    return 0;
                }
            }

            block_async = true;
            long dato = (long)datos_recibidos64.Dequeue();
            block_async = false;
            Thread.Sleep(10);
            return dato;
        }

        public List<long> Recibir64_N(int N)
        {
            while (datos_recibidos64.Count < N) { }
            block_async = true;
            List<long> datos = new List<long>();
            for (int i = 0; i < N; i++)
            {
                datos.Add((long)datos_recibidos64.Dequeue());
            }
            block_async = false;
            Thread.Sleep(10);
            return datos;
        }

        public void Enviar(int dato)
        {
            block_async = true;
            datos_a_enviar.Enqueue(dato);
            block_async = false;
            Thread.Sleep(10);
            return;
        }



        // ------------ Funciones que manejan los tres hilos que usan los PIPE -------------- //

        private void managePipe1()
        {
            NamedPipeClientStream client;

            string fifo_name1 = "/tmp/myfifo1";
            client = new NamedPipeClientStream(".", fifo_name1, PipeDirection.In);
            client.Connect();

            while (is_running)
            {
                if (!block_async)
                {
                    uint dato_recibido = Recibir_uint32(client);
                    int dato;
                    if (dato_recibido != 0)
                    {
                        
                        if (dato_recibido == 0xFFFFFFFF)
                        {
                            dato = 0;
                        }
                        else
                        {
                            dato = (int)dato_recibido;
                        }
                        datos_recibidos32.Enqueue(dato);
                    }
                }
                
            }
            client.Close();
        }


        private void managePipe2()
        {
            NamedPipeClientStream client;
            string fifo_name2 = "/tmp/myfifo2";
            client = new NamedPipeClientStream(".", fifo_name2, PipeDirection.Out);
            client.Connect();

            while (is_running)
            {
                if ((datos_a_enviar.Count != 0)&&(!block_async))
                {
                    int dato_enviado = datos_a_enviar.Dequeue();
                    Enviar_int32(client, dato_enviado);                
                }
            }
            client.Close();
        }

        private void managePipe3()
        {
            NamedPipeClientStream client;

            string fifo_name3 = "/tmp/myfifo3";
            client = new NamedPipeClientStream(".", fifo_name3, PipeDirection.In);
            client.Connect();

            while (is_running)
            {
                if (!block_async)
                {
                   ulong dato_recibido = Recibir_uint64(client);
                   long dato;
                   if (dato_recibido != 0)
                   {
                        
                        if(dato_recibido == 0xFFFFFFFFFFFFFFFF)
                        {
                            dato = 0;
                        }
                        else
                        {
                            dato = (long)dato_recibido;
                        }
                                                
                        datos_recibidos64.Enqueue(dato);
                   }
                }
            }
            client.Close();

        }

        private uint Recibir_uint32(NamedPipeClientStream client)
        {
            byte[] buffer = new byte[4];
            
            client.Read(buffer, 0, 4);
            
            return (BitConverter.ToUInt32(buffer, 0));

        }

        private void Enviar_int32(NamedPipeClientStream client, int numero)
        {

            byte[] buffer = BitConverter.GetBytes(numero);
            client.Write(buffer, 0, buffer.Length);

        }

        private ulong Recibir_uint64(NamedPipeClientStream client)
        {

            byte[] buffer = new byte[8];
            client.Read(buffer, 0, 8);
            return (BitConverter.ToUInt64(buffer, 0));
        }

        private void Enviar_int64(NamedPipeClientStream client, long numero)
        {
            byte[] buffer = BitConverter.GetBytes(numero);
            client.Write(buffer, 0, buffer.Length);
        }


    }
}
