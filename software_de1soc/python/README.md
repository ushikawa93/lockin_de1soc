# Proyecto FPGA DE1-SoC - Interfaz Python

Este proyecto contiene una serie de scripts y módulos en Python para interactuar con una FPGA DE1-SoC. Permite configurar parámetros, leer resultados, controlar el clock, y trabajar con la PLL de la FPGA.

---

## Estructura de archivos

- `FPGA_IO_simple.py` : Clase que permite leer/escribir directamente en registros mapeados de la FPGA.  
- `FPGA_de1soc.py` : Clase de más alto nivel que maneja FIFOs, parámetros, cálculos y resultados tipo Lock-In.  
- `FPGA_macros.py` : Macros y direcciones de memoria para mapeo de la FPGA.  
- `PLL.py` : Clase para configurar la PLL de la FPGA.  

- Scripts de test:  
  - `test_fpga_de1soc.py`  
  - `test_fpga_io_simple.py`  

---

