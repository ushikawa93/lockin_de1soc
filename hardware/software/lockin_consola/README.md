# 🎛️ Lock-in DE1-SoC - Consola

Este proyecto implementa una aplicación de consola (`lockin_consola`) en **C#** que controla un sistema **Lock-in Amplifier** sobre FPGA (DE1-SoC).  
La comunicación con la FPGA se realiza mediante **pipes**, apoyándose en un programa auxiliar escrito en **C++** que actúa como driver de bajo nivel.

---

## 📦 Requisitos

- **.NET 6.0 o superior** (para compilar/ejecutar `lockin_consola` en C#).
- **Compilador C++ (g++ o equivalente)** para el programa auxiliar.
- **Linux / WSL** (recomendado) o entorno compatible con shell scripts.
- **FPGA DE1-SoC** conectada y programada con el bitstream correspondiente.
- Carpeta `results/` creada en el directorio de trabajo.
- Implementación "mono" del framework de .NET

---

## ⚙️ Componentes principales

- **`lockin_consola` (C#)**  
  Programa principal que:
  - Configura parámetros del lock-in (fuente, M, N, ruido, etc).
  - Inicia y detiene medidas.
  - Lee resultados de las FIFOs de la FPGA.
  - Ejecuta barridos en frecuencia y N.
  - Genera archivos de resultados y calibración.

- **Programa C++ (pipe server/driver)**  
  Interfaz de bajo nivel que permite la comunicación con la FPGA mediante memoria mapeada.

- **`run_lia_consola.sh`**  
  Script que:
  1. Lanza el programa C++ (driver de pipes).
  2. Ejecuta el programa `lockin_consola` en C#.

---

## 🚀 Uso

1. **Compilar el programa C++**  
   ```bash
   g++ -o fpga_driver driver.cpp
(Reemplazar driver.cpp por el nombre real del archivo fuente).

2. Ejecutar todo con el script
./run_lia_consola.sh

Esto inicia el servidor C++ y abre el menú interactivo de lockin_consola.

📂 Archivos generados

- results/<archivo>.dat → resultados de medidas y barridos.

- results/<barrido>_cali.dat y results/<barrido>_li.dat → comparaciones CALI vs LI.

- transferencia.dat → archivo de calibración de la cadena analógica.

🖥️ Menú principal (lockin_consola)

- Dentro de la aplicación de consola se ofrecen varias opciones:

  - Cambiar configuración del sistema (fuente, frecuencia, N, M, archivo, etc).

  - Iniciar medida y mostrar resultados.

  - Imprimir valores almacenados en memoria (FIFOs).

  - Barrido en frecuencia (genera CSV en results/).

  - Barrido de constantes de tiempo N.

  - Comparar resultados entre LI y CA-LI.

  - Enviar archivo de resultados al host.

  - Generar/actualizar transferencia.dat (calibración).

  - Salir.

📝 Notas

Antes de ejecutar, asegurarse de tener la FPGA programada y el directorio results/ creado.

El programa lockin_consola es interactivo: solicita parámetros y genera archivos automáticamente.

Para pruebas sin hardware se puede usar el modo simulación (fuente = 2).

📖 Referencia rápida de parámetros

  - fuente (parameter_out_0) → 0=ADC_2308, 1=ADC_HS, 2=Simulación

  - M (parameter_out_1) → puntos por ciclo

  - N_ma_CALI (parameter_out_2) → MAF del CA-LI

  - N_ca_CALI (parameter_out_3) → promediado coherente

  - sim_noise (parameter_out_4) → ruido en simulación

  - seleccion_resultado (parameter_out_5) → modo de salida

  - N_LI (parameter_out_6) → ciclos de LI puro

  - frec_lockin + M → configurado vía set_lockin_frec()