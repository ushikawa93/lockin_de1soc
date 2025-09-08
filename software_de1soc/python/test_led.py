"""
************************************************************************************
Script: test_fpga_io_simple.py
Proyecto: LIA Python Interface
Autor: Matías Oliva
Fecha: 2025

Descripción:
------------
Script de prueba para la clase FPGA_IO_simple.
Incluye:
- Escribir directamente en un parámetro de la FPGA mapeada en memoria.
- Prender o apagar el LED de la FPGA usando el parámetro correspondiente.

Uso:
----
python test_fpga_io_simple.py [valor_led]
- Si no se proporciona valor, se usa 1 por defecto (LED encendido).

Notas:
------
- Requiere que la clase FPGA_IO_simple y FPGA_macros estén correctamente implementadas y accesibles.
************************************************************************************
"""

# Test para probar la clase FPGA_IO_simple:

import sys
from FPGA_IO_simple import FPGA_IO_simple
import FPGA_macros as MACROS

fpga = FPGA_IO_simple()

# Verificar si se proporcionó un argumento en la línea de comandos
if len(sys.argv) > 1:
    # Tomar el primer argumento y convertirlo a entero
    value = int(sys.argv[1])
else:
    # Si no se proporcionó ningún argumento, establecer el valor predeterminado en 1
    value = 1

# Prender o apagar el LED según el valor proporcionado
fpga.write_fpga(MACROS.PARAMETERS_BASE, MACROS.PARAMETER_9, value)