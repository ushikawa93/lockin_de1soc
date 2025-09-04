/* ==========================================================================
 * ====================== REMOVE_MEAN_VALUE_PIPELINED ======================
 *  Descripción general:
 *    Este módulo elimina el valor medio (DC offset) de una señal de entrada
 *    utilizando un promedio móvil de M puntos, implementado de manera pipelined.
 *    La salida es la señal centrada en cero.
 *
 *  Entradas:
 *    - clock: reloj del sistema.
 *    - reset_n: reset activo en bajo.
 *    - data_in: señal de entrada a procesar.
 *    - data_in_valid: flag de dato válido en entrada.
 *
 *  Salidas:
 *    - data_out: señal de salida con el valor medio eliminado.
 *    - data_out_valid: flag indicando que la salida es válida.
 *
 *  Parámetros:
 *    - M: cantidad de muestras usadas para el cálculo del promedio móvil.
 *
 *  Funcionamiento:
 *    1. Se registran las entradas para sincronizar el pipeline (etapas 1-2).
 *    2. Se guarda cada dato en un buffer circular de M posiciones.
 *    3. Se mantiene un acumulador que suma el dato entrante y resta el dato
 *       que se va a sobrescribir (etapa 3), obteniendo un promedio móvil eficiente.
 *    4. La salida se calcula restando el promedio (acumulador/M) del dato actual
 *       (etapa 4), entregando la señal centrada en cero.
 *    5. Se utilizan registros auxiliares `data_valid_aux*` para propagar la validez
 *       de la señal a través del pipeline.
 *
 *  Observaciones:
 *    - La operación de promedio se realiza con desplazamiento de bits `>> 5`
 *      lo cual corresponde a M=32. Ajustar el shift si se cambia M.
 *    - El clear inicial borra el buffer antes de comenzar el procesamiento.
 * ========================================================================== */

module remove_mean_value_pipelined(
	input clock,
	input reset_n,

	input signed [31:0] data_in,
	input data_in_valid,

	output reg signed [31:0] data_out,
	output reg data_out_valid
);

parameter M=32; 

reg signed [31:0] data_etapa2,data_in_etapa3,data_out_etapa3,data_aux;

reg [15:0] index,i; initial index=0;
reg [15:0] index_retrasado;

reg signed [31:0] data_mem [0:M-1];

reg clear;

reg signed [31:0] acumulador; initial acumulador=0;


//Estos son para atrasar el data_out_valid... Hacerlo asi es mas rapido!
reg data_valid_aux1,data_valid_aux2,data_valid_aux3,data_valid_aux4; 
initial data_valid_aux1=0;

always @ (posedge clock or negedge reset_n)
begin
	
	
	if(!reset_n)
	begin
		acumulador <= 0;
		index <= 0;index_retrasado<=0;
		i <= 0;
		
		data_out_valid <= 0;
		
		data_valid_aux1 <= 0;
		data_valid_aux2 <= 0;
		data_valid_aux3 <= 0;
		data_valid_aux4 <= 0;
		
		data_aux <= 0;
		data_etapa2 <= 0;
		data_in_etapa3<=0;
		data_out_etapa3<=0;
		
		clear <= 1;		
		
	end

	else if(data_in_valid && reset_n)
	begin
	
		index <= (index== (M-1))? 0: index+1;
		index_retrasado <= index;
		data_valid_aux1 <= ((index == (M-1))? 1:0 ) || data_valid_aux1;	
		
		// Registrar dato entrante (1 etapa)
		data_etapa2 <= data_in;
		data_valid_aux2 <= data_valid_aux1;
		
		// Guardar dato en arreglo (2 etapa)
		data_mem[index_retrasado] <= data_etapa2;		
		
		data_in_etapa3 <= data_etapa2;
		data_out_etapa3 <= data_mem[index_retrasado];
		
		data_valid_aux3 <= data_valid_aux2;
				
		// Actualizar acumulador (3 etapa)	
		acumulador <= acumulador + data_in_etapa3 - data_out_etapa3;
		data_aux <= data_in_etapa3;
		
		data_valid_aux4 <= data_valid_aux3;
		
		// Actualizar salida (4 etapa)
		data_out <= data_aux - (acumulador >> 5);
		
		data_out_valid <= data_valid_aux4;
				
	end 	
	
	else if(clear)	// Clear arrays		
	begin
		i<=i+1;
		data_mem[i] <= 0;
		clear<=(i==M)? 0:1;
	end
	
	else	
		data_out_valid<=0;	
	
end

endmodule