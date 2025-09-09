# Control y adquisición de datos con Lock-In Amplifiers vía Python

Este repositorio contiene scripts y clases en Python para controlar y obtener datos de dos tipos de lock-in: el Lock-in basado en la FPGA DE1-SoC y el Lock-in SR865. Todos los scripts están diseñados para ejecutarse desde una computadora host que se conecta al equipo vía SSH, utilizando la IP correspondiente de cada dispositivo.

---

## Estructura de clases y scripts

### Clase `de1soc_handler`

Permite manejar la FPGA DE1-SoC de manera remota usando su IP. Entre sus funcionalidades principales están:

- Configuración de parámetros de adquisición:
  - Frecuencia de señal (`set_f`)
  - Número de ciclos de promediación (`set_N`)
  - Fuente de datos (`set_fuente`): ADC_HS, ADC_2308 o simulación
  - Modo de procesamiento (`set_modo_procesamiento`): CALI o Lock-In
  - Frecuencia del reloj principal (`set_f_clk`)
  - Nivel de ruido simulado (`set_sim_noise`)
  
- Obtención de datos del ADC (`get_adc`) y del Lock-In (`measure_lockin`)

- Barridos en frecuencia (`barrido_lockin`), que permiten generar listas de amplitudes y fases sobre un rango de frecuencias

- Funciones auxiliares para lectura de archivos y conversión de cuentas a voltaje

- Verificación de validez de la IP y ejecución de comandos remotos vía scripts de shell en la FPGA

---

### Clase `FuenteDatos` y `ModoProcesamiento`

Enumeraciones auxiliares utilizadas por `de1soc_handler`:

- `FuenteDatos`:
  - `ADC_2308`: ADC de resolución estándar
  - `ADC_HS`: ADC de alta velocidad
  - `SIM`: Datos simulados

- `ModoProcesamiento`:
  - `CALI`: Modo calibración
  - `LI`: Modo Lock-In

---

### Clase `sr865`

Controla el Lock-In SR865 vía VXI-11 usando la IP del instrumento.

Funcionalidades principales:

- Configuración de la frecuencia y tensión de referencia
- Selección de variables a capturar: X, XY, RT, XYRT
- Configuración del tamaño del buffer y tasa de captura máxima
- Captura de datos en tiempo real y lectura del buffer
- Guardado de resultados en archivos CSV
- Barrido en frecuencia con adquisición de amplitud (R) y fase (T)

Enumeración auxiliar `OpcionesCaptura`:

- `X`: Captura solo X
- `XY`: Captura X y Y
- `RT`: Captura R y T
- `XYRT`: Captura X, Y, R y T

---

## Scripts de ejemplo

### Barrido y comparación DE1-SoC vs SR865

- Permite realizar barridos en frecuencia con la FPGA DE1-SoC y luego medir con el SR865.
- Genera gráficos comparativos de amplitud y fase.
- Incluye la posibilidad de aplicar corrección de fase para compensar retrasos en la etapa analógica.

### Medición de ruido en la FPGA

- Evalúa la desviación estándar del ruido del Lock-In DE1-SoC para diferentes valores de N (ciclos de promediación).
- Imprime resultados en consola y genera un gráfico logarítmico de la desviación estándar vs N.

### Captura de ADC

- Scripts simples para leer datos del ADC de la FPGA DE1-SoC.
- Permite configurar número de ciclos y seleccionar la FIFO a leer.

### Medición Lock-In con simulación

- Permite medir señales simuladas con la FPGA DE1-SoC.
- Configuración de N y M para promediación coherente y cálculo de Lock-In.

### Medición Lock-In con fuente simulada

- Realiza mediciones de una señal simulada, calculando amplitud y fase.
- Configurable para diferentes frecuencias y ciclos de promediación.

---

## Requisitos

- Python 3.x
- Librerías: `matplotlib`, `numpy`, `statistics`, `vxi11` (para SR865)
- Conexión SSH al dispositivo FPGA DE1-SoC o al Lock-In SR865 con IP accesible

---

## Uso general

1. Conectar la computadora host a la red del dispositivo.
2. Ejecutar los scripts de Python pasando la IP correspondiente de la FPGA o SR865.
3. Configurar parámetros como frecuencia, N, M, fuente y modo de procesamiento según sea necesario.
4. Ejecutar mediciones, barridos o capturas y visualizar los resultados con matplotlib o guardarlos en archivos CSV/dat.

---

Autor: MatiOliva  
Fecha de creación: 2022-2024  
