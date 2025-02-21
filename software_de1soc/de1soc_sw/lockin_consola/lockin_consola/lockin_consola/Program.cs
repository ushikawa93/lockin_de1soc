using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Diagnostics;
using System.Xml.Linq;
using System.Runtime.Remoting.Messaging;
using System.Threading;

namespace lockin_consola
{
    internal class Program
    {
        // Parametros reconfigurables
        //.parameter_out_0				(fuente_procesamiento), -> 0 adc_2308 // 1 adc_hs // 2 simulacion
        //.parameter_out_1				(M),
        //.parameter_out_2				(N_ma_CALI),
        //.parameter_out_3				(N_ca_CALI),
        //.parameter_out_4				(sim_noise),
        //.parameter_out_5              (seleccion_resultado),
        //.parameter_out_6              (N_LI),
        //.parameter_out_9				(led_test),

        // Valores por defecho de los parametros:
        static int N_ma_CALI, N_ca_CALI, N_LI, M, frec_lockin, sim_noise, N_adc_values;
        static FPGA fpga;
        static string nombreArchivo = "datos.dat";
        static bool corregir_resultado = false;

        static FPGA.FUENTE_DATOS fuente;
        static FPGA.PROC_MODE modo_procesamiento;

        static void Main(string[] args)
        {
            fuente = FPGA.FUENTE_DATOS.ADC_HS;
            modo_procesamiento = FPGA.PROC_MODE.CALI;
            frec_lockin = 2000000;
            N_ma_CALI = 1;
            N_ca_CALI = 64;
            N_LI = 64;
            M = 32;
            sim_noise = 4;
            N_adc_values = 128;

            // La clase FPGA se encarga de la comunicacion con el programa c++ que maneja la FPGA
            fpga = new FPGA();
            configure(true);

            bool exit = false;
            while (!exit)
            {
                Console.Clear();
                Console.WriteLine(menues.ConfiguracionActual(N_ma_CALI, N_ca_CALI, N_LI, M, frec_lockin, sim_noise, fuente, nombreArchivo, corregir_resultado,modo_procesamiento));
                Console.WriteLine(menues.Menu_principal());

                int choice;
                try { choice = int.Parse(Console.ReadLine()); } catch { choice = 99; };

                switch (choice)
                {

                    case 1:
                        // Cambiar algun valor de la configuracion del dispositivo
                        CambiarConfiguracion();
                        Console.WriteLine("Configuracion actualizada");
                        break;

                    case 2:
                        // Calcular valor del lockin para esta configuracion
                        Lockin_results lia_results = Measure();
                        Console.WriteLine(lia_results.ToString());
                        addToArchivo(lia_results);
                        Console.ReadKey();
                        break;

                    case 3:
                        // Imprimir valores almacenados en memoria

                        Console.WriteLine("Ingrese número de memoria (0 -> FIFO_0_32b | 1 -> FIFO_1_32b | 2 -> FIFO_0_64b | 3 -> FIFO_1_64b)");
                        int select;
                        try { select = int.Parse(Console.ReadLine()); } catch { select = 0; };

                        ImprimirMemoria(select);

                        break;

                    case 4:
                        // Hace un barrido en frecuencia y guarda la info en un archivo
                        BarridoEnFrecuencia();
                        break;

                    case 5:
                        // Hace calculos para muchos N y guarda la info en un archivo
                        Barrido_cte_de_tiempo();
                        break;

                    case 6:
                        // Hace calculos para muchos N y guarda la info en un archivo
                        Comparar_resultados();
                        break;

                    case 7:
                        // Envía alguno de los archivos obtenidos a la computadora HOST
                        send2pc.EnviarArchivo();
                        break;
                    case 8:
                        ModificarArchivoCalibracion();
                        break;

                    case 0:
                        // Finaliza la operacion
                        Console.Clear();
                        exit = true;
                        break;

                    default:
                        Console.WriteLine("Opción no válida. Intente nuevamente.");
                        break;
                }

            }


            fpga.Terminate();
        }





        static void CambiarConfiguracion()
        {
            int num;
            bool cambiar_frec= false;
            try
            {
                string opcional = ((int)fuente == 2) ? "(10 para modificar bits de ruido)" : "";
                Console.Write("Ingrese numero de la variable a modificar" + opcional + ": ");
                {
                    num = int.Parse(Console.ReadLine());
                }

                switch (num)
                {
                    case 1:
                        Console.Write("Nuevo valor para Fuente: (0: adc_2305 | 1: adc_hs | 2: simulacion) ");
                        fuente = (FPGA.FUENTE_DATOS)int.Parse(Console.ReadLine());
                        break;

                    case 2:
                        Console.Write("Nuevo valor para Frecuencia Lockin: ");
                        cambiar_frec = true;
                        frec_lockin = int.Parse(Console.ReadLine());
                        break;

                    case 3:
                        Console.WriteLine("Nuevo valor para modo de funcionamiento: ( 0: CA_LI | 1: LI )");
                        modo_procesamiento = (FPGA.PROC_MODE)int.Parse(Console.ReadLine());
                        break;

                    // Solo cambio N_ca y N_ma lo escondo (ya vimos que es lo mas eficiente)
                    case 4:
                        Console.Write("Nuevo valor para N_ca (CALI): ");
                        N_ca_CALI = int.Parse(Console.ReadLine());
                        break;

                    case 5:
                        Console.Write("Nuevo valor para N_ma (CALI): ");
                        N_ma_CALI = int.Parse(Console.ReadLine());
                        break;

                    case 6:
                        Console.Write("Nuevo valor para N (LI): ");
                        N_LI = int.Parse(Console.ReadLine());
                        break;

                    case 7:
                        Console.Write("Nuevo valor para M: ");
                        M = int.Parse(Console.ReadLine());
                        break;

                    case 8:
                        Console.Write("Nuevo nombre del archivo destino: ");
                        nombreArchivo = Console.ReadLine();
                        break;
                                           

                    case 9:
                        corregir_resultado = !corregir_resultado;
                        break;

                    case 10:
                        Console.Write("Nuevo valor para Simulación de Ruido: ");
                        sim_noise = int.Parse(Console.ReadLine());
                        break;
                    default:
                        Console.WriteLine("La opción ingresada no es válida");
                        break;
                }
            }
            catch { Console.WriteLine("Error ingresando datos"); }


            Console.WriteLine("Espere...");
            configure(cambiar_frec);
        }


        static void configure(bool configure_frec)
        {
            if(configure_frec)
            {
                fpga.set_lockin_frec(frec_lockin, M);
            }
            
            fpga.set_param(1, M);
            fpga.set_param(2, N_ma_CALI);
            fpga.set_param(3, N_ca_CALI);
            fpga.set_param(4, sim_noise);
            fpga.set_param(6, N_LI);
            
            fpga.set_fuente_datos(fuente);
            fpga.set_processing_mode(modo_procesamiento);
            
        }

        static Lockin_results Measure()
        {
            fpga.Reset();
            fpga.Start();
            long X = fpga.get_result_64(FPGA.FIFO_DIRECTION.F0_64);
            long Y = fpga.get_result_64(FPGA.FIFO_DIRECTION.F1_64);

            Lockin_results lia_results = new Lockin_results(X, Y, N_ma_CALI * N_ca_CALI * M, frec_lockin, corregir_resultado);
            return lia_results;
        }

        static void ImprimirMemoria(int select)
        {
            fpga.set_processing_mode(FPGA.PROC_MODE.CALI);
            switch (select)
            {
                case 0:
                    Acquire(N_adc_values, FPGA.FIFO_DIRECTION.F0_32);
                    break;
                case 1:
                    Acquire(N_adc_values, FPGA.FIFO_DIRECTION.F1_32);
                    break;
                case 2:
                    Acquire_long(N_adc_values, FPGA.FIFO_DIRECTION.F0_64);
                    break;
                case 3:
                    Acquire_long(N_adc_values, FPGA.FIFO_DIRECTION.F1_64);
                    break;
            }

        }

        static void Acquire(int N,FPGA.FIFO_DIRECTION dir)
        {
            fpga.Reset();
            fpga.Start();
            List<int> datos = fpga.get_from_fifo_32(dir,N);
            Console.WriteLine("Almacenado en memoria:");
            foreach (long i in datos)
            {
                Console.Write(i + ", ");
            }

            Console.ReadKey();
        }

        static void Acquire_long(int N, FPGA.FIFO_DIRECTION dir)
        {
            fpga.Reset();
            fpga.Start();
            List<long> datos = fpga.get_from_fifo_64(dir, N);
            Console.WriteLine("Almacenado en memoria:");
            foreach (long i in datos)
            {
                Console.Write(i + ", ");
            }
            
            Console.ReadKey();

        }        


        static string state()
        {
            return $"Frec: {frec_lockin} | N: {N_ca_CALI * N_ma_CALI} | Fuente: {menues.source(fuente,sim_noise)} " +  Environment.NewLine;

        }

        static void addToArchivo(Lockin_results lia_results)
        {
            using (StreamWriter writer = new StreamWriter("results/" + nombreArchivo, true))
            {
                writer.WriteLine("-----------------------------------------------");
                writer.Write(state());
                writer.WriteLine(lia_results.ToString());
                writer.Write('\n');
            }

        }

        static void BarridoEnFrecuencia()
        {
            Console.Clear();
            Console.WriteLine($"Ingrese: \n1: {menues.mode(FPGA.PROC_MODE.CALI,N_ca_CALI, N_ma_CALI, N_LI)} \n2: {menues.mode(FPGA.PROC_MODE.LI,N_ca_CALI, N_ma_CALI, N_LI)} \n3: Ambos procesamientos en simultaneo \n0: Volver al menu principal");

            int choice;
            try { choice = int.Parse(Console.ReadLine()); } catch { choice = 99; };

            switch (choice)
            {
                case 1:
                    fpga.set_processing_mode(FPGA.PROC_MODE.CALI);
                    BarridoUnico();
                    break;
                case 2:
                    fpga.set_processing_mode(FPGA.PROC_MODE.LI);
                    BarridoUnico();
                    break;
                case 3:
                    Barrido_y_comparacion();
                    break;
                case 0:
                    break;
            }           
        }

        static void BarridoUnico()
        {
            int f_start, f_end, delta_f;

            string nombreArchivo_barrido;
            string nombre_default = "barrido.dat";

            Console.WriteLine("----- Barrido de frecuencias -----");
            try
            {
                Console.WriteLine("Ingrese frecuencia inicial: ");
                f_start = int.Parse(Console.ReadLine());
                Console.WriteLine("Ingrese intervalo de frecuencias: ");
                delta_f = int.Parse(Console.ReadLine());
                Console.WriteLine("Ingrese frecuencia final: ");
                f_end = int.Parse(Console.ReadLine());
               
                
                Console.WriteLine("Ingrese archivo de destino (o enter para " + nombre_default + ")");
                nombreArchivo_barrido = Console.ReadLine();
                if (string.IsNullOrEmpty(nombreArchivo_barrido))
                {
                    nombreArchivo_barrido = nombre_default;
                }

            }            
            catch
            {
                Console.WriteLine("Error ingresando los argumentos");
                return;
            }
            Console.Clear();
            using (StreamWriter writer = new StreamWriter("results/" + nombreArchivo_barrido, true))
            {
                writer.WriteLine($"Barrido en frecuencia desde {f_start} hasta {f_end} con incrementos {delta_f}");
                writer.WriteLine($"N: {N_ca_CALI * N_ma_CALI} | Fuente: {menues.source(fuente,sim_noise)} \n ");
                writer.WriteLine("Formato: frecuencia,X,Y,R,phi \n");

                for (int f = f_start; f < f_end; f = f + delta_f)
                {
                    Console.WriteLine($"Calculando a frecuencia: {f} Hz");
                    fpga.set_lockin_frec(f, M);
                    frec_lockin = f;
                    Lockin_results lia_results = Measure();
                    Console.WriteLine(lia_results.ToString());

                    writer.WriteLine($"{f},{lia_results.X},{lia_results.Y},{lia_results.R},{lia_results.Phi} ");
                }
                writer.WriteLine("---------------------------------------------------------- \n");
            }
        }

        static void Barrido_cte_de_tiempo()
        {
            int N_final;

            string nombreArchivo_barrido_N;
            string nombre_default = "barrido_N.dat";

            Console.Clear();
            Console.WriteLine("----- Barrido de constantes de tiempo -----");

            try
            {
                Console.WriteLine("Ingrese valor final de N: ");
                N_final = int.Parse(Console.ReadLine());

                Console.WriteLine("Ingrese archivo de destino (o enter para " + nombre_default + ")");
                nombreArchivo_barrido_N = Console.ReadLine();
                if (string.IsNullOrEmpty(nombreArchivo_barrido_N))
                {
                    nombreArchivo_barrido_N = nombre_default;
                }
            }

            catch
            {
                return;
            }
            Console.WriteLine($"----- Barrido de N desde 1 a {N_final}-----");

            using (StreamWriter writer = new StreamWriter("results/" + nombreArchivo_barrido_N, false))
            {
                writer.WriteLine($"----- Barrido de N desde 1 a {N_final}-----");
                writer.WriteLine($"frecuencia: {frec_lockin} | Fuente: {menues.source(fuente, sim_noise)} \n ");
                writer.WriteLine("Formato: N,X,Y,R,phi \n");

                for (int N = 1; N < N_final; N ++)
                {
                    Console.WriteLine($"Calculando a N: {N}" );
                    N_ca_CALI = N;
                    configure(false);
                    Lockin_results lia_results = Measure();
                    Console.WriteLine(lia_results.ToString());

                    writer.WriteLine($"{N},{lia_results.X},{lia_results.Y},{lia_results.R},{lia_results.Phi} ");
                }
                writer.WriteLine("---------------------------------------------------------- \n");
            }

        }

        static void Comparar_resultados()
        {
            fpga.Reset();
            fpga.Start();

            fpga.set_processing_mode(FPGA.PROC_MODE.LI);
            long X = fpga.get_result_64(FPGA.FIFO_DIRECTION.F0_64);
            long Y = fpga.get_result_64(FPGA.FIFO_DIRECTION.F1_64);

            Lockin_results lia_results = new Lockin_results(X, Y, N_LI * M, frec_lockin, corregir_resultado);
            Console.WriteLine($"Procesamiento con LI de {N_LI} ciclos:");
            Console.WriteLine(lia_results.ToString());
            // Console.WriteLine($"Sin dividir: \n X: {X} \n Y: {Y}");


            fpga.set_processing_mode(FPGA.PROC_MODE.CALI);
            X = fpga.get_result_64(FPGA.FIFO_DIRECTION.F0_64);
            Y = fpga.get_result_64(FPGA.FIFO_DIRECTION.F1_64);

            lia_results = new Lockin_results(X, Y, N_ma_CALI * N_ca_CALI * M, frec_lockin, corregir_resultado);
            Console.WriteLine($"Procesamiento con CA de {N_ca_CALI} ciclos seguida de LI de {N_ma_CALI} ciclo:");
            Console.WriteLine(lia_results.ToString());
           // Console.WriteLine($"Sin dividir: \n X: {X} \n Y: {Y}");

            Console.ReadKey();



        }

        static void ModificarArchivoCalibracion()
        {
            Console.WriteLine("Cortocircuitar entradas del ADC y salidas del DAC e ingresar ENTER para comenzar");
            Console.ReadKey();
            int f_start, f_end, delta_f;

            Console.Clear();
            Console.WriteLine("----- Barrido de frecuencias -----");
            try
            {
                Console.WriteLine("Ingrese frecuencia inicial: ");
                f_start = int.Parse(Console.ReadLine());
                Console.WriteLine("Ingrese intervalo de frecuencias: ");
                delta_f = int.Parse(Console.ReadLine());
                Console.WriteLine("Ingrese frecuencia final: ");
                f_end = int.Parse(Console.ReadLine());                           
            }
            catch
            {
                Console.WriteLine("Error ingresando los argumentos");
                return;
            }

            using (StreamWriter writer = new StreamWriter("transferencia.dat", false))
            {
                writer.WriteLine($"Barrido en frecuencia desde {f_start} hasta {f_end} con incrementos {delta_f}");
                writer.WriteLine($"N: {N_ca_CALI * N_ma_CALI} | Fuente: {menues.source(fuente, sim_noise)} \n ");
                writer.WriteLine("Formato: frecuencia,X,Y,R,phi \n");

                for (int f = f_start; f < f_end; f = f + delta_f)
                {
                    Console.WriteLine($"Calculando a frecuencia: {f} Hz");
                    fpga.set_lockin_frec(f, M);
                    frec_lockin = f;
                    Lockin_results lia_results = Measure();
                    Console.WriteLine(lia_results.ToString());

                    writer.WriteLine($"{f},{lia_results.X},{lia_results.Y},{lia_results.R},{lia_results.Phi} ");
                }
                writer.WriteLine("---------------------------------------------------------- \n");
            }

        }

        static void Barrido_y_comparacion()
        {
            int f_start, f_end, delta_f;

            string nombreArchivo_barrido;
            string nombre_default = "barrido.dat";

            
            Console.WriteLine("----- Barrido de frecuencias -----");
            try
            {
                Console.WriteLine("Ingrese frecuencia inicial: ");
                f_start = int.Parse(Console.ReadLine());
                Console.WriteLine("Ingrese intervalo de frecuencias: ");
                delta_f = int.Parse(Console.ReadLine());
                Console.WriteLine("Ingrese frecuencia final: ");
                f_end = int.Parse(Console.ReadLine());
                
                Console.WriteLine("Ingrese archivo de destino (o enter para " + nombre_default + ")");
                nombreArchivo_barrido = Console.ReadLine();
                if (string.IsNullOrEmpty(nombreArchivo_barrido))
                {
                    nombreArchivo_barrido = nombre_default;
                }

            }
            catch
            {
                Console.WriteLine("Error ingresando los argumentos");
                return;
            }
            Console.Clear();
            StreamWriter writer_cali = new StreamWriter("results/" + nombreArchivo_barrido + "_cali.dat", false);
            StreamWriter writer_li = new StreamWriter("results/" + nombreArchivo_barrido + "_li.dat", false);


            writer_cali.WriteLine($"Barrido en frecuencia desde {f_start} hasta {f_end} con incrementos {delta_f}");
            writer_cali.WriteLine($"Metodo usado: {menues.mode(FPGA.PROC_MODE.CALI,N_ca_CALI, N_ma_CALI,N_LI)}");
            writer_cali.WriteLine("Formato: frecuencia,X,Y,R,phi \n");

            writer_li.WriteLine($"Barrido en frecuencia desde {f_start} hasta {f_end} con incrementos {delta_f}");
            writer_li.WriteLine($"Metodo usado: {menues.mode(FPGA.PROC_MODE.LI, N_ca_CALI, N_ma_CALI, N_LI)}");
            writer_li.WriteLine("Formato: frecuencia,X,Y,R,phi \n");

            for (int f = f_start; f < f_end; f = f + delta_f)
            {
                Console.WriteLine($"Calculando a frecuencia: {f} Hz");
                fpga.set_lockin_frec(f, M);
                frec_lockin = f;


                // Calculo con CALI y guardo en un archivo
                fpga.Reset();fpga.Start();
                fpga.set_processing_mode(FPGA.PROC_MODE.CALI);
                long X = fpga.get_result_64(FPGA.FIFO_DIRECTION.F0_64);
                long Y = fpga.get_result_64(FPGA.FIFO_DIRECTION.F1_64);

                Lockin_results lia_results_cali = new Lockin_results(X, Y, N_ma_CALI * N_ca_CALI * M, frec_lockin, corregir_resultado);
                Console.WriteLine(lia_results_cali.ToString());
                writer_cali.WriteLine($"{f},{lia_results_cali.X},{lia_results_cali.Y},{lia_results_cali.R},{lia_results_cali.Phi} ");

                // Calculo con lockin y guardo en otro archivo
                fpga.set_processing_mode(FPGA.PROC_MODE.LI);
                X = fpga.get_result_64(FPGA.FIFO_DIRECTION.F0_64);
                Y = fpga.get_result_64(FPGA.FIFO_DIRECTION.F1_64);

                Lockin_results lia_results_li = new Lockin_results(X, Y, N_ma_CALI * N_ca_CALI * M, frec_lockin, corregir_resultado);
                Console.WriteLine(lia_results_li.ToString());

                writer_li.WriteLine($"{f},{lia_results_li.X},{lia_results_li.Y},{lia_results_li.R},{lia_results_li.Phi} ");
            }
            writer_cali.WriteLine("---------------------------------------------------------- \n");
            writer_li.WriteLine("---------------------------------------------------------- \n");

            writer_cali.Close();
            writer_li.Close();
        }
    }
}
