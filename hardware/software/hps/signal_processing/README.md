# Proyecto FPGA DE1-SoC: Control y demostración de filtros FIR

## Descripción
Este proyecto permite **controlar y configurar filtros FIR** en una FPGA DE1-SoC. Se incluyen funcionalidades para la configuración de parámetros de la FPGA, control del PLL y divisores de clock, ejecución de filtros FIR Pasa Bajos y Pasa Altos, y lectura de resultados desde FIFOs de 32 y 64 bits.

---

## Objetivo
- Configurar la FPGA y sus parámetros de operación.
- Configurar el PLL y los divisores de clock.
- Ejecutar filtros FIR Pasa Bajos y Pasa Altos.
- Leer y mostrar los resultados de la filtración desde FIFOs de 32 y 64 bits.

---

## Componentes principales

### 1) Macros (`FPGA_macros.h`)
- Define **direcciones base** para memoria FPGA, FIFOs y parámetros.
- Mappea **entradas y salidas**.
- Establece **tamaños de buffer** y **límites de parámetros**.
- Facilita la interacción con la consola mediante macros como `CLEAR_CONSOLE`.

### 2) Clase `PLL`
- Encargada de la **configuración del PLL** de la FPGA.
- Funciones principales:
  - `configurar_pll(frec_deseada, puntero_pll)`
  - `setM`, `setN`, `setC`, `setMNC`
  - `calculatePll_parameters`
- Permite alcanzar la **frecuencia deseada** lo más precisa posible.

### 3) Clase `FPGA_IO_simple`
- Abstracción de **lectura/escritura a FPGA mediante mmap**.
- Funciones principales:
  - `WriteFPGA(address, offset, value)`
  - `ReadFPGA(address, offset)`
  - `ConfigurarPll(value)`

### 4) Clase `FPGA_de1soc`
- Control general de la FPGA y sus operaciones.
- Funciones principales:
  - `Comenzar()`, `Calcular()`, `Terminar()`
  - `set_N_parametros()`, `set_parameter()`
  - `set_frec_clk()`, `set_divisor_clock()`, `set_clk_from_frec()`
  - `leer_FIFO_32_bit()`, `leer_FIFO_64_bit()`
  - `leer_resultado_32_bit()`, `leer_resultado_64_bit()`
- Maneja hasta **40 parámetros configurables**, organizados en 4 bloques de 10.

### 5) Programa principal (`main.cpp`)
- Interacción por **consola** con el usuario.
- Permite:
  - Seleccionar el **tipo de filtro** y **frecuencia de corte**.
  - Ajustar la **frecuencia de muestreo**.
  - Aplicar el filtro y **leer los resultados**.
- Incluye un **bucle principal** para repetir demostraciones con distintos filtros y frecuencias.

---

## Notas importantes
- Todos los accesos a la FPGA se realizan a través de **mmap** y **punteros volátiles**.
- La FIFO de 64 bits se lee combinando registros `"up"` y `"down"` para obtener el valor completo.
- Macros y definiciones de buffer ayudan en la **interacción con el usuario** y pruebas.
- El proyecto permite **probar distintos filtros FIR** y observar los resultados en tiempo real.
- Para que ande correctamente la FPGA DE1SoC debe estar configurada con signal_procesing.rbf

---

## Uso
1. Compilar el proyecto con **make** o:

g++ -std=c++11 -o signal_processing main.cpp

2. Ejecutar

./signal_processing

3. Seguir las instrucciones en consola para seleccionar filtros, frecuencias y visualizar resultados.
