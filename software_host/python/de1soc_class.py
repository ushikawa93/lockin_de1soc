# -*- coding: utf-8 -*-
"""
Python class to command the de1soc lockin

@author: MatiOliva
"""

import subprocess
import os
from enum import Enum

class de1soc_handler:
    
    """ ------------------------------------- """
    """ ------------ Constructor ------------ """
    """ ------------------------------------- """
    
    def __init__(self, ip_):
        self.set_f(1000000)
        self.set_N(1)
        self.set_IP(ip_)
        self.set_fuente(FuenteDatos.SIM)
        self.set_modo_procesamiento(ModoProcesamiento.LI)
        self.set_sim_noise(0)
        self.set_f_clk(64);
        
    
    
    """ ------------------------------------------ """
    """ ------------ Geters y setters ------------ """
    """ ------------------------------------------ """
        
    def set_IP(self, ip_):
        if self.is_valid_IP(ip_):
            self.ip = ip_
            return True
        return False
    
    def set_sim_noise(self,noise):
        self.sim_noise = noise;
    
        
    def set_f(self, valor_f):
        if(valor_f <= 32000000 and valor_f >= 0.5):
            self.f = valor_f
        else:
            self.f = 100000
            
    def set_f_clk(self,valor_f):
        if(valor_f >= 1 and valor_f < 65):
            self.f_clk = valor_f;
        else:
            self.f_clk = 64;

    def set_N(self, valor_N):
        self.N = valor_N
        
    def set_fuente(self,fuente):
        if(isinstance(fuente,FuenteDatos)):
            self.fuente = fuente
       
    def set_modo_procesamiento(self,modo):
        if(isinstance(modo,ModoProcesamiento)):
            self.modo = modo      
        
    
    
    
    """ ---------------------------------------------------- """    
    """ ------------ Obtener resultados del ADC ------------ """
    """ ---------------------------------------------------- """
    
    def get_adc(self,ciclos2display,fifo2read):
         
        file = "datos_adc.dat"        
         
        script_path = os.path.join("..\shell_scripts", "adquirir.sh")
        command = (
            f"{script_path} {self.N} {self.f} {ciclos2display} {file} {fifo2read} {self.ip} "
        )
         
        de1soc_handler.proceso(command)
        file_path = os.path.join("..\datos_adquiridos",file)
        return self.leer_archivo_adc(file_path);
    
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
                        valores.append(float(de1soc_handler.cuentas2volt(float(valor),True)))
                        
        return valores;
        
    
    
    """ ------------------------------------------------------- """
    """ ------------ Obtener resultados del Lockin ------------ """
    """ ------------------------------------------------------- """
    
    def measure_lockin(self,corregir):
                
        file = "datos.dat"
        
        script_path = os.path.join("..\shell_scripts", "measure_lockin.sh")
        command = (
            f"{script_path} {self.sim_noise} {self.N} {self.f} {self.fuente.value} {self.modo.value} {file} {self.ip}"
        )
        
        self.proceso(command)
        file_path = os.path.join("..\datos_adquiridos",file)
        return self.leer_archivo_lockin(file_path,corregir);
    
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
                    r = de1soc_handler.cuentas2volt(valor,False)
                elif nombre == 'phi':
                    phi = valor
                
           if(corregir == True):
                correccion = de1soc_handler.corregir_etapa_analogica({'f': f, 'r':r, 'phi':phi}, M)
                r = correccion['r']
                phi=correccion['phi']

       return {'f': f, 'M':M, 'N':N, 'x':x, 'y':y, 'r':r, 'phi':phi}
   
    
   
    """ ------------------------------------------------------- """
    """ ------------ Barrido en frecuencia lockin ------------- """
    """ ------------------------------------------------------- """
    
    
    def barrido_lockin(self,f_inicial,f_final,f_step,corregir,file_name="datos_barrido.dat"):
                

        script_path = os.path.join("..\shell_scripts", "barrido_en_f.sh")
        command = (
            f"{script_path} {self.f_clk} {self.N} {self.fuente.value} {self.modo.value} {f_inicial} {f_final} {f_step} {file_name} {corregir*1} {self.sim_noise} {self.ip}"
        )

        self.proceso(command) 
        return self.leer_archivo_barrido(os.path.join("..\datos_adquiridos",file_name));
    
    
    @staticmethod
    def leer_archivo_barrido(nombre_archivo):
        datos = []
        with open(nombre_archivo, 'r') as archivo:
           
            lines = archivo.readlines()
        
            # Leer los datos y almacenarlos en la lista
            
            for line in lines[4:]:
                valores = line.strip().split(',')
                f = float(valores[0])
                r = float(valores[3])
                phi = float(valores[4])
                dato= {'f': f, 'r': r, 'phi': phi}
                datos.append(dato)                
            
            return datos
  
    
  
    """ ------------------------------------------------------- """
    """ ------------------ Funciones auxiliares --------------- """
    """ ------------------------------------------------------- """   
    
    @staticmethod
    def cuentas2volt(cuentas,desafectar_v_medio):
        #factor = 125e-6;
        #valor_medio=0
        factor=1;valor_medio=0;
        if desafectar_v_medio:
            return factor*(cuentas-valor_medio);
        return factor*cuentas; 
        
    
    @staticmethod
    def proceso(comando):
        print(f"Comando enviado a FPGA: {comando}")
        my_env = os.environ.copy()
        my_env["HOME"] = "C:\\Users\\MatiOliva"
        subprocess.run(comando, shell=True,env=my_env)
        
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
    
    


""" ------------------------------------------------------- """
""" -------------- Enumeraciones auxiliares --------------- """
""" ------------------------------------------------------- """   

class FuenteDatos(Enum):
    ADC_2308 = 0
    ADC_HS = 1
    SIM = 2

class ModoProcesamiento(Enum):
    CALI = 0
    LI = 1
