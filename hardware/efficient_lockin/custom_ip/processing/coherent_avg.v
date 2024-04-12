/*
	Este modulo promedia frames_prom_coherente ciclos de la señal y despues transmite el ciclo de señal resultante al siguiente modulo	
*/

module coherent_avg(
	
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
	output data_out_valid,
	output signed [31:0] data_out	
	
);


//=======================================================
// Reg/Wire declarations
//=======================================================


parameter buf_tam = 2048;

wire [15:0] M; assign M=ptos_x_ciclo; 				// Cantidad de puntos por ciclo de señal
wire [15:0] N; assign N=frames_prom_coherente;	// Frames promediados coherentemente... 
							
							
reg [15:0] index,frames_promediados,index_retrasado; 

reg signed [31:0] buffer [0:buf_tam-1];
reg signed [31:0] data_reg,data_anterior,data_out_reg;
reg data_out_reg_valid;

// Registro las entradas... es mas prolijo trabajar con las entradas registradas

reg signed [31:0] data_in_reg; always @ (posedge clk) data_in_reg <= (!reset_n)? 0: data_in;
reg data_valid_reg; always @ (posedge clk) data_valid_reg <= (!reset_n)? 0: data_in_valid;

reg [3:0] state; parameter idle=0,average=1, reset_index=2, transmit=3, clean=4, finish=5;

//===========	============================================
// Algoritmo principal
//=======================================================


always@ (posedge clk)
begin
	if(!reset_n)	//init
	begin 
		state <= idle;
		data_reg <= 0;
		data_anterior <= 0;
		index <= 0;
		index_retrasado <= 0;
		data_out_reg_valid <= 0;
	end		
		
	else 
	begin
		
		case(state)
		
			idle: 
			begin
				state <= (enable)? average : idle;

			end
			
			average:
			begin
				if(data_valid_reg)
				begin				
		
					// 1 etapa datos anteriores
					// Si ya termine de promediar lo que quiero me olvido del dato anterior!
					index <= (index==(M-1))? 0 : index+1;

					data_reg <= data_in_reg;
					data_anterior <= ((frames_promediados == N) || (frames_promediados == 0) )? 0 : buffer [index];	
		
					// 2 etapa dato nuevos
					index_retrasado <= index;		
					buffer[index_retrasado] <= data_anterior + data_reg;
					
					// Logica de cambio de estado
					frames_promediados <= (index == M-1) ? frames_promediados + 1 : frames_promediados;
					state <= (frames_promediados == N) ? transmit : average;
				end
												
			end
			
			reset_index:
			begin
					
				index <= 0;
				index_retrasado <= 0;
					
			end
			
			transmit:
			begin
				data_out_reg <= buffer [index];
				data_out_reg_valid <= 1;

				index <= (index==(M-1))? 0 : index+1;
				state <= (index==(M-1))? clean : transmit;
			end

			clean:
			begin
				buffer [index] <= 0;;
				data_out_reg_valid <= 1;

				index <= (index==(M-1))? 0 : index+1;
				state <= (index==(M-1))? finish : clean;
			end
			
			finish:
			begin
				// Solo un reset me saca de aca				
			end

		endcase
	end
end

assign data_out = data_out_reg; 
assign data_out_valid = data_out_reg_valid;

endmodule


