
# Testeo de funciones de la FPGA en python

import sys
from FPGA_de1soc import FPGA_de1soc

# Verificar si se proporcionó un argumento en la línea de comandos
if len(sys.argv) > 1:
    # Tomar el primer argumento y convertirlo a entero
    value = int(sys.argv[1])
else:
    # Si no se proporcionó ningún argumento, establecer el valor predeterminado en 1
    value = 32

fpga = FPGA_de1soc();

fpga.reset()

fpga.switch_led(0);

fpga.set_frec_clk(value);
fpga.set_frec_dds_compiler(100000,value*1000000);

fpga.iniciar();



#fpga.iniciar();


