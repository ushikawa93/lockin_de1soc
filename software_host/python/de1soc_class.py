# -*- coding: utf-8 -*-
"""
Python class to command the de1soc lockin

@author: MatiOliva
"""

import subprocess
import os
from enum import Enum

class de1soc_handler:

    def __init__(self, ip_):
        self.f = 1000000
        self.M = 32 
        self.N = 1
        self.set_IP(ip_)
        self.fuente = FuenteDatos.ADC_HS
        self.modo = ModoProcesamiento.CALI
        
    def barrido_lockin(self,f_inicial,f_final,f_step,corregir,file_path):
                
        file_aux = "datos_barrido_aux.dat"

        script_path = os.path.join("..\shell_scripts", "barrido_en_f.sh")
        command = (
            f"{script_path} {self.M} {self.N} {self.fuente.value} {self.modo.value} {f_inicial} {f_final} {f_step} {file_aux} {self.ip}"
        )        

        self.proceso(command)        
        self.eliminar_duplicados_por_f(file_aux, file_path)
        os.remove(file_aux)
        return self.leer_archivo_barrido(file_path,corregir);
        
    def measure_lockin(self,corregir):
                
        file = "datos.dat"
        
        script_path = os.path.join("..\shell_scripts", "measure_lockin.sh")
        command = (
            f"{script_path} {self.M} {self.N} {self.f} {self.fuente.value} {self.modo.value} {file} {self.ip}"
        )
        
        self.proceso(command)
        file_path = os.path.join("..\datos_adquiridos",file)
        return self.leer_archivo_lockin(file_path,corregir);
    
    def get_adc(self,ciclos2display):
        
        file = "datos_adc.dat"        
        
        script_path = os.path.join("..\shell_scripts", "adquirir.sh")
        command = (
            f"{script_path} {self.M} {self.N} {self.f} {ciclos2display} {file} {self.ip}"
        )
        
        de1soc_handler.proceso(command)
        file_path = os.path.join("..\datos_adquiridos",file)
        return self.leer_archivo_adc(file_path);
        
    def set_IP(self, ip_):
        if self.is_valid_IP(ip_):
            self.ip = ip_
            return True
        return False
    
    def is_valid_IP(self, ip_):
        num_fields = 0
        ip_stream = ip_.split('.')
        for field in ip_stream:
            if not field or len(field) > 3 or not field.isdigit():
                return False

            field_value = int(field)
            if field_value < 0 or field_value > 255:
                return False

            num_fields += 1

        return num_fields == 4
    
    def set_f(self, valor_f):
        if(valor_f <= 2000000 and valor_f > 1):
            self.f = valor_f
        else:
            self.f = 100000

    def set_M(self, valor_M):
        if(valor_M <= 2048 and valor_M > 1):
            self.M = valor_M
        else:
            self.M = 32

    def set_N(self, valor_N):
        self.N = valor_N
        
    @staticmethod
    def cuentas2volt(cuentas):
        factor = 179e-6;
        
        return factor*cuentas;
    
    @staticmethod
    def corregir_etapa_analogica(medida,M):
        
        if(M == 32):
            correccion = de1soc_handler.encontrar_medida_mas_cercana("transferencias_sin_carga/barrido_sin_carga_M32.dat",medida['f']);
        if(M == 64):
             correccion = de1soc_handler.encontrar_medida_mas_cercana("transferencias_sin_carga/barrido_sin_carga_M64.dat",medida['f']); 
        if(M == 128):
            correccion = de1soc_handler.encontrar_medida_mas_cercana("transferencias_sin_carga/barrido_sin_carga_M128.dat",medida['f']);
        else:
            print("Transferencia sin carga no medida para el M actual")
            return 
        
        r0=7429.145285;
        r = medida['r'] * r0 / correccion['r'] 
        phi = medida['phi'] - correccion['phi']
        
        return {'f': medida['f'], 'r': r, 'phi': phi}
        
    
    @staticmethod
    def leer_archivo_lockin(nombre_archivo,corregir):
    
       with open(nombre_archivo, 'r') as archivo:
           lineas = archivo.readlines()

           # Inicializar variables
           f, M, N, x, y, r, phi = None, None, None, None, None, None, None

           # Leer y procesar cada línea
           for linea in lineas:
               if '=' in linea:
                nombre, valor = linea.split('=')
                nombre = nombre.strip()
                valor = float(valor.strip())
                if nombre == 'f':
                    f = valor
                elif nombre == 'M':
                    M = valor
                elif nombre == 'N':
                    N = valor
                elif nombre == 'x':
                    x = valor
                elif nombre == 'y':
                    y = valor
                elif nombre == 'r':
                    r = de1soc_handler.cuentas2volt(valor)
                elif nombre == 'phi':
                    phi = valor
                
           if(corregir == True):
                correccion = de1soc_handler.corregir_etapa_analogica({'f': f, 'r':r, 'phi':phi}, M)
                r = correccion['r']
                phi=correccion['phi']

       return {'f': f, 'M':M, 'N':N, 'x':x, 'y':y, 'r':r, 'phi':phi}
    
    @staticmethod
    def leer_archivo_adc(nombre_archivo):
        # Lista para almacenar los valores
        valores = []
        
        # Abrir el archivo y leer los valores línea por línea
        with open(nombre_archivo, "r") as archivo:
            for linea in archivo:
                # Eliminar cualquier carácter de espacio en blanco alrededor del valor y dividir la línea en valores individuales
                valores_linea = linea.strip().split(",")
                # Convertir cada valor a un número de punto flotante y agregarlo a la lista de valores
                for valor in valores_linea:
                    if valor:  # Ignorar valores vacíos
                        valores.append(float(de1soc_handler.cuentas2volt(valor)))
                        
        return valores;
    
    @staticmethod
    def leer_archivo_barrido(nombre_archivo,corregir):
        datos = []
        with open(nombre_archivo, 'r') as archivo:
           
            lines = archivo.readlines()
        
            # Leer los datos y almacenarlos en la lista
            
            for line in lines[4:]:
                valores = line.strip().split(',')
                f = float(valores[0])
                r = de1soc_handler.cuentas2volt(float(valores[3]))
                phi = float(valores[4])
                dato= {'f': f, 'r': r, 'phi': phi}
                if(corregir == True):                
                    dato_corregido = de1soc_handler.corregir_etapa_analogica(dato,32)
                    datos.append(dato_corregido)
                else:
                    datos.append(dato)
            
            return datos
    
    @staticmethod
    def eliminar_duplicados_por_f(archivo_entrada, archivo_salida):
        f_set = set()
    
        with open(archivo_entrada, 'r') as entrada, open(archivo_salida, 'w') as salida:
            lines = entrada.readlines()
            salida.write(lines[0]);
            salida.write(lines[1]);
            salida.write(lines[2]);
            salida.write(lines[3]);
            for linea in lines[4:]:
                partes = linea.strip().split(',')
                f = float(partes[0])
                if f not in f_set:
                    salida.write(linea)
                    f_set.add(f)
                    
    @staticmethod
    def encontrar_medida_mas_cercana(archivo_entrada, f_deseado):
        mejor_linea = None
        mejor_diferencia = float('inf')
    
        with open(archivo_entrada, 'r') as archivo:
            lineas=archivo.readlines();
            for linea in lineas[4:]:
                partes = linea.strip().split(',')
                f_actual = float(partes[0])
                diferencia = abs(f_deseado - f_actual)
                if diferencia < mejor_diferencia:
                    mejor_linea = linea
                    mejor_diferencia = diferencia
                    
        partes=mejor_linea.split(',');
        f = float(partes[0])
        r = float(partes[3])
        phi = float(partes[4])
        return {'f': f, 'r': r, 'phi': phi}
    
    @staticmethod
    def proceso(comando):
        print(f"Comando enviado a FPGA: {comando}")
        my_env = os.environ.copy()
        my_env["HOME"] = "C:\\Users\\MatiOliva"
        subprocess.run(comando, shell=True,env=my_env)

class FuenteDatos(Enum):
    ADC_2308 = 0
    ADC_HS = 1
    SIM = 2

class ModoProcesamiento(Enum):
    CALI = 0
    LI = 1
