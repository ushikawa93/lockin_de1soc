# -*- coding: utf-8 -*-
"""
Created on Fri Apr  5 13:49:49 2024

Script para medir ruido en el Lockin.. ¡cortocircuitar entradas!

@author: MatiOliva
"""


from de1soc_class import de1soc_handler
import matplotlib.pyplot as pl
import statistics

ip = "192.168.1.102"
li = de1soc_handler(ip)

Ns = [1,10,50,100,200,500,1000]
iteraciones = 10

desv_estandar_ruido=[]
promedio_ruido = []

for N in Ns:
    
    frecuencia=10000
    li.set_f(frecuencia)
    li.set_N(N)
    li.set_M(512)
    
    r= []
    
    for i in range(1,iteraciones):
        
        data=li.measure_lockin(False);
        r.append(data['r']);    
        #print(f" -> f: {data['f']} \n -> R: {data['r']}")
    
    mean_ruido = statistics.mean(r)
    std_ruido = statistics.stdev(r)
    desv_estandar_ruido.append(std_ruido)
    promedio_ruido.append(mean_ruido)
    
    print(f" ->Medidas con N: {N}\n Valor medio de mediciones: {mean_ruido} cuentas\n -> Desviación estándar de mediciones: {std_ruido} cuentas")


pl.semilogx(Ns,desv_estandar_ruido,marker='x')
pl.grid()
pl.title("Desviacion estandar de ruido")
pl.xlabel("N");pl.ylabel("$\sigma$")
pl.show();

print(f"Promedio del ruido: {statistics.mean(promedio_ruido)}")
