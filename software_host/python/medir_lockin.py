# -*- coding: utf-8 -*-
"""
Created on Thu Nov 23 12:47:18 2023

@author: MatiOliva
"""

from de1soc_class import de1soc_handler
from de1soc_class import FuenteDatos
from de1soc_class import ModoProcesamiento


ip = "192.168.1.2"
li = de1soc_handler(ip)

#frecuencias= list(range(800,1201,25))
frecuencias=[10000]

r = []
N = 2


for f in frecuencias:

    li.set_sim_noise(0)
    li.set_f(f)
    li.set_N(N)
    li.set_modo_procesamiento(ModoProcesamiento.LI)
    li.set_fuente(FuenteDatos.SIM)
    
    data=li.measure_lockin(False)
    r.append(data['r']);
    print(f" -> f: {data['f']} \n -> R: {data['r']} \n -> phi: {data['phi']}")

