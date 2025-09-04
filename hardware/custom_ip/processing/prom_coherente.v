/* ==========================================================================
 * ============================ PROM_COHERENTE ==============================
 *  Descripción general:
 *    Este módulo realiza un promedio coherente de N frames sobre M puntos 
 *    por ciclo de señal. Se utiliza en un Lock-In digital para suavizar la 
 *    señal de fase o cuadratura después de la multiplicación por referencias.
 *
 *  Entradas:
 *    - clk: reloj del sistema.
 *    - reset: reset activo en bajo.
 *    - data_in: señal de entrada a promediar (signed 32 bits).
 *    - data_in_valid: indica que `data_in` es válida.
 *
 *  Salidas:
 *    - data_out: salida del promedio coherente (signed 32 bits).
 *    - data_out_valid: indica que `data_out` es válida.
 *    - calculando: indica que el módulo aún está acumulando frames.
 *
 *  Parámetros:
 *    - M: cantidad de puntos por ciclo de señal.
 *    - N: cantidad de frames a promediar coherentemente.
 *
 *  Funcionamiento:
 *    1. Se mantiene un buffer de tamaño M que acumula la suma de los frames.
 *    2. Se incrementa `frames_promediados` cuando se completa un ciclo.
 *    3. Una vez que se completan N frames, se generan 8 ciclos de salida de
 *       datos válidos (`data_out_valid` = 1) usando el buffer acumulado.
 *    4. Luego se limpia el buffer y se puede volver a iniciar el promedio.
 *
 *  Observaciones:
 *    - `calculando` permite saber si el módulo aún está acumulando frames.
 *    - La salida se mantiene válida solo durante 8 ciclos por promedio.
 * ========================================================================== */

module prom_coherente(
	
	input clk,
	input reset,
	
	input data_in_valid,
	input signed [31:0] data_in,
	
	output reg data_out_valid,
	output signed [31:0] data_out,
	
	output calculando
	
);

parameter M=32; 	// Cantidad de puntos por ciclo de señal
parameter N=64;		// Frames promediados coherentemente... 
							// en el 65 haría el lockin de 32 ptos
							
reg [15:0] index,frames_promediados,i,ciclos_enviados; 

reg signed [31:0] buffer [0:M-1];
reg signed [31:0] data_out_reg;


initial begin data_out_valid <= 0;index=0;frames_promediados=0;data_out_reg<=0;ciclos_enviados=0;end

// Registro las entradas... es mas prolijo trabajar con las entradas registradas

reg signed [31:0] data_in_reg; always @ (posedge clk) data_in_reg <=(!reset)? 0: data_in;
reg signed data_valid_reg; always @ (posedge clk) data_valid_reg <= (!reset)? 0: data_in_valid;


always@ (posedge clk or negedge reset)
begin
	
	
	if(!reset)	//init
	begin 
		data_out_valid <= 0;
		index<=0;
		frames_promediados<=0;			
		data_out_reg<=0;
		ciclos_enviados<=0; 
	end

	else if ( (data_valid_reg) && (frames_promediados<N) )		//calcular
	begin
		
		index <= (index==(M-1))? 0 : index+1;
			
		// 1 etapa datos anteriores
		buffer[index] <= data_in_reg + buffer[index];
		
		if((index==(M-1)))
				frames_promediados <= frames_promediados+1;
		
	end
	
	else if ( (frames_promediados==N) && (ciclos_enviados < 8) )	//send	
	begin
		index <= (index==(M-1))? 0 : index+1;		
		
		if((index==(M-1))) ciclos_enviados <= ciclos_enviados + 1; 
		
		data_out_valid <= 1;
		data_out_reg <= buffer[index];

	end
	
	else if ( (ciclos_enviados == 8) )		//finish
	begin
		buffer[index]<=0;
		index <= (index==(M-1))? 0 : index+1;	
		data_out_valid <= 0;
	end
		

end

assign data_out = data_out_reg; 

assign calculando = ((data_valid_reg) && (frames_promediados<N))?1:0;

endmodule
