# -*- coding: utf-8 -*-
"""
Created on Tue Mar  5 15:21:56 2024

@author: MatiOliva
"""

from de1soc_class import de1soc_handler
import matplotlib.pyplot as plt


ip = "192.168.1.2"

li = de1soc_handler(ip);
li.set_M(32)
li.set_N(32)

f_start = 10
f_stop = 40000
step = 10

data=li.barrido_lockin(f_start, f_stop, step,False);


# Lista para almacenar las amplitudes obtenidas para cada frecuencia ensayada
amplitudes = []
fases = []
frecuencias = []

# Realiza el barrido en frecuencia y obtiene las amplitudes y fases correspondientes
for dato in data:
    amplitudes.append(dato['r'])
    fases.append(dato['phi'])
    frecuencias.append(dato['f'])
    


# Crea una figura y ejes para los subplots
fig, axs = plt.subplots(2, 1, figsize=(10, 8))

# Subplot para la amplitud (r) vs frecuencia (f)
axs[0].semilogx(frecuencias, amplitudes, marker='o', linestyle='-')
axs[0].set_title('Amplitud (r) vs Frecuencia (f)')
axs[0].set_xlabel('Frecuencia (kHz)')
axs[0].set_ylabel('Amplitud (r)')
axs[0].grid(True)

# Subplot para phi vs frecuencia (f)
axs[1].semilogx(frecuencias, fases, marker='o', linestyle='-')
axs[1].set_title('Phi vs Frecuencia (f)')
axs[1].set_xlabel('Frecuencia (kHz)')
axs[1].set_ylabel('Phi')
axs[1].grid(True)

# Ajusta el diseño para evitar solapamiento
plt.tight_layout()

# Muestra el gráfico
plt.show()