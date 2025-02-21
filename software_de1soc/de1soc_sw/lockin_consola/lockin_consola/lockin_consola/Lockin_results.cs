using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Runtime.InteropServices.ComTypes;

namespace lockin_consola
{
    public class Lockin_results
    {
        double r, phi, x, y;
        double amplitud_ref = 32767;

        public Lockin_results(long X, long Y, int div, int frec, bool corregir)
        {
            x = (double)X / div;
            y = (double)Y / div;
            r = Math.Sqrt(Math.Pow(x, 2) + Math.Pow(y, 2)) * 2 / amplitud_ref;
            phi = Math.Atan2(y, x);

            if (corregir)
            {
                corregirResultados(frec);
            }
        }

        public double R
        {
            get { return r; }
        }
        public double Phi
        {
            get { return phi * 180 / Math.PI; }
        }
        public double X
        {
            get { return x; }
        }
        public double Y
        {
            get { return y; }
        }
        public override string ToString()
        {
            return "X: " + X.ToString() + Environment.NewLine +
                   "Y: " + Y.ToString() + Environment.NewLine +
                   "R: " + R.ToString("F4") + Environment.NewLine +
                   "PHI: " + Phi.ToString("F4");
        }


        // La parte analogica me mete algunas cosas raras. Con esto lo corrigo ad-hoc
        private void corregirResultados(double frec)
        {
            // Para bajas frecuencias no hay nada que corregir
            if (frec < 10000)
            {
                return;
            }

            // Levanto la transferencia obtenida con el lockin "en corto"
            string filePath = "transferencia.dat"; // Reemplaza con la ruta de tu archivo

            List<int> frecuencias = new List<int>();
            List<double> amplitudes = new List<double>();
            List<double> fases = new List<double>();

            // Crear una CultureInfo con punto como separador decimal
            CultureInfo cultureInfo = new CultureInfo("en-US");

            // Leemos el archivo línea por línea
            string[] lines = File.ReadAllLines(filePath);

            foreach (string line in lines)
            {
                string[] parts = line.Split(',');

                if (parts.Length == 5)
                {
                    if (int.TryParse(parts[0], out int frequency) &&
                        double.TryParse(parts[1], NumberStyles.Float, cultureInfo, out double x) &&
                        double.TryParse(parts[2], NumberStyles.Float, cultureInfo, out double y) &&
                        double.TryParse(parts[3], NumberStyles.Float, cultureInfo, out double r) &&
                        double.TryParse(parts[4], NumberStyles.Float, cultureInfo, out double phi))
                    {
                        frecuencias.Add(frequency);
                        amplitudes.Add(r);
                        fases.Add(phi);

                    }
                }
            }

            // Encontrar la frecuencia mas cercana de la lista y corregir con eso:
            // R = R_medida * R_guardada(0) / R_guardada(i)
            // phi = phi_medida - phi_guardada

            // Inicializar variables para realizar un seguimiento del número más cercano y su diferencia
            int frec_mas_cercana = frecuencias[0];
            double diferenciaMinima = Math.Abs(frec - frec_mas_cercana);
            
            foreach (int f in frecuencias)
            {
                

                double diferencia = Math.Abs(frec - f);
                if (diferencia < diferenciaMinima)
                {
                    diferenciaMinima = diferencia;
                    frec_mas_cercana = f;
                }          
            }

            int indice = frecuencias.IndexOf(frec_mas_cercana);
            
            phi = phi - fases[indice]*Math.PI/180;
            r = r * amplitudes[0] / amplitudes[indice];

            //Console.WriteLine($"Corrigiendo con valor a frecuencia: {frec_mas_cercana} (phi: {fases[indice]}, r = {amplitudes[indice]})");


            return;

        }



    }
}
