using System;
using System.IO;
using System.IO.Pipes;
using System.Text;
using System.Threading;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;


namespace pipe_test
{
    internal class Program
    {
        static bool block_async;
        static bool is_running;
        static Queue<long> datos_recibidos64;
        static Thread thread;

        static void Main(string[] args)
        {

            datos_recibidos64 = new Queue<long>();
            thread = new Thread(new ThreadStart(managePipe));
            thread.Start();

            while (true)
            {

            }

        }

        static private void managePipe()
        {
            NamedPipeClientStream client;

            string fifo_name3 = "/tmp/myfifo3";
            client = new NamedPipeClientStream(".", fifo_name3, PipeDirection.In);
            client.Connect();

            while (is_running)
            {
                if (!block_async)
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

        static private long Recibir_int64(NamedPipeClientStream client)
        {
            byte[] buffer = new byte[8];
            client.Read(buffer, 0, 8);
            return (BitConverter.ToInt64(buffer, 0));
        }

    }
}