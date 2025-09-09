# Servidor Web Lock-In en DE1-SoC

Este proyecto permite controlar y visualizar un sistema **Lock-In** implementado en la FPGA (DE1-SoC) mediante una interfaz web simple.  
El servidor corre en el procesador ARM (uP) de la placa y se comunica con binarios en C++ para interactuar con la lógica de la FPGA.

---

## Estructura del proyecto

- **web_server/**  
  Contiene los archivos necesarios para levantar un servidor HTTP en el uP.  
  Incluye:
  - Servidor Node.js (`server.js`) que atiende las solicitudes HTTP.
  - Archivos HTML/JS para la interfaz gráfica en navegador.
  - Ejemplos de prueba (como toggle de LED).

- **software_host/**  
  Contiene los programas en C++ que ejecutan acciones sobre la FPGA (ej: `toggle_led`).  
  Estos deben compilarse en el uP y colocarse en un directorio accesible por el servidor web.

---

## Requisitos previos

1. **FPGA configurada** con el bitstream `lockin_estable.rbf`.  
   Esto asegura que la lógica del Lock-In esté cargada.

2. **Node.js** instalado en el uP de la DE1-SoC.  
   Verificar con:
   ```bash
   node -v
   ```

3. Compilación de binarios en C++ (`ej. toggle_led`) desde software_host.

## Instalación y uso

1. Copiar todo el contenido de la carpeta web_server/ al directorio raíz del servicio HTTP en el uP.
Ejemplo:

 ```bash
cp -r web_server/* /home/root/web_server/
 ```
2. Compilar los programas de software_host en la DE1-SoC y colocarlos en la ruta esperada por el servidor (ej: /root/Documents/de1soc_sw/cpp/toggle_led/). Para ello hay un shell script "make_all.sh"

3. Iniciar el servidor Node.js en la DE1-SoC:

 ```bash
 node server.js
 ```

4. El servidor quedará escuchando en:

 ```bash
 http://<IP_DE1SOC>:8080/
 ```

4. Abrir en un navegador desde una PC conectada a la misma red:

 - index.html (interfaz principal Lock-In).

 - led_test.html (ejemplo de prueba para controlar un LED).

--- 

## Ejemplo de uso: LED Test

 - HTML: led_test.html muestra un botón que alterna el estado del LED.

 - Al presionarlo, envía una petición GET al servidor (/toggle) con el parámetro led_state.

 - El servidor ejecuta el binario toggle_led en la FPGA.

 - Se muestra en la página la cantidad de veces que el botón fue presionado.

## Notas

 - Este entorno está pensado para pruebas rápidas y visualización del Lock-In sin necesidad de interactuar directamente con la lógica HDL.

 - Se recomienda ejecutar el servidor con permisos adecuados y mantener las rutas consistentes entre server.js y los binarios en C++.

