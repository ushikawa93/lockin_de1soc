# -*- coding: utf-8 -*-
"""
Script para adquirir y mostrar datos del ADC del lock-in DE1-SoC

Este script:
- Se conecta a la FPGA DE1-SoC vía IP
- Configura el lock-in para obtener N ciclos de promediación de la señal
- Lee los datos de un FIFO específico del ADC
- Aplica la conversión a voltaje de la señal
- Grafica los datos obtenidos

Parámetros configurables:
- N_promediacion: número de ciclos de promediación
- f: frecuencia de la señal generada
- display_ciclos: cantidad de ciclos que se muestran en la gráfica
- fifo2read: FIFO de lectura del ADC
- sim_noise: nivel de ruido simulado

Autor: MatiOliva
Creado: 2024
"""



from de1soc_class import de1soc_handler
from de1soc_class import FuenteDatos

import matplotlib.pyplot as plt


ip = "192.168.1.2"
N_promediacion = 1;

# Para generar una sinusoide:
f = 50000;


display_ciclos = 2;
fifo2read = 0;

li = de1soc_handler(ip);
li.set_N(N_promediacion)
li.set_f(f);
li.set_fuente(FuenteDatos.ADC_HS)
li.set_sim_noise(12);

medidas1 = [(valor-8192)*125e-6 / N_promediacion for valor in li.get_adc(display_ciclos,fifo2read)]

"""
fifo2read = 1;

medidas2 = [valor / N_promediacion for valor in li.get_adc(display_ciclos,fifo2read)]
"""
plt.plot(medidas1,marker='x');
#plt.plot(medidas2,marker='x');
plt.grid();
plt.show();


