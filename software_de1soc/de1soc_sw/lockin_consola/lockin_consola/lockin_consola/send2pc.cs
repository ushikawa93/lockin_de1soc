/*
================================================================================
 Clase send2pc
================================================================================
 Propósito:
 ----------
 Enviar archivos generados en la carpeta results/ del programa a una PC remota 
 usando `scp` (Secure Copy Protocol) a través de SSH.

 Flujo general:
 --------------
 - EnviarArchivo():
    1. Lista todos los archivos en results/.
    2. El usuario selecciona uno mediante índice.
    3. Solicita IP del host y ruta de destino (con valores por defecto).
    4. Llama a EnviarArchivoSSH() para copiar el archivo.

 - EnviarArchivoSSH():
    - Construye el comando `scp`:
        scp <archivo_local> usuario@IP:<ruta_destino>
    - Lanza el proceso y redirige la salida a consola.

 - getIP():
    - Pide al usuario una IP de destino (default: 192.168.1.105).

 - getPath():
    - Pide al usuario una ruta de destino remoto (default: 
      C:\Users\MatiOliva\Documents\04-de1soc_sw\).

 Parámetros fijos:
 -----------------
 - Usuario SSH: "MatiOliva" (puede modificarse según configuración).
 - Programa externo: requiere `scp` instalado y accesible en PATH.

 Notas:
 ------
 - Usa rutas con `\\` para compatibilidad Windows.
 - La carpeta results/ debe existir previamente, de lo contrario se lanza error.
 - No maneja autenticación por contraseña/clave: se asume que SSH está configurado
   con autenticación sin intervención (ej. claves públicas).
================================================================================
*/


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
