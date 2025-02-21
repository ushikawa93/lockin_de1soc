
module filtro_promedio_movil(

	// Entradas de control
	input clock,
	input reset_n,
	input enable,
	
	// Parametros de configuracion
	input [15:0] ptos_x_ciclo,
	input [15:0] frames_integracion,
	
	// Entrada avalon streaming 
	input data_valid,
	input signed [63:0] data,	
		
	// Salida avalon streaming
	output reg signed [63:0] data_out,
	output reg data_out_valid,

	// Salidas auxiliares
	output ready_to_calculate,
	output calculo_finalizado

);

//=======================================================
// Parametros de configuracion 
//=======================================================

parameter buf_tam = 4096;					// Con 8192 ya me paso de la cantidad de bloques de ram que hay
parameter delay=3;
parameter fifo_depth = 2048;



wire [15:0] M;	assign M = ptos_x_ciclo;				// Puntos por ciclo de señal
wire [7:0] N; 	assign N = frames_integracion;		// Frames de integracion // Largo del lockin M*N	


//=======================================================
// Reg/Wire declarations
//=======================================================

reg signed [63:0] data_in_2_etapa;
reg signed [63:0] data_out_2_etapa;

reg signed [63:0] acumulador;	// Son un poco mas largos para que no haya overflow

reg signed [63:0] array_datos [0:buf_tam-1];

reg data_valid_1,data_valid_2, limpiando_arrays;

reg [15:0] i,index_promediacion, ciclos_completados;

reg [15:0] muestras_promediadas,index_aux;
wire finish;
reg fifo_lleno;

reg [15:0] ciclos_para_llenar_fifo;
	always @ (posedge clock) ciclos_para_llenar_fifo <= 2048 / (MxN);
	
reg [15:0] MxN;
	always @ (posedge clock) MxN <= M*N;


// Registro las entradas... es mas prolijo trabajar con las entradas registradas
reg signed [63:0] data_in_reg; always @ (posedge clock) data_in_reg <= (!reset_n)? 0: data;
reg data_valid_reg; always @ (posedge clock) data_valid_reg <= (!reset_n)? 0: data_valid;

//=======================================================
// Algoritmo principal
//=======================================================

always @ (posedge clock or negedge reset_n)
begin

	if(!reset_n)
	begin
	
		acumulador<=0;
		ciclos_completados<=0;
		muestras_promediadas<=0;
		index_aux<=0;
		
		data_in_2_etapa<=0;		
		data_out_2_etapa<=0;
		index_promediacion <= 0;
		
		fifo_lleno<=0;	
		i <= 0;
		data_valid_1<=0;
		data_valid_2<=0;
		limpiando_arrays<=1;
		
	end	
	
	else if (enable)
	begin
		
		if(data_valid_reg && !fifo_lleno && !finish)
		begin
		
			index_promediacion <=  (index_promediacion == ((MxN)-1))? 0 : index_promediacion + 1;
			ciclos_completados <= (index_promediacion == ((MxN)-1))? ciclos_completados+1: ciclos_completados;
			fifo_lleno <= (ciclos_completados == ciclos_para_llenar_fifo)? 1:0;

			//guardar dato en arreglo (1 etapa)
							
			array_datos[index_promediacion] <= data_in_reg;		
			data_in_2_etapa <= data_in_reg;			
			data_out_2_etapa <= array_datos[index_promediacion];		
			data_valid_1 <= 1;
				
			// Actualizar acumulador (2 etapa)		
			index_aux <= index_promediacion;
			acumulador <= acumulador + data_in_2_etapa - data_out_2_etapa;		
			data_valid_2 <= data_valid_1;
			
					
			// Actualizar salida (3 etapa)	
			muestras_promediadas <= index_aux;
			data_out <= acumulador;			
			
		end
	end	
	
	else
	begin		
      if(i<buf_tam-1)
		begin		
			array_datos[i]<=0;
			i<=i+1;			
		end
		else
			limpiando_arrays <= 0;	
	end
	
end

always @ (posedge clock) 
	data_out_valid <= (data_valid_2 && data_valid_reg);

	
assign ready_to_calculate = !limpiando_arrays;
assign finish = (muestras_promediadas == (MxN+1));

assign calculo_finalizado = finish || fifo_lleno;


endmodule
