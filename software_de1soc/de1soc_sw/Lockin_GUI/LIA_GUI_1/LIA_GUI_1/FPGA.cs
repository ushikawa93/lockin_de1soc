/****************************************************************************************
 *  Proyecto:   LIA_GUI_1 - Control del Lock-in Amplifier en FPGA
 *  Archivo:    FPGA.cs
 *
 *  Descripción:
 *  --------------------------------------------------------------------
 *  Clase de alto nivel que abstrae la comunicación con la FPGA a través de 
 *  un objeto PipeControl. Define y envía comandos específicos para configurar 
 *  y controlar el procesamiento lock-in.
 *
 *  Comandos implementados (enum COMANDOS):
 *    - RST              → Reinicia la FPGA.
 *    - START            → Inicia la adquisición y procesamiento.
 *    - SET_CLK          → Configura la frecuencia de reloj (kHz).
 *    - SET_PARAM        → Setea un parámetro en una posición de memoria.
 *    - GET_PARAM        → Lee el valor de un parámetro.
 *    - RD_FIFO          → Lee N datos de un FIFO (32 o 64 bits).
 *    - RD_RESULT        → Obtiene el último resultado desde un FIFO.
 *    - SET_LOCKIN_FREC  → Configura la frecuencia de muestreo del lock-in.
 *    - TERMINATE        → Finaliza la comunicación con la FPGA.
 *
 *  Funcionalidades principales:
 *    - Configuración de parámetros individuales o múltiples (set_param, set_N_param).
 *    - Control del reloj y frecuencia del lock-in.
 *    - Lectura de resultados de 32 y 64 bits desde FIFOs.
 *    - Encendido/apagado de LED de prueba en la FPGA.
 *    - Métodos auxiliares privados para enviar/recibir comandos y valores.
 *
 *  Autor:    [Tu nombre / equipo]
 *  Fecha:    [dd/mm/aaaa]
 ****************************************************************************************/


using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;



namespace LIA_GUI_1
{
    public class FPGA
    {
        PipeControl pipe;

        // Comandos para controlar la cosa
        enum COMANDOS { RST , START, SET_CLK, SET_PARAM, GET_PARAM, RD_FIFO , RD_RESULT , SET_LOCKIN_FREC, TERMINATE = 99};
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


