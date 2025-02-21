import math
from FPGA_IO_simple import FPGA_IO_simple
import FPGA_macros as MACROS

amplitud_ref = 32767

class FPGA_de1soc:

    def __init__(self):
        self.fifo0_32_bit = [0] * MACROS.BUFFER_SIZE_RAW
        self.fifo1_32_bit = [0] * MACROS.BUFFER_SIZE_RAW
        self.fifo0_64_bit = [0] * MACROS.BUFFER_SIZE_RAW
        self.fifo1_64_bit = [0] * MACROS.BUFFER_SIZE_RAW
        self.parameters = [0] * MACROS.N_parametros
        self.PARAM_MACROS_ARRAY = [MACROS.PARAMETER_0, MACROS.PARAMETER_1, MACROS.PARAMETER_2,
                                   MACROS.PARAMETER_3, MACROS.PARAMETER_4, MACROS.PARAMETER_5,
                                   MACROS.PARAMETER_6, MACROS.PARAMETER_7, MACROS.PARAMETER_8,
                                   MACROS.PARAMETER_9]
        self.SALIDAS_AUX_ARRAY = [MACROS.SALIDA_AUX_0, MACROS.SALIDA_AUX_1, MACROS.SALIDA_AUX_2,
                                  MACROS.SALIDA_AUX_3, MACROS.SALIDA_AUX_4]
        self.frec_clk = 0
        self.div_clk = 0
        self.calculos_disponibles = False
        self.fpga = FPGA_IO_simple()

    def iniciar(self):
        self.fpga.write_fpga(MACROS.ENABLE_BASE, 0, 1)

    def reset(self):
        self.fpga.write_fpga(MACROS.ENABLE_BASE, 0, 0)
        self.fpga.write_fpga(MACROS.RESET_BASE, 0, 1)
        self.fpga.write_fpga(MACROS.RESET_BASE, 0, 0)

    def esperar(self):
        while self.fpga.read_fpga(MACROS.FINALIZACION_BASE, 0) == 0:
            pass

    def to_volt_adc_hs(self, tension):
        factor_conversion_a_volt = 1.93 / 7423  # Medido con osciloscopio
        return tension * factor_conversion_a_volt

    def terminar(self):
        self.reset()
        self.calculos_disponibles = False

    def set_n_parametros(self, N, parameters_array):
        for i in range(N):
            self.set_parameter(parameters_array[i], i)

    def set_parameter(self, value, parameter_index):
        self.parameters[parameter_index] = value
        if 0 <= parameter_index < 10:
            self.fpga.write_fpga(MACROS.PARAMETERS_BASE, self.PARAM_MACROS_ARRAY[parameter_index], value)
        elif 10 <= parameter_index < 20:
            self.fpga.write_fpga(MACROS.PARAMETERS_1_BASE, self.PARAM_MACROS_ARRAY[parameter_index - 10], value)
        elif 20 <= parameter_index < 30:
            self.fpga.write_fpga(MACROS.PARAMETERS_2_BASE, self.PARAM_MACROS_ARRAY[parameter_index - 20], value)
        elif 30 <= parameter_index < 40:
            self.fpga.write_fpga(MACROS.PARAMETERS_3_BASE, self.PARAM_MACROS_ARRAY[parameter_index - 30], value)

    def set_frec_clk(self, frec_clk_i):
        self.frec_clk = frec_clk_i
        self.fpga.configurar_pll(frec_clk_i)

    def set_divisor_clock(self, div_clk_i):
        self.div_clk = div_clk_i
        self.fpga.write_fpga(MACROS.DIVISOR_CLOCK_BASE, 0, div_clk_i)

    def set_frec_dds_compiler(self, f_deseada, f_clk):
        B = 27  # Bits del acumulador de fase
        delta_phase = f_deseada * pow(2, B) / f_clk
        self.set_parameter(int(delta_phase), 7)
        return f_clk * delta_phase / pow(2, B)

    def switch_led(self, state):
        self.set_parameter(state, 9)

    def get_parameter(self, parameter_index):
        return self.parameters[parameter_index]

    def get_output_auxiliar(self, parameter_index):
        return self.fpga.read_fpga(MACROS.PARAMETERS_BASE, self.SALIDAS_AUX_ARRAY[parameter_index])

    def leer_fifo_32_bit(self, fifo):
        for indice in range(MACROS.BUFFER_SIZE_RAW):
            if fifo == 0:
                sample = self.fpga.read_fpga(MACROS.FIFO0_32_BIT_BASE, 0)
                self.fifo0_32_bit[indice] = sample
            elif fifo == 1:
                sample = self.fpga.read_fpga(MACROS.FIFO1_32_BIT_BASE, 0)
                self.fifo1_32_bit[indice] = sample

        if fifo == 0:
            return self.fifo0_32_bit
        else:
            return self.fifo1_32_bit

    def leer_resultado_32_bit(self, fifo):
        self.esperar()
        if fifo == 0:
            return self.fpga.read_fpga(MACROS.RESULT0_32_BIT_BASE, 0)
        else:
            return self.fpga.read_fpga(MACROS.RESULT1_32_BIT_BASE, 0)

    @staticmethod
    def cuentas2volt(cuentas):
        factor = 125e-6  # Medido empíricamente
        return factor * cuentas

    @staticmethod
    def get_resultados_from_xy(X, Y, div, convert2volt):
        result = {}
        result['x'] = X / div
        result['y'] = Y / div
        result['r'] = math.sqrt(result['x'] ** 2 + result['y'] ** 2) * 2 / amplitud_ref
        result['phi'] = math.atan2(result['y'], result['x']) * 180 / math.pi
        if convert2volt:
            result['r'] = FPGA_de1soc.cuentas2volt(result['r'])
        return result