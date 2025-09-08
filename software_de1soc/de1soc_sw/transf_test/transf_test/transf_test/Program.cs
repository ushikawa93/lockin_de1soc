/****************************************************************************************
 *  Proyecto:   Corrección de mediciones Lock-in con archivo de transferencia
 *  Archivo:    Program.cs
 *
 *  Descripción:
 *  --------------------------------------------------------------------
 *  Este programa lee el archivo "transferencia.dat" generado por el lock-in
 *  (contiene frecuencia, X, Y, amplitud R y fase Φ para cada punto de calibración)
 *  y lo utiliza para corregir nuevas mediciones.
 *
 *  Flujo principal:
 *    1. Leer y parsear "transferencia.dat".
 *    2. Almacenar frecuencias, amplitudes y fases en listas.
 *    3. Buscar la frecuencia más cercana a la de la nueva medición.
 *    4. Calcular valores corregidos:
 *         - Amplitud corregida: R_corr = R_medido * R_guardada(0) / R_guardada(i)
 *         - Fase corregida:     φ_corr = φ_medido - φ_guardada(i)
 *    5. Mostrar resultados corregidos en consola.
 *
 *  Clases auxiliares:
 *    - Medicion: encapsula frecuencia, X, Y, R y Φ de cada línea del archivo.
 *
 *  Autor:    [Tu nombre / equipo]
 *  Fecha:    [dd/mm/aaaa]
 ****************************************************************************************/


using System;
using System.Collections.Generic;
using System.IO;
using System.Globalization; 

class Program
{
    static void Main()
    {
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
        int frec = 2000000;
        double phi_medido = 0;
        double r_medido = 7000;

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

        phi_medido = phi_medido - fases[indice];
        r_medido = r_medido * amplitudes[0] / amplitudes[indice];
        Console.WriteLine(frec.ToString() + "    " + phi_medido.ToString() + "   " + r_medido.ToString());


        Console.ReadKey();

        // Ahora tienes la lista de objetos DataItem
        // Puedes hacer lo que necesites con estos datos
    }
}



class Medicion
{
    public int Frequency { get; }
    public double X { get; }
    public double Y { get; }
    public double R { get; }
    public double Phi { get; }

    public Medicion(int frequency, double x, double y, double r, double phi)
    {
        Frequency = frequency;
        X = x;
        Y = y;
        R = r;
        Phi = phi;
    }

    public override string ToString()
    {
        return $"{Frequency};   {X};    {Y};    {R};    {Phi}";
    }
}