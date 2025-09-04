/* ==========================================================================
 * =========================== REMOVE_MEAN_VALUE ===========================
 *  Descripción general:
 *    Módulo que elimina el valor medio de una señal de entrada utilizando
 *    un promedio móvil de M muestras. La implementación utiliza una RAM
 *    de propósito general para almacenar los datos anteriores y un
 *    acumulador para calcular el promedio eficiente.
 *
 *  Entradas:
 *    - clock: reloj del sistema.
 *    - reset: reset síncrono.
 *    - data_in: señal de entrada.
 *    - CE: clock enable; habilita la actualización del buffer.
 *
 *  Salidas:
 *    - data_out: señal de salida con valor medio eliminado.
 *    - data_valid: indica que la salida es válida.
 *
 *  Parámetros:
 *    - M: cantidad de muestras usadas para el promedio móvil.
 *
 *  Funcionamiento:
 *    1. `init`: Inicializa acumulador, índice y registros.
 *    2. `esperar`: Espera que CE esté activo; lee dato anterior del buffer
 *       y actualiza `data_reg` y acumulador (resta dato antiguo).
 *    3. `act_tabla`: Deshabilita escritura en RAM; mantiene valor en buffer.
 *    4. `act_salida`: Actualiza acumulador sumando el dato leído del buffer,
 *       incrementa índice (circular) y habilita salida con `data_valid`.
 *    5. La salida se calcula restando el promedio (acumulador >> 5)
 *       del dato actual (`data_reg`), centrando la señal en cero.
 *
 *  Observaciones:
 *    - El shift `>> 5` corresponde a M=32; ajustar si se cambia M.
 *    - Usa una RAM de 32 palabras para almacenar datos anteriores.
 * ========================================================================== */

module remove_mean_value(
input clock,
input reset,
input [15:0] data_in,
input CE,

output signed [31:0] data_out,
output reg data_valid
);

wire [31:0] read_data;
reg signed [31:0] data_reg;
reg write_ram_en;
reg [5:0] index; initial index=0;

single_port_ram data_mem(
	.data(data_in),
	.addr(index),
	.we(write_ram_en),
	.clk(clock),
	.q(read_data)
);

parameter M=31; 

reg [31:0] acumulador; initial acumulador=0;

reg [1:0] state; parameter init=0,esperar=1, act_tabla=2, act_salida=3; initial state = init;

assign data_out = data_reg - (acumulador >> 5);


always @ (posedge clock)
begin

	if(reset)
		state <= init;

	case(state)
	init:
	begin
		acumulador <= 0;
		index <= 0;
		data_reg <= 0;
		state <= esperar;
	end
	
	esperar:
	begin
		data_valid <= 0;
		if(CE)
		begin 
			write_ram_en <= 1;
			acumulador <= acumulador - read_data;
			data_reg <= data_in;
			state <= act_tabla;	
		end 
	end
		
	act_tabla:
	begin
		write_ram_en <= 0;
		state <= act_salida;			
	end
	
	act_salida:
	begin
		data_valid <= 1;
		acumulador <= acumulador + read_data;		
		index <= (index== M)? 0: index+1;
		state <= esperar;
	end
	
	endcase
	
	
end

endmodule
