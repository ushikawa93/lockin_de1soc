import struct

class PLL:
    def set_m(self, M, pll_reconfig,pll_offset):
        low_count = M
        high_count = M
        code_mult = ((high_count & 0xFF) << 8) | (low_count & 0xFF)

        struct.pack_into('I', pll_reconfig, pll_offset, 1)  # Polling mode
        struct.pack_into('I', pll_reconfig, pll_offset + 4 * 4, code_mult)

        struct.pack_into('I', pll_reconfig, pll_offset + 2 * 4, 1)  # Start register
        #while struct.unpack_from('I', pll_reconfig, pll_offset + 1 * 4)[0] == 0:
        #    pass
        struct.pack_into('I', pll_reconfig, pll_offset + 2 * 4, 0)  # Stop register

    def set_n(self, N, pll_reconfig,pll_offset):
        low_count = N
        high_count = N
        code_div = ((high_count & 0xFF) << 8) | (low_count & 0xFF)

        struct.pack_into('I', pll_reconfig, pll_offset, 1)  # Polling mode
        struct.pack_into('I', pll_reconfig, pll_offset+3 * 4, code_div)

        struct.pack_into('I', pll_reconfig,pll_offset+ 2 * 4, 1)  # Start register
        #while struct.unpack_from('I', pll_reconfig, pll_offset+1 * 4)[0] == 0:
        #    pass
        struct.pack_into('I', pll_reconfig, pll_offset+2 * 4, 0)  # Stop register

    def set_c(self, C, counter_number, pll_reconfig,pll_offset):
        if C % 2 == 0:
            low_count = C // 2
            high_count = C // 2
        else:
            low_count = C // 2 + 1
            high_count = C // 2

        c_address = counter_number
        code_pll = ((c_address & 0x1F) << 18) | ((high_count & 0xFF) << 8) | (low_count & 0xFF)

        struct.pack_into('I', pll_reconfig,pll_offset+ 0, 1)  # Polling mode
        struct.pack_into('I', pll_reconfig,pll_offset+ 5 * 4, code_pll)

        struct.pack_into('I', pll_reconfig,pll_offset+ 2 * 4, 1)  # Start register
        #while struct.unpack_from('I', pll_reconfig,pll_offset+ 1 * 4)[0] == 0:
        #    pass
        struct.pack_into('I', pll_reconfig,pll_offset+ 2 * 4, 0)  # Stop register

    def set_mnc(self, M, N, C, counter_number, pll_reconfig,pll_offset):
        low_count = M
        high_count = M
        code_mult = ((high_count & 0xFF) << 8) | (low_count & 0xFF)

        low_count = N
        high_count = N
        code_div = ((high_count & 0xFF) << 8) | (low_count & 0xFF)

        if C % 2 == 0:
            low_count = C // 2
            high_count = C // 2
        else:
            low_count = C // 2 + 1
            high_count = C // 2

        c_address = counter_number
        code_pll = ((c_address & 0x1F) << 18) | ((high_count & 0xFF) << 8) | (low_count & 0xFF)

        struct.pack_into('I', pll_reconfig, pll_offset+ 0, 1)  # Polling mode
        struct.pack_into('I', pll_reconfig, pll_offset+ 3 * 4, code_div)
        struct.pack_into('I', pll_reconfig, pll_offset+ 4 * 4, code_mult)
        struct.pack_into('I', pll_reconfig, pll_offset+ 5 * 4, code_pll)

        struct.pack_into('I', pll_reconfig, pll_offset+ 2 * 4, 1)  # Start register
        while struct.unpack_from('I', pll_reconfig, pll_offset+ 1 * 4)[0] == 0:
            pass
        struct.pack_into('I', pll_reconfig, pll_offset+ 2 * 4, 0)  # Stop register

    class PllParameters:
        def __init__(self, M, N, C):
            self.M = M
            self.N = N
            self.C = C

    def calculate_pll_parameters(self, frec_deseada, frec_referencia):
        pll = self.PllParameters(0, 0, 0)

        frec_normalizada = frec_deseada / frec_referencia
        vco_out = 6
        min_dif = 1
        vco_out_final = 6
        C_posible = 0

        while vco_out <= 30:
            C_posible = vco_out / frec_normalizada
            if C_posible - int(C_posible) == 0:
                pll.C = int(C_posible)
                vco_out_final = vco_out
                break
            else:
                C_posible_redondeado = int(C_posible)
                dif = C_posible - C_posible_redondeado
                if dif < min_dif:
                    pll.C = C_posible_redondeado
                    min_dif = dif
                    vco_out_final = vco_out

            vco_out += 0.5

        if vco_out_final == int(vco_out_final):
            pll.M = int(vco_out_final)
            pll.N = 1
        else:
            pll.M = int(2 * vco_out_final)
            pll.N = 2

        return pll

    def configurar_pll(self, frec_deseada, pll_reconfig_base, pll_offset):
        pll = self.calculate_pll_parameters(frec_deseada, 50)
        
       
        self.set_mnc(pll.M,pll.N,pll.C,0,pll_reconfig_base,pll_offset);

        # Devuelve la frecuencia lograda (no siempre es exactamente la que quiero)
        return 50.0 * pll.M / (pll.N * pll.C)