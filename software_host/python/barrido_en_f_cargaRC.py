# -*- coding: utf-8 -*-
"""
Script para realizar barridos en frecuencia sobre una carga RC usando dos lock-ins: 
el lock-in de la FPGA DE1-SoC y el lock-in SR865.

Se obtienen amplitudes y fases de la señal en función de la frecuencia, comparando:
1. Medidas con la FPGA DE1-SoC
2. Medidas con el SR865
3. Resultados teóricos para una carga RC ideal

El script permite:
- Configurar los parámetros de adquisición de cada lock-in (M, N, frecuencia inicial, final, paso)
- Guardar los datos en archivos
- Graficar resultados comparando medidas experimentales y teóricas

Autor: MatiOliva
Creado: Tue Mar 5 15:21:56 2024

Dependencias:
- de1soc_class (control del lock-in de la FPGA)
- sr865_functions (control del SR865)
- matplotlib
- numpy
- funciones.py (cálculos teóricos)

Ejemplo de ejecución:
1. Configurar los parámetros deseados (M, N, nombres de archivo, rangos de frecuencia)
2. Conectar la carga RC
3. Ejecutar el script desde Python
4. Visualizar gráficos de amplitud y fase vs frecuencia
"""


from de1soc_class import de1soc_handler
import matplotlib.pyplot as plt
import numpy as np
import math
import funciones
from sr865_functions import sr865 
import os

# Datos de la carga RC:
R = 680; C=1e-9;
fc = 1/(2*math.pi*R*2*C);

   #    Vdac+ ------ R -------|------- Vadc+     #
   #                          |                  #
   #                                             #
   #                          C                  #
   #                                             #
   #                          |                  #
   #    Vdac- ------ R -------|------- Vadc+     #


#-------------------- Medimos las cosas con el lockin de1soc ----------------------#
medir_de1soc = False;
corregir = False;
M=64
N=128
nombre_archivo_de1soc = "r680c1n_de1soc_3.dat"
directorio_de1soc = "../datos_adquiridos/r680c1n"
file_path_de1s0c = os.path.join(directorio_de1soc,nombre_archivo_de1soc)


if(medir_de1soc):
    f_start = 5000; f_stop = 1000000; step = 10;
    print("Obteniendo datos con el lockin de1soc")
    # Datos para el barrido en frecuencia
       
    ip_de1soc = "192.168.1.102"
    li = de1soc_handler(ip_de1soc);
    li.set_M(M)
    li.set_N(N)
    
    data=li.barrido_lockin(f_start, f_stop, step,corregir,file_path_de1s0c);
    
else:
    file_path = os.path.join(directorio_de1soc,nombre_archivo_de1soc)
    data=de1soc_handler.leer_archivo_barrido(file_path, corregir,M)

# Lista para almacenar las amplitudes obtenidas para cada frecuencia ensayada
amplitudes = []
fases = []
frecuencias = []

# Realiza el barrido en frecuencia y obtiene las amplitudes y fases correspondientes
for dato in data:
    amplitudes.append(dato['r'])
    fases.append(dato['phi'])
    frecuencias.append(dato['f'])




#-------------------- Medimos las cosas con el lockin sr865 ----------------------#
medir_sr865 = True;
graficar_sr865 = True;
nombre_archivo_sr865 = "r680c1n_sr865.dat"
directorio_sr865 = "../datos_adquiridos/r680c1n"
file_path_sr865 = os.path.join(directorio_sr865,nombre_archivo_sr865)

if(medir_sr865):
    # Datos para el barrido en frecuencia
    f_start = 5000; f_stop = 1000000; step = 100;
    
    
    input("Datos con el de1soc listos. Conecte sr865 a la carga...")
    ip_sr865 = '192.168.1.4'
    sr865_inst = sr865(ip_sr865)
    tension_referencia = 500
    
    data_sr865 = sr865_inst.barrido_en_f(tension_referencia, f_start, f_stop, step,file_path_sr865)
    
elif (graficar_sr865):
    
    data_sr865 = sr865.leer_archivo_barrido(file_path_sr865)
    


#-------------------------------- Datos teoricos ----------------------------------# 
data_teorica = funciones.TransferenciaTeorica_RC_ideal(R,C,frecuencias[0],frecuencias[-1],len(data))    





#-------------------------------- Graficos ----------------------------------# 
# %matplotlib qt -> Para poder hacerle zoom a los graficos ejecutar esto

# Crea una figura y ejes para los subplots
fig, axs = plt.subplots(2, 1, figsize=(10, 8))


# Subplot para la amplitud (r) vs frecuencia (f)
axs[0].semilogx(frecuencias, amplitudes, marker='o', linestyle='-',label="Datos de1soc")
axs[0].set_title('Amplitud (r) vs Frecuencia (f)')
axs[0].set_xlabel('Frecuencia (kHz)')
axs[0].set_ylabel('Amplitud (r)')
axs[0].grid(True)


# Agrego medidas teoricas:
axs[0].semilogx(data_teorica['f'],amplitudes[0]*abs(data_teorica['H']),marker='x',linestyle='-',label="Datos teoricos")

# Agrego medidas SR865 
if(graficar_sr865):
    factor_correccion = amplitudes[0]/data_sr865['r'][0]
    axs[0].semilogx(data_sr865['f'],factor_correccion*np.array(data_sr865['r']),marker='v',linestyle='-',label="Datos sr865")

axs[0].legend()

# Subplot para phi vs frecuencia (f)
axs[1].semilogx(frecuencias, fases, marker='o', linestyle='-',label="Datos de1soc")
axs[1].set_title('Phi vs Frecuencia (f)')
axs[1].set_xlabel('Frecuencia (kHz)')
axs[1].set_ylabel('Phi')
axs[1].grid(True)

# Agrego medidas teoricas:
axs[1].semilogx(data_teorica['f'],np.angle(data_teorica['H'])*180/math.pi,marker='x',linestyle='-',label="Datos teoricos")

# Agrego medidas SR865
if(graficar_sr865):
    axs[1].semilogx(data_sr865['f'],data_sr865['phi'],marker='v',linestyle='-',label="Datos sr865")


axs[1].legend()

# Ajusta el diseño para evitar solapamiento
plt.tight_layout()

# Muestra el gráfico
plt.show()