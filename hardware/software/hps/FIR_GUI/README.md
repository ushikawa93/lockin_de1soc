# FIR Filter Graphical User Interface (GUI)

## Descripción
Esta GUI permite controlar y visualizar filtros digitales implementados en una FPGA DE1-SoC.  
Está desarrollada en **C#** y se ejecuta en el procesador HPS de la FPGA (Ubuntu), usando **Mono/.NET**.  

El sistema completo incluye:  
- **GUI en C#** (`FIR_GUI.exe`): interfaz gráfica para interacción con la FPGA.  
- **Driver en C++** (`fpga_driver`): maneja la comunicación con la FPGA a través de la HAL.  
- **Named Pipes (FIFOs)**: utilizados para la comunicación entre la GUI y el driver.

## Estructura del proyecto
FIR_GUI/
├─ Pipe_c++/ # Código fuente del driver en C++ que accede a la HAL  
│ └─ Makefile # Para compilar el driver en la plataforma de destino  
├─ software/hps/FIR_GUI/ # Código de la GUI en C#  
└─ filters/ # Clases de filtros, banco de filtros y gestión de coeficientes  


## Comunicación GUI <-> FPGA
Se utiliza **interfaz por FIFOs**:
- `myfifo1`: C++ escribe, C# lee  
- `myfifo2`: C# escribe, C++ lee  

### Comandos disponibles
| Comando | Descripción |
|---------|-------------|
| RST | Reinicia la FPGA |
| START | Comienza la adquisición y procesamiento |
| SET_CLK VALUE | Configura el clock de la FPGA en kHz |
| SET_PARAM OFFSET VALUE | Setea el valor de un parámetro en el offset indicado |
| GET_PARAM OFFSET | Obtiene el valor de un parámetro en el offset indicado |
| RD_FIFO NUM | Lee un FIFO específico (32 o 64 bits) |
| TERMINATE | Finaliza el driver y detiene la FPGA |

### FIFOs disponibles
| FIFO | Tipo |
|------|------|
| F0_32 | 32 bits |
| F1_32 | 32 bits |
| F0_64 | 64 bits |
| F1_64 | 64 bits |

## Instalación y ejecución
1. Compilar el driver C++ en la plataforma de destino:
```bash
cd FIR_GUI/Pipe_c++
make
```

2.Ejecutar el driver y la GUI simultáneamente. Por ejemplo, con un script:

```bash
./fpga_driver && mono FIR_GUI.exe
```

> Nota: El driver debe ejecutarse primero para que los FIFOs estén disponibles para la GUI.

- Funcionalidades de la GUI

  - Visualización de señales adquiridas por la FPGA.

  - Selección y carga de coeficientes de filtros (PA, PB, bypass).

  - Configuración de parámetros de la FPGA (clock, offsets).

  - Lectura de FIFOs en tiempo real.

  - Control de encendido/apagado de LEDs de la FPGA.

- Clases principales

  - **FPGA**: encapsula los comandos y operaciones que la GUI puede enviar a la FPGA.

  - **PipeControl**: maneja la comunicación a través de FIFOs con el driver C++.

  - **Filtro**: representa un filtro digital (PA, PB, bypass) y sus coeficientes.

  - **BancoFiltros**: colección de filtros predefinidos y funciones para acceder a ellos.

- Requisitos

  - Ubuntu en HPS de la FPGA.
  
  - FPGA seteada con el signal_processing.rbf

  - Mono/.NET instalado para correr la GUI.

  - Permisos para crear y usar named pipes.
 

Observaciones

La GUI y el driver deben ejecutarse simultáneamente para funcionar correctamente.

Los FIFOs deben crearse en /tmp y tener los permisos adecuados.

Esta implementación está pensada para demostración y pruebas de filtros digitales en tiempo real.