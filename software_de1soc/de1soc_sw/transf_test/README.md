 *  Proyecto:   Corrección de mediciones Lock-in con archivo de transferencia
 *  Archivo:    Program.cs
 *
 *  Descripción:
 *  --------------------------------------------------------------------
 *  Este programa lee el archivo "transferencia.dat" generado por el lock-in
 *  (contiene frecuencia, X, Y, amplitud R y fase Φ para cada punto de calibración)
 *  y lo utiliza para corregir nuevas mediciones.
 *
 *  Flujo principal:
 *    1. Leer y parsear "transferencia.dat".
 *    2. Almacenar frecuencias, amplitudes y fases en listas.
 *    3. Buscar la frecuencia más cercana a la de la nueva medición.
 *    4. Calcular valores corregidos:
 *         - Amplitud corregida: R_corr = R_medido * R_guardada(0) / R_guardada(i)
 *         - Fase corregida:     φ_corr = φ_medido - φ_guardada(i)
 *    5. Mostrar resultados corregidos en consola.
 *
 *  Clases auxiliares:
 *    - Medicion: encapsula frecuencia, X, Y, R y Φ de cada línea del archivo.
 *
 *  Autor:    [Tu nombre / equipo]
 *  Fecha:    [dd/mm/aaaa]

