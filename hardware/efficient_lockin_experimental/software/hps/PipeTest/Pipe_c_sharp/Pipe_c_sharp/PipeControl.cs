using System;
using System.IO;
using System.IO.Pipes;
using System.Text;
using System.Threading;
using System.Collections.Generic;


namespace Pipe_c_sharp
{
    public class PipeControl
    {
        /*
            myfifo1 -> Escribe c++ lee c#
            myfifo2 -> Escribe c# lee c++
         */


        Thread thread1, thread2;

        Queue <int> datos_a_enviar;
        Queue <int> datos_recibidos;


        public PipeControl()
        {
            datos_a_enviar = new Queue <int>();
            datos_recibidos = new Queue <int>();

            thread1 = new Thread(new ThreadStart(managePipe1));
            thread1.Start();

            thread2 = new Thread(new ThreadStart(managePipe2));
            thread2.Start();
        }

        public void Terminate(int command)
        {
            Enviar(command);
            thread1.Abort();
            thread2.Abort();
        }   

        public int Recibir()
        {
            while (datos_recibidos.Count == 0) { }
            int dato = datos_recibidos.Dequeue();
            return dato;            
        }

        public void Enviar(int dato)
        {
            datos_a_enviar.Enqueue(dato);
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
                datos_recibidos.Enqueue ( Recibir_int32(client) );
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
                if(datos_a_enviar.Count != 0)
                {
                    Enviar_int32(client, datos_a_enviar.Dequeue());                    
                }         
            }
        }

        private int Recibir_int32(NamedPipeClientStream client)
        {
            byte[] buffer = new byte[4];
            client.Read(buffer, 0, 4);
            return (BitConverter.ToInt32(buffer, 0));

        }

        private void Enviar_int32(NamedPipeClientStream client,int numero)
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

        private void Enviar_int64(NamedPipeClientStream client,long numero)
        {
            byte[] buffer = BitConverter.GetBytes(numero);
            client.Write(buffer, 0, buffer.Length);
        }


    }
}
