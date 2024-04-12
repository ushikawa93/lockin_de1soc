
module reference_mixer(

	// Entradas de control
	input clock,
	input reset_n,
	input enable,
	
	// Parametros de configuracion
	input [15:0] ptos_x_ciclo,
	
	// Entrada avalon streaming
	input signed [31:0] data,	
	input data_valid,	
		
	// Salidas avalon streaming 
	output signed [63:0] data_out_seno,
	output signed [63:0] data_out_coseno,
	output data_valid_multiplicacion	

);

referencias ref(

	// Entradas de control
	.clock(clock),
	.reset_n(reset_n),
	.enable(enable),
	
	// Parametro configurable
	.pts_x_ciclo(ptos_x_ciclo),

	// Entrada de sincronizacion
	.avanzar_en_tabla(data_valid),
	
	.data_out_seno(data_seno),
	.data_out_cos(data_cos)
	
);

wire signed [31:0] data_seno;
wire signed [31:0] data_cos;

wire data_valid_seno,data_valid_cos;

// Esto es un parche medio raro... atraso un ciclo la señal entrante para que quede
// todo bien sincronizado con la referencia
reg signed [31:0] data_reg; always @ (posedge clock) data_reg <= (!reset_n)? 0: data;


multiplicador prod_fase(

	// Entradas de control
	.clock(clock),
	.reset_n(reset_n),
	.enable(enable),
	
	// Entrada avalon streaming
	.data_a(data_reg),
	.data_b(data_seno),
	.data_valid(data_valid),	
		
	// Salidas avalon streaming 
	.data_out(data_out_seno),
	.data_valid_multiplicacion(data_valid_seno)	

);


multiplicador prod_cuadratura(

	// Entradas de control
	.clock(clock),
	.reset_n(reset_n),
	.enable(enable),
	
	// Entrada avalon streaming
	.data_a(data_reg),
	.data_b(data_cos),
	.data_valid(data_valid),	
		
	// Salidas avalon streaming 
	.data_out(data_out_coseno),
	.data_valid_multiplicacion(data_valid_cos)	


);


assign data_valid_multiplicacion = (data_valid_seno && data_valid_cos);

endmodule

