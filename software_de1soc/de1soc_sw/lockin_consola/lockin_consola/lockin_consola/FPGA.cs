using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;



namespace lockin_consola
{
    public class FPGA
    {
        PipeControl pipe;

        // Comandos para controlar la cosa
        enum COMANDOS { RST , START, SET_CLK, SET_PARAM, GET_PARAM, RD_FIFO , RD_RESULT , SET_LOCKIN_FREC, TERMINATE = 99};
        public enum FUENTE_DATOS { ADC_2308 = 0, ADC_HS = 1, SIM = 2  };
        public enum PROC_MODE { CALI = 0, LI = 1 };
        public enum FIFO_DIRECTION {  F0_32, F1_32, F0_64, F1_64  };
        bool led_state;
        int led_base = 9;

            // C# le manda enteros de 32 bits a C++. Cada una es una instruccion. Una o mas instrucciones son un comando
            // RST -> Reinicia todo ( rst = 1)
            // START -> Empieza a adquirir y procesar (enable = 1)
            // SET_CLK VALUE -> Setea el clock al valor en value (en kHz)
            // SET_PARAM OFFSET VALUE -> Setea VALUE en el parametro OFFSET
            // GET_PARAM OFFSET -> Obtiene el parametro en OFFSET
            // RD_FIFO NUM -> Lee el FIFO NUM que es del tipo enum fifo_direction (son 4 fifos 2 de 32b y 2 de 64b)
            // RD_RESULT NUM -> Lee el ultimo resultado en el bus NUM del tipo enum FIFO_DIRECTION
            // SET_LOCKIN_FREC FREC M -> Setea el clock del lockin 
            // TERMINATE -> Finaliza el programa

        public FPGA()
        {
            pipe = new PipeControl();
            led_state = false;
        }

        public void Start()
        {
            EnviarComando(COMANDOS.START);
            return;
        }

        public void Reset()
        {
            EnviarComando(COMANDOS.RST);
            return;
        }

        public void set_clk(int value)
        {
            EnviarComando(COMANDOS.SET_CLK);
            EnviarValor(value);
            Thread.Sleep(2000);
            return;
        }

        public void set_lockin_frec(int value,int M)
        {
            EnviarComando(COMANDOS.SET_LOCKIN_FREC);
            EnviarValor(value);
            EnviarValor(M);
            Thread.Sleep(2000);
            return;
        }

        public void set_param(int param_index, int value)
        {
            EnviarComando(COMANDOS.SET_PARAM);
            EnviarValor(param_index);
            EnviarValor(value);
            return;
        }

        public long get_param(int param_index)
        {
            EnviarComando(COMANDOS.GET_PARAM);
            EnviarValor(param_index);
            return RecibirComando();
        }

        public void set_fuente_datos(FUENTE_DATOS fuente_datos)
        {
            set_param(0, (int)fuente_datos);
        }

        public void set_processing_mode(PROC_MODE procesing_mode )
        {
            set_param(5, (int)procesing_mode);
        }


        public void Terminate(){
            EnviarComando(COMANDOS.TERMINATE);
            Thread.Sleep(10);
            pipe.Terminate();
            return;
        }

        public void set_N_param ( int start_index ,  List <int> parametros  )
        {
            int param_index = start_index;
            foreach (int param in parametros)
            {
                set_param( param_index, param );
                param_index++;                                
            }
            return; 
        }
        
        
        public List <int> get_from_fifo_32 (FIFO_DIRECTION fifo_direction, int N)
        {
            EnviarComando(COMANDOS.RD_FIFO);
            EnviarValor((int)fifo_direction);
            EnviarValor((int)N);

            return pipe.Recibir32_N(N);
        }

        public List<long> get_from_fifo_64(FIFO_DIRECTION fifo_direction, int N)
        {
            EnviarComando(COMANDOS.RD_FIFO);
            EnviarValor((int)fifo_direction);
            EnviarValor((int)N);

            return pipe.Recibir64_N(N);
        }

        public long get_result_64(FIFO_DIRECTION fifo_direction)
        {
            EnviarComando(COMANDOS.RD_RESULT);
            EnviarValor((int)fifo_direction);

            return pipe.Recibir64(); 

        }

        public void Toggle_led()
        {
            led_state = !led_state;
            set_param(led_base, (led_state) ? 1 : 0);
            return;
        }

        private void EnviarComando(COMANDOS command)
        {
            pipe.Enviar((int)command);
            return;
        }

        private void EnviarValor(int value)
        {
            pipe.Enviar((int)value);
            return;
        }

        private int RecibirComando()
        {
            return pipe.Recibir32();
        }
    }
}


