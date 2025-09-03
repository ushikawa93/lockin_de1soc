
module data_source_dac(

	input clock,
	input reset_n,
	input CE,
	
	input [15:0] ptos_x_ciclo,
	input seleccion_dac,
	
	output zero_cross,
	output reg data_valid,
	output [31:0] data
);


//=======================================================
// Reg/Wire declarations
//=======================================================

wire [15:0] M = ptos_x_ciclo;				// Puntos por ciclo de señal

reg [15:0] interval;
	always @ (posedge clock) interval = 2048/M; // Para poder cambiar el largo de la secuencia sin tener que leer otro archivo
														  						

parameter delay=0;		// El modulo saca una muestra cada delay+1 ciclos de señal

reg [15:0] buffer [0:2047];
	initial	$readmemh("LU_Tables/x2048_14b.mem",buffer);

reg [15:0] data_out_reg; initial data_out_reg = 0;
	
assign data = data_out_reg;

reg [15:0] index; initial index = 0;

reg [15:0] counter; initial counter = 0;

reg en_reg; always @ (posedge clock) 	en_reg <= CE;

parameter nivel_dc = 8192;


//=======================================================
// Algoritmo principal
//=======================================================

//Manda un dato cada delay+1 ciclos de reloj
always @ (posedge clock or negedge reset_n)
begin

	
	if(!reset_n) 
	begin 
		index <= 0; 
		counter <= 0; 
		data_valid <= 0;
		data_out_reg<=0; 
	end
	else	
	begin
		if(en_reg) 
		begin				
			counter <= counter+1;
		
			if(counter==delay)
			begin
				index <= (index == (M-1))? 0: index+1 ;	
				data_out_reg <= (seleccion_dac)? nivel_dc : (buffer[index*interval]);
				data_valid <= 1;
				counter <= 0;
			end			
		end
	end
end

//=======================================================
// Señalizacion de paso por cero del seno
//=======================================================

assign zero_cross = (index == 0) && (CE) && (data_valid);

endmodule