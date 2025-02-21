using System;
using System.IO;
using System.IO.Pipes;
using System.Text;
using System.Threading;

namespace Pipe_c_sharp
{
    class Program
    {
        static void Main(string[] args)
        {
            PipeControl pipeControl = new PipeControl();

            Console.Write("\nRecibido desde c++ (32 bit): ");
            Console.WriteLine(pipeControl.Recibir());

            pipeControl.Enviar(60);
                        
            bool led_state = true;
            int counter=0;
            while (counter <= 20)
            {
                led_state = !led_state;
                int led = (led_state) ? 1 : 0;
                pipeControl.Enviar(led);
                Thread.Sleep(100);
                counter++;
            }
            pipeControl.Terminate(2);

        }
        
    }
}
