
module multiple_IIR(

	// Entradas de control
	input clock,
	input reset,
	input enable,	
	
	// Parametros configurables 
	// (Para IIR no tienen funcionalidad pero los dejo para que tenga la misma interfaz que el filtro de media movil)
	input [15:0] ptos_x_ciclo,
	input [15:0] frames_integracion,
		
	// Interfaz avalon streaming de entrada
	input data_valid,
	input signed [63:0] data,	
	
	// Interfaz avalon streaming de salida
	output signed [63:0] data_out,
	output data_out_valid,

	// Señales auxiliares
	output reg ready,
	output reg fifo_lleno

);

// Salida IIR1 entrada IIR2
wire [63:0] data_aux_1;
wire 			data_aux_1_valid;

// Salida IIR2 entrada IIR3
wire [63:0] data_aux_2;
wire 			data_aux_2_valid;

// Salida IIR2 entrada IIR4
wire [63:0] data_aux_3;
wire 			data_aux_3_valid;

// Salida IIR2 entrada IIR5
wire [63:0] data_aux_4;
wire 			data_aux_4_valid;


IIR_filter filtro_pasabajos1(

	// Entradas de control
	.clock(clock),
	.reset(reset),
	.enable(enable),
		
	// Interfaz avalon streaming de entrada
	.data_valid(data_valid),
	.data(data),	
	
	// Interfaz avalon streaming de salida
	.data_out(data_aux_1),
	.data_out_valid(data_aux_1_valid)

);


IIR_filter filtro_pasabajos2(

	// Entradas de control
	.clock(clock),
	.reset(reset),
	.enable(enable),
		
	// Interfaz avalon streaming de entrada
	.data_valid(data_aux_1_valid),
	.data(data_aux_1),	
	
	// Interfaz avalon streaming de salida
	.data_out(data_aux_2),
	.data_out_valid(data_aux_2_valid)

);

IIR_filter filtro_pasabajos3(

	// Entradas de control
	.clock(clock),
	.reset(reset),
	.enable(enable),
		
	// Interfaz avalon streaming de entrada
	.data_valid(data_aux_2_valid),
	.data(data_aux_2),	
	
	// Interfaz avalon streaming de salida
	.data_out(data_aux_3),
	.data_out_valid(data_aux_3_valid)

);

IIR_filter filtro_pasabajos4(

	// Entradas de control
	.clock(clock),
	.reset(reset),
	.enable(enable),
		
	// Interfaz avalon streaming de entrada
	.data_valid(data_aux_3_valid),
	.data(data_aux_3),	
	
	// Interfaz avalon streaming de salida
	.data_out(data_aux_4),
	.data_out_valid(data_aux_4_valid)

);

IIR_filter filtro_pasabajos5(

	// Entradas de control
	.clock(clock),
	.reset(reset),
	.enable(enable),
		
	// Interfaz avalon streaming de entrada
	.data_valid(data_aux_4_valid),
	.data(data_aux_4),	
	
	// Interfaz avalon streaming de salida
	.data_out(data_out),
	.data_out_valid(data_out_valid),
	
	// Salidas auxiliares (solo las conecto en el ultimo para avisarle al procesador...)
	.ready(ready_wire),
	.fifo_lleno(fifo_lleno_wire)

);

// Salidas auxiliares
wire ready_wire;
wire fifo_lleno_wire;

always @ (posedge clock)
begin
	ready <= ready_wire;
	fifo_lleno <= fifo_lleno_wire;
end

endmodule
