# -*- coding: utf-8 -*-
"""
Script para medir la respuesta del lock-in DE1-SoC usando señal simulada

Este script:
- Se conecta a la FPGA DE1-SoC vía IP
- Configura el lock-in para operar en modo LI (Lock-In)
- Establece la fuente de datos como simulada
- Ajusta la frecuencia de la señal y el número de ciclos de promediación
- Obtiene las medidas de r (amplitud) y phi (fase) para cada frecuencia
- Imprime los resultados en consola

Parámetros configurables:
- frecuencias: lista de frecuencias a medir
- N: número de ciclos de promediación
- sim_noise: nivel de ruido simulado
- modo_procesamiento: CALI o LI
- fuente: ADC o simulación

Autor: MatiOliva
Creado: 2023
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

