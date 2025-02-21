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
