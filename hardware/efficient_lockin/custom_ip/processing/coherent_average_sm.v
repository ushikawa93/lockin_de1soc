
module coherent_average_sm

	#( parameter M = 32,
		parameter Q_in = 14,
		parameter Q_out = 32,
		parameter N = 3,
		parameter simulacion = 1)

	(	input clk_rapido,
		input clk_lento,
		input reset_n,
		input enable,
	
		input [Q_in-1:0] x,
		input x_valid,
	
		output [31:0] data_out,
		output data_out_valid
			
);


parameter idle = 0;
parameter calculando = 1;
parameter transmitiendo = 2;
parameter limpiando = 3;
parameter finished = 4;
parameter extra_1 = 5;
parameter extra_2 = 6;
parameter extra_3 = 7;


reg [6:0] n,n_1,n_2,h;
reg [15:0] k;

reg [Q_in-1:0] x_1;

reg [Q_out-1:0] y [M-1:0];
reg [Q_out-1:0] y_actual;
reg [Q_out-1:0] sum_actual;

reg data_out_valid_reg;
reg [Q_out-1:0] data_out_reg;


///////////////// Maquina de estados //////////////////////////

reg [3:0] state;
reg cycled;

always @ (posedge clk_rapido or negedge reset_n)
begin
	if(!reset_n)
		cycled <= 0;
	else
		cycled <= (n == M-1)||(h == M-1);
end



always @ (posedge clk_rapido or negedge reset_n)
begin

	if(!reset_n)
		state <= idle;
		
	else
		case(state)
			
			idle:
				state <= ((enable)? calculando: idle);
				
			calculando:
				state <= ((k == N)? transmitiendo: calculando); 
			
			transmitiendo:
				state <= (cycled)? limpiando:transmitiendo;
			
			limpiando:
				state <= (cycled)? finished: limpiando;
				
			finished:
				state <= finished;
			
			extra_1:
				state <= idle;
				
			extra_2:
				state <= idle;
				
			extra_3:
				state <= idle;

		endcase

end

//////////////////////////////////////////////////////////////


always @ (posedge clk_rapido or negedge reset_n)
begin

	if(!reset_n)
	begin
		n <= 0;
		n_1 <= 0;
		n_2 <= 0;
		k <= 0;
		y_actual <= 0;
		sum_actual <= 0;
		x_1 <= 0;
		
	end
	
	else
	begin

		case (state)
		
			idle:
			begin
			
			end
				
			calculando:
			begin
			
				if(x_valid)
				begin
							
					// Fetch
					y_actual <= y[n];
					x_1 <= x;
					n <= (n == M-1)? 0:n+1;
							
					// Sum
					sum_actual <= y_actual + x_1;
					n_1 <= n;
						
					// Save
					y[n_2] <= sum_actual;				
					n_2 <= n_1;		
						
					k <= (n_1 == M-1)? k+1:k;	
				
				end
					
			end
				
			transmitiendo:
			begin
				
				n <= 0; // Aprovecho para reiniciar este registro con el que voy a limpiar la RAM
				
				// Para transmitir uso el clock lento
			end
				
			limpiando:
			begin
				
				y[n] <= 0;
				n <= n+1;				
			end
			
			finished:
			begin
				// Termine de calcular, solo un reset me saca de aca
			end
			
			default:
			begin
				// Nadaa
			end
			
		endcase
	end
end


always @ (posedge clk_lento or negedge reset_n)
begin

	if(!reset_n)
	begin
		h <= 0;
		data_out_valid_reg <= 0;
		data_out_reg <= 0;
	end
	
	else 
	begin

		case (state)
			
			idle:
			begin

			end
						
			calculando:
			begin
				// Para esto uso el clock rapido
			end
				
			transmitiendo:
			begin					
				data_out_reg <= y[h];
				h <= h+1;
				data_out_valid_reg <= 1;					
			end
				
			limpiando:
			begin
					// Para esto uso el clock rapido
			end
						
			finished:
			begin
				// Termine de calcular, solo un reset me saca de aca
			end
			
			default:
			begin
				h <= 0;
			end
		endcase
	end
end

assign data_out_valid = data_out_valid_reg;
assign data_out = data_out_reg;

// Inicializacion de arreglo para la simulacion... (si no estoy simulando ni lo compilo)

generate 
	if(simulacion)
	begin
		integer j;
		initial
		begin
			
			for (j = 0 ; j < M; j=j+1)
				y[j] <= 0;

		end
	end
endgenerate

endmodule
