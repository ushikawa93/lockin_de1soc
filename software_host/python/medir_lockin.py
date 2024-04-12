# -*- coding: utf-8 -*-
"""
Created on Thu Nov 23 12:47:18 2023

@author: MatiOliva
"""

from de1soc_class import de1soc_handler
from de1soc_class import FuenteDatos
import matplotlib.pyplot as pl


ip = "192.168.1.2"
plot = False

li = de1soc_handler(ip)

#frecuencias= list(range(800,1201,25))
frecuencias=[4000]

r = []
N = 1
f_externa = 1000

for f in frecuencias:

    li.set_f(f)
    li.set_N(N)
    li.set_M(64)
    li.set_fuente(FuenteDatos.ADC_HS)
    
    data=li.measure_lockin(False)
    r.append(data['r']);
    print(f" -> f: {data['f']} \n -> R: {data['r']}")


if plot:
    frecuencias.append(frecuencias[-1]+25);
    pl.stairs(r,frecuencias);
    pl.title(f"Medidas con N: {N} para una f de entrada de {f_externa}")
    pl.grid();
    pl.show();

