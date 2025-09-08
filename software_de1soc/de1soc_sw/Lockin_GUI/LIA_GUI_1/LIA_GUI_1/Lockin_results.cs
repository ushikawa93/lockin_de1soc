/* ***********************************************************************************
 * Clase: Lockin_results
 * Proyecto: LIA_GUI_1
 * 
 * Descripción:
 * ------------
 * Clase que encapsula los resultados de un lock-in digital, calculando magnitud (R) 
 * y fase (Φ) a partir de las componentes cartesianas X e Y.
 * 
 * Detalles de implementación:
 * ---------------------------
 * - Convierte las entradas `X` y `Y` en valores normalizados según el divisor `div`.
 * - Calcula la magnitud:
 *      R = sqrt(x² + y²) * 2 / amplitud_ref
 * - Calcula la fase:
 *      Φ = atan2(y, x) en grados.
 * - `amplitud_ref` fija en 32767 como valor de referencia de amplitud.
 * 
 * Uso:
 * ----
 *   var result = new Lockin_results(X, Y, div);
 *   double magnitud = result.R;
 *   double fase = result.Phi;
 * 
 ************************************************************************************/


using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LIA_GUI_1
{
    public class Lockin_results
    {
        double r, phi,x,y;
        double amplitud_ref = 32767;

        public Lockin_results(long X, long Y, int div)
        {
            x = (double)X / div;
            y = (double)Y / div;
            r = Math.Sqrt(Math.Pow(x, 2) + Math.Pow(y, 2)) * 2 / amplitud_ref;
            phi = Math.Atan2(y, x);
        }

        public double R
        {
            get { return r; }
        }
        public double Phi
        {
            get { return phi* 180/Math.PI; }
        }

     
    }
}
