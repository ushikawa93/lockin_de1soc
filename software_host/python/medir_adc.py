# -*- coding: utf-8 -*-
"""
Created on Tue Mar  5 16:03:14 2024

@author: MatiOliva
"""


from de1soc_class import de1soc_handler
import matplotlib.pyplot as plt


ip = "192.168.1.2"
N_promediacion = 1;

# Para generar una sinusoide:
pts_x_ciclo = 64;
f = 1000;

display_ciclos = 6;

li = de1soc_handler(ip);
li.set_M(pts_x_ciclo)
li.set_N(N_promediacion)
li.set_f(f);

medidas = [valor / N_promediacion for valor in li.get_adc(display_ciclos)]

plt.plot(medidas);
plt.grid();
plt.show();


