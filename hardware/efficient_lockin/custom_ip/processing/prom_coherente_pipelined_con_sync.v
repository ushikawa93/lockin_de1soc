

module prom_coherente_pipelined_con_sync(
	
	// Entradas de control
	input clk,
	input reset_n,
	input enable,
	
	// Parametros de configuracion
	input [15:0] ptos_x_ciclo,
	input [15:0] frames_prom_coherente,
	
	input sync,
	
	// Entrada avalon streaming
	input data_in_valid,
	input signed [31:0] data_in,
	
	// Salida avalon streaming 
	output data_out_valid,
	output signed [31:0] data_out,

	output sync_out
	
);


//=======================================================
// Reg/Wire declarations
//=======================================================


parameter buf_tam = 32768;

wire [15:0] M; assign M=ptos_x_ciclo; 				// Cantidad de puntos por ciclo de señal
wire [15:0] N; assign N=frames_prom_coherente;	// Frames promediados coherentemente... 
							
							
reg [15:0] index,frames_promediados; 
reg [15:0] index_retrasado,index_clean; 
reg start,sync_out_reg;

reg signed [31:0] buffer [0:buf_tam-1];
reg signed [31:0] data_reg,data_anterior,data_out_reg;

reg data_out_valid_reg;


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
	
		data_out_valid_reg <= 0;
		index<=0;index_retrasado<=0;index_clean<=0;
		frames_promediados<=0;			
		data_reg<=0;data_out_reg<=0;
		data_anterior<=0;		
		start <= 0;
		sync_out_reg <= 0;
	end		
	
	else if(enable)
	begin
	
		if ( (data_valid_reg) )
		begin
		
			if (sync)
			begin
				start <= 1;
				index <= 0;
				frames_promediados <= (start)? ( (frames_promediados < N)? frames_promediados+1 : 1) : 0 ;
				sync_out_reg <= ((frames_promediados == N-1)? 1 : 0);
			end else
			begin
				index <= index+1;
				sync_out_reg <= 0;
			end
			
			if(start)
			begin
				// Indice para la otra etapa del pipeline
				index_retrasado <= index;		
			
				// 1 etapa datos anteriores
				// Si ya termine de promediar lo que quiero me olvido del dato anterior!
				data_reg <= data_in_reg;
				data_anterior <= ((frames_promediados == N) || (frames_promediados == 0) )? 0 : buffer [index];	
			
				// 2 etapa dato nuevos
				buffer[index_retrasado] <= data_anterior + data_reg;
				
				
				// Este flag señala cuantos ciclos voy promediando
				//frames_promediados <= 	(frames_promediados < N)? 
				//								( ( index == (M-1)) ? frames_promediados+1 : frames_promediados ) :
				//								( ( index == (M-1)) ? 1 : N );
													

				// Si termine de promediar lo que quiero habilito la salida por un rato...
				if ((frames_promediados == N) )	//habilitar salida	
				begin			
					data_out_valid_reg <= 1;
					data_out_reg <= buffer[index];
				end
				else
					data_out_valid_reg <= 0;	
			end		
		end
		
		else 
		begin
			data_out_valid_reg <= 0;			
		end
	end
	else
	begin
		data_out_valid_reg <= 0;			
		buffer[index_clean]<=0;
		index_clean <= index_clean+1;	
	end
	
end


// Cuando N=1 la cosa no tiene que hacer nada, solo debe retrasar la señal dos ciclos de reloj para simular el pipeline
// Queda medio feo hacerlo asi pero es lo mas rapido para salir del paso...

reg signed [31:0]  data_out_reg_n_1,data_aux;
reg data_out_valid_n_1,data_valid_aux;
reg sync_aux,sync_out_n_1;

always @ (posedge clk)
begin

	//data_aux <= data_in_reg;
	data_out_reg_n_1 <= data_in_reg;
	
	//data_valid_aux <= data_in_valid;
	data_out_valid_n_1 <= data_in_valid;
	
	//sync_aux <= sync;
	sync_out_n_1 <= sync;

end


assign sync_out = (N==1)? sync_out_n_1 : sync_out_reg;
assign data_out = (N==1)? data_out_reg_n_1 : data_out_reg; 
assign data_out_valid = (N==1)? data_out_valid_n_1 : data_out_valid_reg;

endmodule

