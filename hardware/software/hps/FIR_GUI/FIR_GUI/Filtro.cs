/*
    Filtro - Representación de un filtro FIR individual

    Descripción:
    ------------
    Esta clase encapsula la información de un filtro FIR específico, incluyendo
    sus coeficientes, tipo y frecuencia de muestreo.

    Propiedades y Funciones:
    -----------------------
    - F_muestreo: Permite obtener o establecer la frecuencia de muestreo del filtro.
    - F_corte: Calcula la frecuencia de corte real del filtro a partir de su 
      frecuencia normalizada y la frecuencia de muestreo.
    - Coeficientes: Lista de coeficientes enteros que definen la respuesta del filtro.
    - TipoFiltro: Indica si el filtro es Pasa-bajos (PB), Pasa-altos (PA) o Bypass.
    - ToString(): Retorna una descripción legible del filtro, incluyendo tipo,
      orden (cantidad de coeficientes - 1) y frecuencia de corte.

    Notas:
    ------
    - Los coeficientes se asumen en formato entero y listos para ser enviados
      a la FPGA.
    - La frecuencia de corte se calcula en kHz.
    - Los filtros de tipo BYPASS simplemente indican que no se aplica procesamiento.
*/


using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace FIR_GUI
{
    public class Filtro
    {
        double f_muestreo;
        double fc_normalizada;
        List<int> coeficientes;
        TIPOS_FILTRO tipo_filtro;

        public enum TIPOS_FILTRO { PA, PB, BYPASS };

        public Filtro(List<int> coef, double f_muestreo_i, double fc_normalizada_i, TIPOS_FILTRO tipo)
        {
            fc_normalizada = fc_normalizada_i;
            f_muestreo = f_muestreo_i;
            coeficientes = coef;
            tipo_filtro = tipo;
        }

        public double F_muestreo
        {
            set
            {
                f_muestreo = value;
            }
            get
            {
                return f_muestreo;
            }

        }

        public double F_corte
        {
            get
            {
                return (double)fc_normalizada * (double)f_muestreo / (double)2;
            }
        }

        public List<int> Coeficientes
        {
            get
            {
                return coeficientes;
            }
            set
            {
                coeficientes = value;
            }
        }

        public TIPOS_FILTRO TipoFiltro
        {
            get
            {
                return tipo_filtro;
            }
        }

        public override string ToString()
        {
            if (tipo_filtro == TIPOS_FILTRO.BYPASS)
            {
                return "Bypass processing";
            }
            else
            {
                string tipo = (tipo_filtro == TIPOS_FILTRO.PA) ? "PA" : (tipo_filtro == TIPOS_FILTRO.PB) ? "PB" : "";
                return "Filter: " + tipo + ". Order: " + (coeficientes.Count() - 1).ToString() + ". Cutoff freq: " + F_corte.ToString() + " kHz";
            }
            
        }


    }
}
