# Software DE1sSoC

Esta carpeta contiene programas pensados para ser ejecutados en el microprocesador ARM Cortex A9 disponible en el Cyclone V.

Los programas en C# están pensados para ejecutarse a través de la implementación mono del framework de .NET. Los programas en c++ deben compilarse en la plaaforma objetivo (g++).

Tiene varios programas para controlar el Lock-in o los filtros FIR de distintas maneras. 

Cada archivo tiene comentarios más específicos de cada funcionalidad, pero aqui se desribe brevemente cual es el propósito de cada proyecto, y el bitstream que debe estar cargado en la FPGA para utilizarlo correctamente

- FIR Consola: Control de Filtros FIR por consola, programado en C# con pipes en C++ para comunicación con FPGA. Debe estar cargado el bitstream fir_filter.rbf para funcionar correctamente.

- FIR GUI: Control de Filtros FIR por una interfaz gráfica, programado en C# con pipes en C++ para comunicación con FPGA. Debe estar cargado el bitstream fir_filter.rbf para funcionar correctamente.

- Firmware: Programa para controlar el rbf que está cargado en la FPGA. 

- lockin_consola: Programa escrito en C# con pipes en C++ para comunicación con FPGA para controlar el acmplificador Lock-in. Debe estar cargado el bitstream efficient_lockin_estable.rbf para funcionar correctamente.

- Lockin GUI: Programa escrito en C# con pipes en C++ para comunicación con FPGA para controlar el acmplificador Lock-in a través de una interfaz gráfica. Debe estar cargado el bitstream efficient_lockin_estable.rbf para funcionar correctamente.

- Pipe Test: Pruebas preeliminares para los named pipes que utilizan los otros programas.

- Transf Test: Pruebas preeliminares para corrección de funciones de transferencia que utiliza el Lock-in.