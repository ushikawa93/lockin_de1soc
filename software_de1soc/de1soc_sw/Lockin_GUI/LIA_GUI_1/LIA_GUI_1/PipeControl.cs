﻿/************************************************************************************
 * Clase: PipeControl
 * Proyecto: LIA_GUI_1
 * 
 * Descripción:
 * ------------
 * Clase que gestiona la comunicación entre C# y C++ mediante pipes con nombre 
 * (FIFOs). Se implementa un sistema de colas y tres hilos que controlan la 
 * transferencia de datos.
 * 
 * Canales FIFO:
 * -------------
 * - myfifo1: escribe C++ → lee C#  (32 bits)
 * - myfifo2: escribe C# → lee C++
 * - myfifo3: escribe C++ → lee C#  (64 bits)
 * 
 * Detalles de implementación:
 * ---------------------------
 * - Usa tres hilos independientes:
 *      - managePipe1: recepción de enteros de 32 bits.
 *      - managePipe2: envío de enteros de 32 bits.
 *      - managePipe3: recepción de enteros de 64 bits.
 * - Sincronización con flags (`block_read_*`, `block_write`) para evitar colisiones.
 * - Maneja colas en memoria:
 *      - datos_a_enviar      → enteros pendientes de envío.
 *      - datos_recibidos32   → enteros recibidos de 32 bits.
 *      - datos_recibidos64   → enteros recibidos de 64 bits.
 * - Métodos de acceso:
 *      - `Enviar(int dato)` → envía dato a C++.
 *      - `Recibir32()`, `Recibir32_N(N)` → recibe enteros de 32 bits.
 *      - `Recibir64()`, `Recibir64_N(N)` → recibe enteros de 64 bits.
 * - `Terminate()` detiene los hilos y finaliza la comunicación.
 * 
 * Uso:
 * ----
 *   var pipe = new PipeControl();
 *   pipe.Enviar(1234);
 *   int valor = pipe.Recibir32();
 * 
 ************************************************************************************/


using System;
using System.IO;
using System.IO.Pipes;
using System.Text;
using System.Threading;
using System.Collections.Generic;


namespace LIA_GUI_1
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
        bool block_read_32;
        bool block_read_64;
        bool block_write;
        bool is_running;

        public PipeControl()
        {
            datos_a_enviar = new Queue<int>();
            datos_recibidos32 = new Queue<int>();
            datos_recibidos64 = new Queue<long>();

            block_read_32 = false;
            block_read_64 = false;
            block_write = false;
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
            thread1.Abort();
            thread2.Abort();
            thread3.Abort();
        }

        public int Recibir32()
        {
            while (datos_recibidos32.Count == 0) { }
            block_read_32 = true;
            int dato = (int)datos_recibidos32.Dequeue();
            block_read_32 = false;
            Thread.Sleep(10);
            return dato;
        }        
        
        public List<int> Recibir32_N(int N)
        {
            while (datos_recibidos32.Count < N) { }
            block_read_32 = true;
            List <int> datos = new List<int>();
            for (int i = 0; i < N; i++)
            {
                datos.Add((int)datos_recibidos32.Dequeue());
            }
            block_read_32 = false;
            Thread.Sleep(10);
            return datos;
        }

        public long Recibir64()
        {
            while (datos_recibidos64.Count == 0) { }
            block_read_64 = true;
            long dato = (long)datos_recibidos64.Dequeue();
            block_read_64 = false;
            Thread.Sleep(10);
            return dato;
        }

        public List<long> Recibir64_N(int N)
        {
            while (datos_recibidos64.Count < N) { }
            block_read_64 = true;
            List<long> datos = new List<long>();
            for (int i = 0; i < N; i++)
            {
                datos.Add((long)datos_recibidos64.Dequeue());
            }
            block_read_64 = false;
            Thread.Sleep(10);
            return datos;
        }

        public void Enviar(int dato)
        {
            block_write = true;
            datos_a_enviar.Enqueue(dato);
            block_write = false;
            Thread.Sleep(10);
            return;
        }

        private void managePipe1()
        {
            NamedPipeClientStream client;

            string fifo_name1 = "/tmp/myfifo1";
            client = new NamedPipeClientStream(".", fifo_name1, PipeDirection.In);
            client.Connect();

            while (is_running)
            {
                if (!block_read_32)
                {
                    int dato = Recibir_int32(client);
                    if(dato != 0)
                    {
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
                if ((datos_a_enviar.Count != 0)&&(!block_write))
                {                    
                    Enviar_int32(client, datos_a_enviar.Dequeue());
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
                if (!block_read_64)
                {
                    long dato = Recibir_int64(client);
                    if (dato != 0)
                    {
                        datos_recibidos64.Enqueue(dato);
                    }
                }
            }
            client.Close();
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
