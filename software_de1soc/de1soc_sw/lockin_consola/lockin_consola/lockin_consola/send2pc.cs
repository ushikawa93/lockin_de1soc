using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace lockin_consola
{
    internal class send2pc
    {
        public static void EnviarArchivo()
        {
            Console.Clear();
            try
            {
                string[] archivos = Directory.GetFiles("results/");
                Console.WriteLine("Archivos de resultados:");
                int i = 1;
                foreach (string archivo in archivos)
                {

                    Console.WriteLine(i + ". " + archivo); i++;
                }
                Console.Write("Archivo seleccionado -> ");
                i = int.Parse(Console.ReadLine());
                string archivo_obj = archivos[i - 1];
                Console.WriteLine(archivo_obj);

                string ipAddress = getIP();
                string remotePath = getPath();

                EnviarArchivoSSH(ipAddress, remotePath, archivo_obj);
            }
            catch
            {
                Console.WriteLine("Error. El directorio results/ debe existir");
                Console.ReadKey();
                return;
            }

        }

        static void EnviarArchivoSSH(string IP, string destinoRemoto, string nombre_archivo)
        {

            // Copiar archivo usando scp
            string archivoLocal = nombre_archivo;
            string usuarioSSH = "MatiOliva";
            string hostSSH = IP;
            destinoRemoto = destinoRemoto + nombre_archivo.Replace("/", "\\\\");

            string comandoScp = $"{archivoLocal} {usuarioSSH}@{hostSSH}:{destinoRemoto}";

            Process process = new Process();
            process.StartInfo.FileName = "scp";
            process.StartInfo.Arguments = comandoScp;
            process.StartInfo.UseShellExecute = false;
            process.StartInfo.RedirectStandardOutput = true;

            process.Start();
            string output = process.StandardOutput.ReadToEnd();
            process.WaitForExit();
            Console.WriteLine(output);

        }

        static string getIP()
        {
            Console.Write("Introduce la dirección IP (presiona Enter para usar 192.168.1.105 por defecto): ");
            string ipAddress = Console.ReadLine();

            if (string.IsNullOrEmpty(ipAddress))
            {
                ipAddress = "192.168.1.105";
            }
            return ipAddress;

        }

        static string getPath()
        {
            Console.Write("Introduce la ruta del destino remoto (presiona Enter para usar C:\\\\Users\\\\MatiOliva\\\\Documents\\\\04-de1soc_sw\\\\results\\\\ ): ");
            string remotePath = Console.ReadLine();

            if (string.IsNullOrEmpty(remotePath))
            {
                remotePath = @"C:\\Users\\MatiOliva\\Documents\\04-de1soc_sw\\";
            }
            return remotePath;
        }
    }
}
