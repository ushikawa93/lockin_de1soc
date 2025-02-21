
module IIR_filter(

	// Entradas de control
	input clock,
	input reset_n,
	input enable,
		
	// Interfaz avalon streaming de entrada
	input data_valid,
	input signed [63:0] data,	
	
	// Interfaz avalon streaming de salida
	output signed [63:0] data_out,
	output data_out_valid,
	
	// Parametros configurables 
	// (Para IIR no tienen funcionalidad pero los dejo para que tenga la misma interfaz que el filtro de media movil)
	input [15:0] ptos_x_ciclo,
	input [15:0] frames_integracion,

	// Señales auxiliares
	output ready,
	output fifo_lleno

);

// Parametros de un filtro IIR para wn = 0.01, cuantizados a 8 bits
parameter A1 = 256; 
	parameter log2A1 = 8;
parameter A2 = -248;
parameter B1 = 4;
parameter B2 = 4;

// Parametros para controlar que datos mando a los FIFO
parameter FIFO_DEPTH = 2048;
parameter START_SENDING = 0;

// Estados de la ecuacion en diferencias
wire signed [63:0] x_n; 
	assign x_n = data;
reg signed [63:0] x_n_1;
reg signed [63:0] y_n; 

// Contador auxiliar para saber cuando se termina la operacion
reg [15:0] counter;

always @ (posedge clock or negedge reset_n)
begin

	if(!reset_n)
	begin	
		x_n_1 <= 0;
		y_n <= 0;		
		counter <= 0;

	end
	else if (enable)
	begin		
		if(data_valid)
		begin
			x_n_1 <= x_n;		
			y_n <= (  B1 * x_n + B2 * x_n_1 - A2 * y_n ) >>> log2A1;		
			counter <= (counter == FIFO_DEPTH + START_SENDING )? counter: counter+1;
		end
	end
end

// Salidas:
assign data_out = y_n;
assign data_out_valid = (data_valid && (counter > START_SENDING) );

// Salidas auxiliares
assign ready = reset_n; // El unico momento en que no puede calcular es cuando reset_n = 0
assign fifo_lleno = (counter == FIFO_DEPTH + START_SENDING);

endmodule
