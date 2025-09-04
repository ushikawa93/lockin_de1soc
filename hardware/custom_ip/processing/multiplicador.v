/* ==========================================================================
 * ============================= MULTIPLICADOR ==============================
 *  Descripción general:
 *    Este módulo realiza la multiplicación de dos señales de entrada
 *    en streaming (Avalon streaming) y entrega la salida registrada
 *    junto con la señal de validación.
 *
 *  Entradas:
 *    - clock: reloj del sistema.
 *    - reset_n: reset activo en bajo.
 *    - enable: habilita la operación de multiplicación.
 *    - data_a: primer operando (signed 32 bits).
 *    - data_b: segundo operando (signed 32 bits).
 *    - data_valid: indica que las entradas `data_a` y `data_b` son válidas.
 *
 *  Salidas:
 *    - data_out: resultado de la multiplicación (signed 64 bits).
 *    - data_valid_multiplicacion: indica que `data_out` es válido.
 *
 *  Funcionamiento:
 *    1. Las entradas se registran para sincronizar y estabilizar los datos.
 *    2. La multiplicación se realiza en dos etapas:
 *       - Primera etapa: producto registrado.
 *       - Segunda etapa: producto enviado a la salida y validado.
 *    3. La señal `data_valid_multiplicacion` indica cuándo la salida es confiable.
 *
 *  Observaciones:
 *    - La señal `enable` permite detener la operación sin alterar el registro.
 *    - El módulo está preparado para trabajar en un pipeline de 2 etapas.
 * ========================================================================== */

module multiplicador(

	// Entradas de control
	input clock,
	input reset_n,
	input enable,
	
	// Entrada avalon streaming
	input signed [31:0] data_a,
	input signed [31:0] data_b,
	input data_valid,	
		
	// Salidas avalon streaming 
	output reg signed [63:0] data_out,
	output data_valid_multiplicacion	

);


// Registro las entradas... es mas prolijo trabajar con las entradas registradas
reg signed [31:0] data_a_reg; always @ (posedge clock) data_a_reg <= (!reset_n)? 0: data_a;
reg signed [31:0] data_b_reg; always @ (posedge clock) data_b_reg <= (!reset_n)? 0: data_b;
reg data_valid_reg; always @ (posedge clock) data_valid_reg <= (!reset_n)? 0: data_valid;


reg signed [63:0] producto;
reg data_valid_1,data_valid_2,data_out_valid;

//=======================================================
// Algoritmo principal
//=======================================================

always @ (posedge clock or negedge reset_n)
begin
	
	if(!reset_n)
	begin		

		data_out_valid <= 0;
		
	end
	else if(enable)
	begin
		if(data_valid_reg)
		begin				
			data_out <= data_a_reg * data_b_reg;
			data_out_valid <= 1;
			
		end
		else
			data_out_valid <= 0;
		
	end
end

assign data_valid_multiplicacion = data_out_valid;




endmodule
