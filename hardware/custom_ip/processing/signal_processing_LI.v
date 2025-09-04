/*==============================================================================
 Módulo: signal_processing_LI
 ------------------------------------------------------------------------------

 Descripción:
 -------------
 Módulo de procesamiento de señal tipo Lock-In (LI) para streaming Avalon. 
 Calcula componentes en fase y en cuadratura de la señal de entrada usando una 
 referencia externa senoidal/cosenoidal.  

 Características principales:
 -----------------------------
 - Lock-in segmentado con referencia externa opcional.
 - Procesamiento de señales de streaming tipo Avalon.
 - Salidas en fase y cuadratura (64 bits con signo).
 - Parametrizable mediante registros configurables (`parameter_in_0` a `parameter_in_32`) 
   cargados al reset.
 - Señales de control:
     - `ready_to_calculate`: indica que el lock-in está listo para operar.
     - `processing_finished`: indica que se completó el cálculo.
 - Soporta bypass para evaluación sin procesamiento si se desea.

 Entradas:
 ----------
 - clk                      : Reloj del sistema.
 - reset_n                  : Reset activo bajo.
 - enable_gral              : Habilita procesamiento general.
 - bypass                    : Habilita paso directo sin procesamiento.
 - referencia_externa        : Señal de referencia externa (binaria).
 - sync                      : Señal de sincronización para el lock-in.
 - referencia_externa_sen    : Componente senoidal de la referencia externa.
 - referencia_externa_cos    : Componente cosenoidal de la referencia externa.
 - referencia_externa_valid  : Validez de la referencia externa.
 - data_in                   : Datos de entrada a procesar (32 bits con signo).
 - data_in_valid             : Validez de `data_in`.
 - parameter_in_0 .. parameter_in_32 : Parámetros de configuración cargados al reset.

 Salidas:
 ---------
 - data_out1                 : Componente en fase del lock-in (64 bits).
 - data_out1_valid           : Validez de `data_out1`.
 - data_out2                 : Componente en cuadratura del lock-in (64 bits).
 - data_out2_valid           : Validez de `data_out2`.
 - ready_to_calculate        : Indica que el lock-in está listo.
 - processing_finished       : Indica que el procesamiento finalizó.
 - parameter_out_0 .. parameter_out_4 : Parámetros de salida (uso general).

 Notas:
 -------
 - El lock-in segmentado utiliza referencias sen/cos con validación.
 - Las salidas están sincronizadas con la validez de la entrada.
 - `n_datos_promediados` se expone como `parameter_out_0`.
 - Se puede comentar la sección de bypass para pruebas sin procesamiento.
==============================================================================*/

module signal_processing_LI(
	input clk,
	input reset_n,
	input enable_gral,	
	
	input bypass,
	
	// Referencia externa
	input referencia_externa,
	input sync,
	input signed [31:0] referencia_externa_sen,
	input signed [31:0] referencia_externa_cos,
	input referencia_externa_valid,
	
	input signed [31:0] data_in,
	input 		 data_in_valid,
	
	output signed [63:0] data_out1,
	output signed  data_out1_valid,
	
	output signed [63:0] data_out2,
	output signed  data_out2_valid,
	
	output ready_to_calculate,
	output processing_finished,
	
	input [31:0] parameter_in_0,
	input [31:0] parameter_in_1,
	input [31:0] parameter_in_2,
	input [31:0] parameter_in_3,
	input [31:0] parameter_in_4,
	input [31:0] parameter_in_5,
	input [31:0] parameter_in_6,
	input [31:0] parameter_in_7,
	input [31:0] parameter_in_8,
	input [31:0] parameter_in_9,
	
	input [31:0] parameter_in_10,
	input [31:0] parameter_in_11,
	input [31:0] parameter_in_12,
	input [31:0] parameter_in_13,
	input [31:0] parameter_in_14,
	input [31:0] parameter_in_15,
	input [31:0] parameter_in_16,
	input [31:0] parameter_in_17,
	input [31:0] parameter_in_18,
	input [31:0] parameter_in_19,
	
	input [31:0] parameter_in_20,
	input [31:0] parameter_in_21,
	input [31:0] parameter_in_22,
	input [31:0] parameter_in_23,
	input [31:0] parameter_in_24,
	input [31:0] parameter_in_25,
	input [31:0] parameter_in_26,
	input [31:0] parameter_in_27,
	input [31:0] parameter_in_28,
	input [31:0] parameter_in_29,
	
	input [31:0] parameter_in_30,
	input [31:0] parameter_in_31,
	input [31:0] parameter_in_32,
	
	
	output [31:0] parameter_out_0,
	output [31:0] parameter_out_1,
	output [31:0] parameter_out_2,
	output [31:0] parameter_out_3,
	output [31:0] parameter_out_4
		

);




////////////////////////////////////////////////////////////////
// ================ Registro parametros en reset ===============
////////////////////////////////////////////////////////////////


// Modificables en tiempo de ejecucion:
reg[31:0] parameter_0_reg,parameter_1_reg,parameter_2_reg,parameter_3_reg,parameter_4_reg,parameter_5_reg,parameter_6_reg,parameter_7_reg,parameter_8_reg,parameter_9_reg;
reg[31:0] parameter_10_reg,parameter_11_reg,parameter_12_reg,parameter_13_reg,parameter_14_reg,parameter_15_reg,parameter_16_reg,parameter_17_reg,parameter_18_reg,parameter_19_reg;
reg[31:0] parameter_20_reg,parameter_21_reg,parameter_22_reg,parameter_23_reg,parameter_24_reg,parameter_25_reg,parameter_26_reg,parameter_27_reg,parameter_28_reg,parameter_29_reg;
reg[31:0] parameter_30_reg,parameter_31_reg,parameter_32_reg;

always @ (posedge clk)
begin

	if(!reset_n)
	begin
		parameter_0_reg <= parameter_in_0;
		parameter_1_reg <= parameter_in_1;
		parameter_2_reg <= parameter_in_2;
		parameter_3_reg <= parameter_in_3;
		parameter_4_reg <= parameter_in_4;
		parameter_5_reg <= parameter_in_5;
		parameter_6_reg <= parameter_in_6;
		parameter_7_reg <= parameter_in_7;
		parameter_8_reg <= parameter_in_8;
		parameter_9_reg <= parameter_in_9;
		
		parameter_10_reg <= parameter_in_10;
		parameter_11_reg <= parameter_in_11;
		parameter_12_reg <= parameter_in_12;
		parameter_13_reg <= parameter_in_13;
		parameter_14_reg <= parameter_in_14;
		parameter_15_reg <= parameter_in_15;
		parameter_16_reg <= parameter_in_16;
		parameter_17_reg <= parameter_in_17;
		parameter_18_reg <= parameter_in_18;
		parameter_19_reg <= parameter_in_19;
		
		parameter_20_reg <= parameter_in_20;
		parameter_21_reg <= parameter_in_21;
		parameter_22_reg <= parameter_in_22;
		parameter_23_reg <= parameter_in_23;
		parameter_24_reg <= parameter_in_24;
		parameter_25_reg <= parameter_in_25;
		parameter_26_reg <= parameter_in_26;
		parameter_27_reg <= parameter_in_27;
		parameter_28_reg <= parameter_in_28;
		parameter_29_reg <= parameter_in_29;
		
		parameter_30_reg <= parameter_in_30;
		parameter_31_reg <= parameter_in_31;
		parameter_32_reg <= parameter_in_32;
		
	end

end

//////////////////////////////////////////////////
// ================ Procesamiento ===============
//////////////////////////////////////////////////

wire [15:0] M = parameter_0_reg;
wire [15:0] N_ma = parameter_1_reg;


////////////////////////////////////////////////
// ================== Lock in  ===============
////////////////////////////////////////////////

//////// Entradas de LIA ///////
wire data_in_lia_valid;
	assign data_in_lia_valid = data_in_valid;

wire signed [31:0] data_in_lia; 
	assign data_in_lia = data_in;

lockin_segmentado lock_in(

	// Entradas de control
	.clock(clk),
	.reset_n(reset_n),
	.enable(enable_gral),
	
	// Parametros de configuracion
	.ptos_x_ciclo(M),
	.frames_integracion(N_ma),
	
	// Referencia externa
	.referencia_externa(referencia_externa),
	.sync(sync),
	.referencia_externa_sen(referencia_externa_sen),
	.referencia_externa_cos(referencia_externa_cos),
	.referencia_externa_valid(referencia_externa_valid),
	
	// Entrada avalon streaming
	.data_valid(data_in_lia_valid),
	.data(data_in_lia),	
		
	// Salidas avalon streaming
	.data_out_fase(data_fase),
	.data_out_fase_valid(data_fase_valid),

	.data_out_cuad(data_cuad),
	.data_out_cuad_valid(data_cuad_valid),
	
	// Salidas auxiliares
	.lockin_ready(lockin_ready),
	.n_datos_promediados(n_datos_promediados),
	.fifos_llenos(calculo_finalizado)
	
);

//////// Salidas de lockin ////////
wire signed [63:0] data_cuad;
wire data_cuad_valid;
wire signed [63:0] data_fase;
wire data_fase_valid;

wire calculo_finalizado;
wire lockin_ready;	// El lockin esta listo para calcular
wire [31:0] n_datos_promediados;



//////////////////////////////////////////////////
// ================ Salidas  ===============
//////////////////////////////////////////////////

assign data_out1 = data_fase;
assign data_out1_valid = data_fase_valid;
	
assign data_out2 = data_cuad;
assign data_out2_valid = data_cuad_valid;
	

wire ready_fase,ready_cuadratura;
wire finished_fase,finished_cuadratura;

assign ready_to_calculate = lockin_ready;
assign processing_finished = calculo_finalizado;

assign parameter_out_0 = n_datos_promediados;
assign parameter_out_1 = 0;
assign parameter_out_2 = 0;
assign parameter_out_3 = 0;
assign parameter_out_4 = 0;


//////////////////////////////////////////////////
// ================ Sin procesamiento ===============
//////////////////////////////////////////////////
/*
assign data_out1 = data_in;
assign data_out1_valid = data_in_valid;

assign data_out2 = data_in;
assign data_out2_valid = data_in_valid;

assign ready_to_calculate = 1;
*/

endmodule

