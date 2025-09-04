/*
================================================================================
 Programa: Selector de Bitstream para FPGA
================================================================================
 Descripción:
 -------------
 Este programa lista todos los archivos con extensión ".rbf" en la carpeta
 "bitstreams", muestra cuál está actualmente cargado en la FPGA y permite al
 usuario seleccionar un nuevo archivo para cargar. 

 Funcionalidades principales:
 - Abrir la carpeta "bitstreams" y leer archivos ".rbf".
 - Mostrar el bitstream actualmente cargado.
 - Permitir seleccionar un bitstream de la lista.
 - Ejecutar un script externo para configurar la FPGA con el bitstream
   seleccionado.
 - Guardar el bitstream actualmente seleccionado en "bitstream_actual.txt".

================================================================================
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>

#define MAX_FILES 100

int main() {
    DIR *dir;
    struct dirent *entry;
    char *fileList[MAX_FILES];
    int fileCount = 0;

    // Abre la carpeta "bitstreams"
    dir = opendir("bitstreams");
    if (dir == NULL) {
        perror("No se pudo abrir la carpeta");
        return 1;
    }

    // Recorre los archivos en la carpeta y guarda los nombres en la lista
    while ((entry = readdir(dir)) != NULL) {
        // Comprueba si el nombre del archivo termina en ".rbf"
        if (strstr(entry->d_name, ".rbf") != NULL) {
            fileList[fileCount] = strdup(entry->d_name);
            fileCount++;
        }
    }

    // Imprime el seleccionado actualmente
    {
      FILE *savedFile = fopen("bitstream_actual.txt", "r");
      if (savedFile != NULL) {
          char savedFileName[256];
          if (fgets(savedFileName, sizeof(savedFileName), savedFile) != NULL) {
              savedFileName[strcspn(savedFileName, "\n")] = '\0';  // Elimina el salto de l�nea
          }
          printf("Bitstream cargado: %s\n\n", savedFileName);
      }
    }

    // Cierra la carpeta
    closedir(dir);

    // Muestra la lista de archivos y permite al usuario seleccionar uno
    printf("Archivos disponibles:\n");
    for (int i = 0; i < fileCount; i++) {
        printf("%d: %s\n", i + 1, fileList[i]);
    }

    int selection;
    printf("Seleccione un archivo (1-%d) o ingrese 0 para no cambiar: ", fileCount);
    scanf("%d", &selection);

    if (selection == 0) {
        printf("No se realizaron cambios.\n");
    } else if (selection >= 1 && selection <= fileCount) {
        printf("Archivo seleccionado: %s\n", fileList[selection - 1]);

        // Verifica si el archivo seleccionado ya est� guardado
        FILE *savedFile = fopen("bitstream_actual.txt", "r");
        if (savedFile != NULL) {
            char savedFileName[256];
            if (fgets(savedFileName, sizeof(savedFileName), savedFile) != NULL) {
                savedFileName[strcspn(savedFileName, "\n")] = '\0';  // Elimina el salto de l�nea
                if (strcmp(savedFileName, fileList[selection - 1]) == 0) {
                    printf("Este bitsream ya est� cargado en la FPGA.\n");
                    fclose(savedFile);
                    printf("\n\nIngrese enter para salir\n\n");
                    getchar();
                    while (getchar() != '\n') {
                        // Vac�a el b�fer de entrada
                    }
                    return 0;
                }
            }
            fclose(savedFile);
        }

        // Llama a una funcion del sistema para configurar la FPGA:
        char command[256] = {0};
        strcat(command, "./set_bitstream.sh bitstreams/");
        strcat(command, fileList[selection - 1]);
        system(command);

        // Guarda el nombre del archivo seleccionado en un nuevo archivo
        FILE *outputFile = fopen("bitstream_actual.txt", "w");
        if (outputFile != NULL) {
            fprintf(outputFile, "%s\n", fileList[selection - 1]);
            fclose(outputFile);
            printf("Nombre del archivo seleccionado guardado en 'bitstream_actual.txt'\n");
        } else {
            perror("Error al crear el archivo");
        }
    } else {
        printf("Selecci�n inv�lida.\n");
    }

    // Libera la memoria de la lista de archivos
    for (int i = 0; i < fileCount; i++) {
        free(fileList[i]);
    }

    printf("\n\nIngrese enter para salir\n\n");

    getchar();
    while (getchar() != '\n') {
        // Vac�a el b�fer de entrada
    }

    return 0;
}
