
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