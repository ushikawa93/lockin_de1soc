# -*- coding: utf-8 -*-
"""
Script para realizar un barrido en frecuencia utilizando el lock-in de la FPGA DE1-SoC.

El script:
- Configura el lock-in con parámetros de adquisición (f_clk, N, fuente de datos y modo de procesamiento)
- Realiza un barrido de frecuencia desde f_start hasta f_stop con pasos definidos
- Almacena amplitud (r) y fase (phi) de la señal para cada frecuencia
- Grafica amplitud vs frecuencia y fase vs frecuencia

Autor: MatiOliva
Creado: Tue Mar 5 15:21:56 2024

Dependencias:
- de1soc_class (control del lock-in de la FPGA)
- matplotlib

Parámetros de ejemplo:
- ip: Dirección IP de la FPGA DE1-SoC
- f_start, f_stop, step: Rango y paso del barrido en Hz
- corregir_fase: Booleano para corrección de fase de la señal
- FuenteDatos: ADC_HS, ADC_2308 o SIMULACION
- ModoProcesamiento: CALI o LI

Uso:
1. Configurar los parámetros deseados (IP, fuente, modo, f_start, f_stop, step)
2. Ejecutar el script desde Python
3. Visualizar gráficos de amplitud y fase vs frecuencia
"""


from de1soc_class import de1soc_handler
import matplotlib.pyplot as plt
from de1soc_class import FuenteDatos
from de1soc_class import ModoProcesamiento


ip = "192.168.1.2"

li = de1soc_handler(ip);


li.set_f_clk(64);
li.set_N(32)
li.set_modo_procesamiento(ModoProcesamiento.CALI)
li.set_fuente(FuenteDatos.ADC_HS)


f_start = 10000
f_stop = 2000000
step = 1000
corrregir_fase = True;

data=li.barrido_lockin(f_start, f_stop, step,corrregir_fase);


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