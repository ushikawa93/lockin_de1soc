import mmap
import os
import struct
import fcntl 
from PLL import PLL  # Asegúrate de tener la clase PLL definida similar a tu implementación en C++

# Definición de constantes necesarias (deberás ajustar estas según tus necesidades)
ALT_STM_OFST = 0xfc000000
HW_REGS_BASE = ALT_STM_OFST  # Ajusta esta dirección base según tu hardware
HW_REGS_SPAN = 0x04000000  # Ajusta el tamaño de mapeo según tu hardware
HW_REGS_MASK = HW_REGS_SPAN - 1
ALT_LWFPGASLVS_OFST = 0xff200000  # Ajusta este offset según tu hardware
PLL_RECONFIGURAR_BASE = 0x42000  # Ajusta esta base según tu hardware


class FPGA_IO_simple:
    def __init__(self):
        try:
            # Abre /dev/mem
            self.fd = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
            # Mapea la memoria
            self.virtual_base = mmap.mmap(self.fd, HW_REGS_SPAN, flags=mmap.MAP_SHARED,
                                          prot = (mmap.PROT_READ | mmap.PROT_WRITE),
                                          offset=HW_REGS_BASE)
            self.pll = PLL()  # Inicializa la clase PLL
        except Exception as e:
            print("Error al inicializar FPGA_IO_simple:" )
            self.virtual_base = None
            if self.fd:
                os.close(self.fd)

    def __del__(self):
        # Desmapea la memoria y cierra el archivo
        if self.virtual_base:
            self.virtual_base.close()
        if self.fd:
            os.close(self.fd)

    def _get_puntero_a_variable(self, address):
        # Calcula la dirección virtual
        return (ALT_LWFPGASLVS_OFST + address) & HW_REGS_MASK

    def write_fpga(self, address, offset, value):
        if not self.virtual_base:
            print("Error: virtual_base no está inicializado.")
            return
        # Calcula la dirección del registro
        ptr = self._get_puntero_a_variable(address)
        # Escribe el valor en la dirección calculada
        struct.pack_into('I', self.virtual_base, ptr + offset * 4, value)

    def read_fpga(self, address, offset):
        if not self.virtual_base:
            print("Error: virtual_base no está inicializado.")
            return None
        # Calcula la dirección del registro
        ptr = self._get_puntero_a_variable(address)
        # Lee el valor desde la dirección calculada
        value = struct.unpack_from('I', self.virtual_base, ptr + offset * 4)[0]
        return value

    def configurar_pll(self, value):
        if not self.virtual_base:
            print("Error: virtual_base no está inicializado.")
            return
        # Calcula la dirección del registro de configuración de PLL
        offset = self._get_puntero_a_variable(PLL_RECONFIGURAR_BASE);
        base = self.virtual_base;
        # Configura la PLL utilizando el método de la clase PLL
        self.pll.configurar_pll(value, base ,offset )
        
