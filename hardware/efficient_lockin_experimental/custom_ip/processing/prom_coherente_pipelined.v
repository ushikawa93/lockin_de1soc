

module prom_coherente_pipelined(
	
	// Entradas de control
	input clk,
	input reset_n,
	input enable,
	
	// Parametros de configuracion
	input [15:0] ptos_x_ciclo,
	input [15:0] frames_prom_coherente,
	
	// Entrada avalon streaming
	input data_in_valid,
	input signed [31:0] data_in,
	
	// Salida avalon streaming 
	output reg data_out_valid,
	output signed [31:0] data_out	
	
);


//=======================================================
// Reg/Wire declarations
//=======================================================


parameter buf_tam = 2048;

wire [15:0] M; assign M=ptos_x_ciclo; 				// Cantidad de puntos por ciclo de señal
wire [15:0] N; assign N=frames_prom_coherente;	// Frames promediados coherentemente... 
							
							
reg [15:0] index,frames_promediados; 
reg [15:0] index_retrasado,index_clean; 

reg signed [31:0] buffer [0:buf_tam-1];
reg signed [31:0] data_reg,data_anterior,data_out_reg;


// Registro las entradas... es mas prolijo trabajar con las entradas registradas

reg signed [31:0] data_in_reg; always @ (posedge clk) data_in_reg <= (!reset_n)? 0: data_in;
reg data_valid_reg; always @ (posedge clk) data_valid_reg <= (!reset_n)? 0: data_in_valid;

//=======================================================
// Algoritmo principal
//=======================================================


always@ (posedge clk)
begin
		
	if(!reset_n)	//init
	begin 
	
		data_out_valid <= 0;
		index<=0;index_retrasado<=0;index_clean<=0;
		frames_promediados<=0;			
		data_reg<=0;data_out_reg<=0;
		data_anterior<=0;		
	end		
	
	else if(enable)
	begin
	
		if ( (data_valid_reg) )
		begin
		
			// Llevo dos indices porque son dos etapas de pipeline
			index <= (index==(M-1))? 0 : index+1;
			index_retrasado <= index;		
		
			// 1 etapa datos anteriores
			// Si ya termine de promediar lo que quiero me olvido del dato anterior!
			data_reg <= data_in_reg;
			data_anterior <= ((frames_promediados == N) || (frames_promediados == 0) )? 0 : buffer [index];	
		
			// 2 etapa dato nuevos
			buffer[index_retrasado] <= data_anterior + data_reg;
			
			
			// Este flag señala cuantos ciclos voy promediando
			frames_promediados <= 	(frames_promediados < N)? 
											( ( index == (M-1)) ? frames_promediados+1 : frames_promediados ) :
											( ( index == (M-1)) ? 1 : N );
												

			// Si termine de promediar lo que quiero habilito la salida por un rato...
			if ((frames_promediados == N) )	//habilitar salida	
			begin			
				data_out_valid <= 1;
				data_out_reg <= buffer[index];
			end
			else
				data_out_valid <= 0;			
		end
		
		else 
		begin
			data_out_valid <= 0;			
		end
	end
	else
	begin
		data_out_valid <= 0;			
		buffer[index_clean]<=0;
		index_clean <= index_clean+1;	
	end
	
end

assign data_out = data_out_reg; 

endmodule


