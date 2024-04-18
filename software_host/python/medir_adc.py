# -*- coding: utf-8 -*-
"""
Created on Tue Mar  5 16:03:14 2024

@author: MatiOliva
"""


from de1soc_class import de1soc_handler
from de1soc_class import FuenteDatos

import matplotlib.pyplot as plt


ip = "192.168.1.2"
N_promediacion = 1;

# Para generar una sinusoide:
f = 400000;

display_ciclos = 2;

li = de1soc_handler(ip);
li.set_N(N_promediacion)
li.set_f(f);
li.set_fuente(FuenteDatos.SIM)

medidas = [valor / N_promediacion for valor in li.get_adc(display_ciclos)]


plt.plot(medidas,marker='x');
plt.grid();
plt.show();


