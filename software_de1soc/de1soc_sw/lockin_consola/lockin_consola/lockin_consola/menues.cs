using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace lockin_consola
{
    public class menues
    {
        public static string Menu_principal() 
        {
            string menuOptions = "Opciones:\n" +
                     "1. Cambiar configuración\n" +
                     "2. Iniciar medida\n" +
                     "3. Ver N valores almacenados en memorias \n" +
                     "4. Barrido de frecuencias\n" +
                     "5. Barrido de constantes de tiempo\n" +
                     "6. Comparar resultados con CA y CA/LI \n" +
                     "7. Enviar datos a computadora HOST\n" +
                     //"8. Modificar archivo de calibración \n" +
                     "0. Salir\n"+
                     "Elija una opción:";
            return menuOptions;
        }

        public static string ConfiguracionActual(int N_ma_CALI, int N_ca_CALI,int N_LI, int M, int frec_lockin, int sim_noise, FPGA.FUENTE_DATOS fuente,string nombreArchivo,bool corregir_resultado, FPGA.PROC_MODE modo_procesamiento)
        {
            string lockinInfo = "------------ LOCKIN DE1SOC -------------\n" +
                     $"1. Fuente: {source(fuente, sim_noise)}\n" +
                     $"2. Frecuencia Lockin: {frec_lockin}\n" +
                     $"3. Modo de procesamiento: {mode(modo_procesamiento, N_ca_CALI, N_ma_CALI, N_LI)}\n" +
                     $"4. N_ca (ciclos promediados coherentemente CALI): {N_ca_CALI}\n" +
                     $"5. N_ma (largo de filtro de media movil CALI): {N_ma_CALI}\n" +
                     $"     Total CALI --> N: {N_ca_CALI* N_ma_CALI}   \n" +    
                     $"6. N (ciclos promediados LI \"puro\"): {N_LI}\n" +
                     $"7. M (PTS por ciclo de señal): {M}\n" +
                     $"8. Archivo de destino: {nombreArchivo}\n" +
                     
                     //$"9. Corregir efecto de etapa analógica: {(corregir_resultado? "Si":"No")}\n" +
                     "----------------------------------------\n";
            return lockinInfo;
        }

        public static string source(FPGA.FUENTE_DATOS fuente,int sim_noise)
        {
            return ((int)fuente == 0) ? "adc_2308" : ((int)fuente == 1) ? "Highspeed_ADC" : $"Simulacion con {sim_noise} bits de ruido";
        }

        public static string mode(FPGA.PROC_MODE modo, int N_ca,int N_ma, int N_li)
        {
            return ((int)modo == 0) ? $"CA de {N_ca} ciclos seguida de LI de {N_ma} ciclo " : $"LI de {N_li} ciclos";
        }
    }
}
