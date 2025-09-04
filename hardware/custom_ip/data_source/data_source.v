/* ==========================================================================
 * ============================ DATA SOURCE ==================================
 *  Descripción general:
 *    Este módulo genera datos simulados tipo sinusoidal cuantizada en 14 bits,
 *    agregando ruido opcional. Puede generar ruido mediante LFSR o un
 *    generador congruencial lineal (GCL), según el parámetro de selección.
 *    Los datos se entregan como flujo tipo Avalon Streaming.
 *
 *  Entradas:
 *    - clock: reloj principal de operación.
 *    - reset_n: reset activo en bajo.
 *    - enable: habilita la generación de datos.
 *    - simulation_noise: cantidad de bits de ruido a generar.
 *    - ptos_x_ciclo: número de puntos por ciclo de la señal sinusoidal.
 *    - seleccion_ruido: 0 -> LFSR; 1 -> GCL.
 *
 *  Salidas:
 *    - data_valid: indica que el dato de salida es válido.
 *    - data: dato de salida de 32 bits con señal y ruido.
 *    - zero_cross: pulso en cada paso por cero de la señal sinusoidal.
 *    - lfsr_cicled: indica cuando el LFSR completa un ciclo completo.
 *
 *  Funcionamiento:
 *    1. Se selecciona el generador de ruido según `seleccion_ruido`.
 *    2. Se calcula el intervalo dentro de la tabla de look-up para obtener
 *       la señal sinusoidal cuantizada.
 *    3. Se suma el ruido atenuado al valor de la señal para producir la
 *       salida final `data`.
 *    4. Se generan las señales auxiliares `zero_cross` y `lfsr_cicled`.
 *
 *  Observaciones:
 *    - La tabla de look-up tiene 2048 valores y se adapta a la cantidad de
 *      puntos por ciclo usando interpolación por índice.
 *    - Adecuado para pruebas de sistemas de ADC/DAC con señal y ruido controlado.
 * ========================================================================== */

module data_source(

	// Entradas de control
	input clock,
	input reset_n,
	input enable,
	
	// Parametros de configuracion
	input [7:0] simulation_noise,
	input [15:0] ptos_x_ciclo,
	input 	seleccion_ruido,
	
	// Salida avalon streaming
	output reg data_valid,
	output signed [31:0] data,
	
	output [31:0] noise,

	// Salidas auxiliares
	output zero_cross,
	output reg lfsr_cicled
);


//=======================================================
// Ruido LFSR
//=======================================================
	
wire [31:0] dato_ruidoso_lfsr;
wire ciclo_completado;
wire dato_ruidoso_lfsr_valid;

LFSR ruido_lfsr
(	
	.i_Clk(clock),
	.i_Enable(1'b1),
	
	.o_LFSR_Data(dato_ruidoso_lfsr),
	.o_LFSR_Done(ciclo_completado),
	
	.o_LFSR_valid(dato_ruidoso_lfsr_valid)
	
);

parameter MAX_bits = 24 ;


defparam ruido_lfsr.NUM_BITS = 32;		// Genero ruido de 32 bits para maximizar el periodo del LFSR, despues lo trunco...
wire [MAX_bits-1:0] dato_ruidoso_truncado_lfsr;
	assign dato_ruidoso_truncado_lfsr = dato_ruidoso_lfsr[MAX_bits:0];

wire signed [31:0] dato_ruidoso_atenuado_lfsr;
	assign dato_ruidoso_atenuado_lfsr = (dato_ruidoso_truncado_lfsr >> (MAX_bits-simulation_noise) ) - (2**(simulation_noise)>>1);

//=======================================================
// Ruido con generador congruencial lineal
//=======================================================
	
	
wire [31:0] dato_ruidoso_gcl;
wire dato_ruidoso_gcl_valid;

reg [31:0] dato_aleatorio_anterior;
  
initial dato_aleatorio_anterior = 0;   
always @ (posedge clock) dato_aleatorio_anterior <= dato_ruidoso_gcl;

GCL ruido_GCL
  (  
	.i_Clk(clock),
   .i_Enable(1'b1),
	.i_seed(dato_aleatorio_anterior),
   .o_Data(dato_ruidoso_gcl),
	.o_Data_valid(dato_ruidoso_gcl_valid)
  );
  
wire [MAX_bits-1:0] dato_ruidoso_truncado_gcl;
	assign dato_ruidoso_truncado_gcl = dato_ruidoso_gcl[MAX_bits-1:0];

wire signed [31:0] dato_ruidoso_atenuado_gcl;
	assign dato_ruidoso_atenuado_gcl = (dato_ruidoso_truncado_gcl >> (MAX_bits-simulation_noise) ) - (2**(simulation_noise)>>1);

	
//=======================================================
// Reg/Wire declarations
//=======================================================

parameter atenuacion = 0;

wire [15:0] M = ptos_x_ciclo;				// Puntos por ciclo de señal

reg [15:0] interval;
reg sync;
			
reg signed [15:0] buffer [0:2047];
		 initial	$readmemh("LU_Tables/x2048_14b.mem",buffer);
	//  initial	$readmemh("LU_Tables/rampa.mem",buffer);

reg signed [31:0] data_out_reg;	
	assign data = data_out_reg;

reg [15:0] index,index_2;

reg en_reg,data_valid_aux,data_valid_aux_2; 
	always @ (posedge clock) 	en_reg <= enable;

reg signed [31:0] noise_reg; 
	
always @ (posedge clock)	interval = 2048/M; // Para poder cambiar el largo de la secuencia sin tener que leer otro archivo

wire ruido_valid; assign ruido_valid = (seleccion_ruido == 1)? dato_ruidoso_gcl_valid: dato_ruidoso_lfsr_valid;

//=======================================================
// Algoritmo principal
//=======================================================

//Manda un dato cada delay+1 ciclos de reloj
always @ (posedge clock or negedge reset_n)
begin

	
	if(!reset_n) 
	begin 
		index <= 0; 
		index_2 <= 0;
		data_valid <= 0;
		data_valid_aux<=0;
		data_valid_aux_2<=0;
		data_out_reg<=0; 
		sync <= 0;
	end
	
	else if(en_reg && ruido_valid) 
	begin		
	
		// 1 etapa registro el indice
		index <= (index == (M-1))? 0: index+1 ;
		data_valid_aux <= 1;
			
		// 2 escalo el indice
		index_2 <= index*interval;
		data_valid_aux_2 <= 1;
		
		noise_reg <= (seleccion_ruido == 1)? dato_ruidoso_atenuado_gcl : dato_ruidoso_atenuado_lfsr;
	
		// 3 etapa saco el dato para afuera del modulo
		sync <= (index_2 == 0) && (data_valid_aux_2);
		data_out_reg <= ((buffer[index_2]) >> atenuacion )  + noise_reg;			
		data_valid <= data_valid_aux_2;
	end	
	
	else
		data_valid <= 0;

end

//=======================================================
// Señalizacion de paso por cero del seno
//=======================================================

assign zero_cross = sync;
//=======================================================
// Señalizacion de ciclo del LFSR
//=======================================================

// A 65 MHz y 32 bits de LFSR conseguimos un periodo de 66 s
// por lo que la secuencia puede considerarse aleatoria uniforme

always @ (posedge clock or negedge reset_n)
begin
	
	if(!reset_n) 	
		lfsr_cicled = 0;
	
	else	if (ciclo_completado == 1)
		lfsr_cicled = !lfsr_cicled;
end

//=======================================================
// Exporto el ruido solo tambien (me sirve para otras cosas)
//=======================================================


assign noise = noise_reg;

endmodule
