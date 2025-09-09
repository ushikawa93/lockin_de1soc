# -*- coding: utf-8 -*-
"""
Python class to interface with the SR865 Lock-In Amplifier

Este módulo permite:
- Conectar con un SR865 vía VXI-11 usando su IP
- Configurar parámetros de referencia (frecuencia y tensión)
- Seleccionar variables a capturar: X, XY, RT, XYRT
- Configurar tamaño del buffer de adquisición y tasa máxima
- Capturar datos y leerlos desde el buffer
- Guardar los datos en archivos CSV
- Realizar barridos en frecuencia y procesar resultados (amplitud y fase)

Clases principales:
- sr865: clase para manejar el Lock-In
- OpcionesCaptura: enumeración de configuraciones de captura (X, XY, RT, XYRT)

Dependencias:
- vxi11 (librería necesaria para la comunicación con el instrumento)
- numpy
- csv
- time
- struct

Autor: MatiOliva
Creado: 2022
"""


from enum import IntEnum
from struct import unpack_from
import csv
import time
import numpy as np

try:
    import vxi11            # required
except ImportError:
    print('required python vxi11 library not found. Please install vxi11')

class OpcionesCaptura (IntEnum):
    X = 0
    XY = 1
    RT = 2
    XYRT = 3

class sr865:
    
    SR865_handler = None;
        
    def __init__(self, ip_addr= '192.168.1.4'):
        print('Abriendo el SR865 en el puerto %s ...'%ip_addr)
        self.SR865_handler = vxi11.Instrument(ip_addr)   
    
    def sendCommand(self,command):
        self.SR865_handler.write(command)
        
    # Setea la frecuencia de la referencia. Valor en Hz
    def set_frecuencia_referencia(self,frecuencia):
        self.sendCommand('FREQ ' + str(frecuencia) )
        
    # Setea la tension de la referencia en mV
    def set_tension_referencia(self,tension):
        self.sendCommand( 'SLVL ' + str(tension) + ' MV' )
        
    # Esta funcion setea todo lo que necesito y hace la captura de datos sin hacer tanto quilombo
    # para hacerlo usa todas las funciones que fui definiendo abajo
    def configurar_buffer_y_capturar(self,cantidad_de_datos,variables_a_capturar):
        self.stop_capture()
        self.set_variables_a_capturar(variables_a_capturar)
        k_bytes_necesarios = max (1 , round ( (cantidad_de_datos * 4 * ( int(variables_a_capturar)+1 ) ) / 1024.0))
        self.set_capture_buffer_length(k_bytes_necesarios)
        self.capture_data(cantidad_de_datos, variables_a_capturar)
        return self.recuperar_data(cantidad_de_datos, variables_a_capturar)    
    
        
    # Setea que variables queremos obtener (X,XY,RT,XYRT)
    def set_variables_a_capturar(self, variables_a_capturar):
        if(isinstance(variables_a_capturar,OpcionesCaptura)):
            self.sendCommand( 'CAPTURECFG ' + str(int(variables_a_capturar)) )
            
    # Setea el tamaño del buffer a un valor en kBytes
    # Cada valor (X,Y,R o T) ocupa 4 Bytes
    # Si estamos obteniendo los 4 y ponemos la cosa en 1 KB -> 1024/(4*4) = 64 datos
    # El valor siempre es par, si se le pone un impar redondea para arriba
    def set_capture_buffer_length(self,length_kb):
        if(length_kb > 1 and length_kb < 4096):
            self.sendCommand(' CAPTURELEN ' + str(length_kb))
    
    # Obtiene el tamaño del buffer de adquisicion.
    def get_capture_buffer_length(self):
        length_kB = float (self.SR865_handler.ask('CAPTURELEN?'))
        return length_kB

    # Obtiene la maxima tasa de captura en Hz. Depende de la constante de tiempo de los filtros.
    def get_capture_rate_max(self):
        length_max = float (self.SR865_handler.ask('CAPTURERATEMAX?'))
        return length_max
    
    # Detiene cualquier captura que este en proceso
    def stop_capture(self):
        self.sendCommand('CAPTURESTOP')
        
    # Empieza la captura y espera el tiempo necesario para recuperar "cantidad_a_capturar" datos
    # Si no le alcanza el buffer de adquisicion para los datos que tiene que adquirir avisa
    def capture_data(self , cantidad_a_capturar , variables_a_capturar ):
        largo_del_buffer = self.get_capture_buffer_length() * 1024
        bytes_necesarios = round ( (cantidad_a_capturar * 4 * ( int(variables_a_capturar)+1 ) ) )
        if(isinstance(variables_a_capturar,OpcionesCaptura) and (bytes_necesarios < largo_del_buffer) ):            
            self.sendCommand('CAPTURESTART ONE, IMM')
            bytes_captured = 0
            
            while (bytes_captured < bytes_necesarios):
                bytes_captured = int(self.SR865_handler.ask('CAPTUREBYTES?'))
            
            self.sendCommand('CAPTURESTOP')
            return bytes_captured;
        else:
            print("El largo del buffer de adquisicion no es suficientemente largo para los datos que quiere obtener")
            return 0;
                
        
    # Lee el buffer de adquisicion
    def recuperar_data(self,cantidad_a_capturar,variables_a_capturar):
        f_data = []
        n_data = ( int(variables_a_capturar)+1 )
        
        k_bytes_necesarios = max (1 , round ( (cantidad_a_capturar * 4 * n_data ) / 1024.0))
        self.sendCommand('CAPTUREGET? 0, ' + str(k_bytes_necesarios))
        buf = self.SR865_handler.read_raw()
                
        # El lockin me manda primero un # y despues 
        raw_data = buf[2 + int(buf[1]):]        
        f_block_data = list(unpack_from('<%df' %(4*cantidad_a_capturar), raw_data))
                
        for i in range (0, cantidad_a_capturar):
            f_data.append( f_block_data[i*4:i*4+n_data] )
        return f_data
    
    def write_data_to_file( self, file_name, variables_a_capturar, datos ):
        
        if(isinstance(variables_a_capturar,OpcionesCaptura)):
            if((variables_a_capturar) == OpcionesCaptura.X):
                campos = ['frecuencia','X']
            elif((variables_a_capturar) == OpcionesCaptura.XY):
                campos = ['frecuencia','X','Y']
            elif((variables_a_capturar) == OpcionesCaptura.RT):
                campos = ['frecuencia','X','Y','R'] 
            elif((variables_a_capturar) == OpcionesCaptura.XYRT):
                campos = ['frecuencia','X','Y','R','T'] 
        
        
        with open(file_name, 'w') as f:
            # using csv.writer method from CSV package
            write = csv.writer(f)
              
            write.writerow(campos)
            write.writerows(datos)
            
            
    def barrido_en_f(self, tension, f_inicio, f_final, f_step , nombre_archivo=None ):

        
        self.set_tension_referencia(tension)
        self.set_frecuencia_referencia(f_inicio)
        time.sleep(4)
    
        # Adquisición de datos
        resultados = []
    
        for frec in range(f_inicio, f_final + 1, f_step):
           self.set_frecuencia_referencia(frec)
           dato = self.configurar_buffer_y_capturar(1, OpcionesCaptura.XYRT)
           dato[0].insert(0, frec)
           resultados.append(dato[0])

        # Guardar datos en CSV si se proporciona un nombre de archivo
        if nombre_archivo:
           self.write_data_to_file(nombre_archivo, OpcionesCaptura.XYRT, resultados)
        
        # Procesamiento de resultados
        frecuencias = np.array([r[0] for r in resultados])
        tensiones = np.array([r[3] for r in resultados])
        fases = np.array([r[4] for r in resultados])
        
        return {'f': frecuencias, 'r': tensiones,'phi': fases}

    @staticmethod
    def leer_archivo_barrido(file_path):
        
        data_sr865 = []
        with open(file_path, newline='') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                data_sr865.append(row)

        amplitudes = []; fases = []; frecuencias = []

        # Realiza el barrido en frecuencia y obtiene las amplitudes y fases correspondientes
        for dato in data_sr865:
            amplitudes.append(float(dato['R']))
            fases.append(float(dato['T']))
            frecuencias.append(float(dato['frecuencia']))

        
        return {'f': frecuencias, 'r': amplitudes,'phi': fases}
        
        
        
        
        
        
        
