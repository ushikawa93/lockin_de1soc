================================================================================
 Programa: Selector de Bitstream para FPGA
================================================================================
 Descripción:
 -------------
 Este programa lista todos los archivos con extensión ".rbf" en la carpeta
 "bitstreams", muestra cuál está actualmente cargado en la FPGA y permite al
 usuario seleccionar un nuevo archivo para cargar. 

 Funcionalidades principales:
 - Abrir la carpeta "bitstreams" y leer archivos ".rbf".
 - Mostrar el bitstream actualmente cargado.
 - Permitir seleccionar un bitstream de la lista.
 - Ejecutar un script externo para configurar la FPGA con el bitstream
   seleccionado.
 - Guardar el bitstream actualmente seleccionado en "bitstream_actual.txt".
