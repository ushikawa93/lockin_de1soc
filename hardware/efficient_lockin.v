//////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                          //
//                                    efficient_lockin                                      //
//                                                                                          //
//  Descripción:                                                                            //
//  --------------------------------------------------------------------------------------  //
//  Módulo principal para el procesamiento tipo Lock-In en FPGA. Integra adquisición de     //
//  señales desde ADCs de alta velocidad y el ADC 2308, generación de referencias con DDS,  //
//  procesamiento de señales (LI y CA-LI), control mediante Nios/HPS, y salida por DAC.     //
//                                                                                          //
//  Funcionalidades clave:                                                                  //
//   - Multiplexación flexible de fuentes de datos (ADC, simulación, señales procesadas).   //
//   - Generación de referencias sinusoidales y cosenoidales con DDS.                       //
//   - Procesamiento Lock-In (LI) y Coherent Averaging Lock-In (CA-LI).                     //
//   - Interfaz con memorias FIFO de 32 y 64 bits.                                          //
//   - Control parametrizable mediante softcore Nios/HPS.                                   //
//   - Monitoreo con LEDs y señal de reloj de vigilancia.                                   //
//                                                                                          //
//  Entradas/Salidas principales:                                                           //
//   - CLK, SW, KEY, LED                                                                    //
//   - ADC/DAC de alta velocidad                                                            //
//   - ADC 2308                                                                             //
//   - HPS DDR3                                                                             //
//                                                                                          //
//  Autor: [Tu Nombre]                                                                      //
//  Fecha: [03/09/2025]                                                                     //
//                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////

/* ================================================================================ *
 *                      +-------------------+										*
 *     ADC HS --------->|                   |										*
 *     ADC 2308 ------->|    Multiplexor    |										*
 *         ^            | (fuente de datos) |										*
 *         |            +---------+---------+										*
 *     Desde Carga                |													*
 *                                v													*
 *                      +-------------------+										*
 *                      |  DDS (sin/cos)    |										*
 *                      |  Generación ref.  |-------+	 							*
 *                      +---------+---------+		|								*
 *                                |					|								*
 *                                v					|								*
 *                      +-------------------+		|								*
 *                      |   Procesamiento   |		|								*
 *                      |  LI / CA-LI core  |		|								*
 *                      +---------+---------+		|								*
 *                                |					|								*
 *                +---------------+				    |								*
 *                |                                 |								*
 *                v                                 v								*
 *       +------------------+              +------------------+						*
 *       |   FIFO 32/64b    |              |       DAC        |						*
 *       |  (almacenaje)    |              |  salida analógica|						*
 *       +------------------+              +------------------+						*
 *                |									|								*
 *                v									v								*
 *        +-----------------+					Hacia Carga							*
 *        |  HPS / Nios II  |														*
 *        |  Control y cfg. |														*
 *        +-----------------+														*
 *																					*
 *                    (Monitoreo: LEDs + reloj watchdog)							*
 * ================================================================================	*/


module efficient_lockin(

	////////// CLK /////////
	input clk,
	
	 ///////// SW /////////
    input       [3:0]  SW,
	
	///////// KEYS ////////
	input 		[1:0] KEY,
	
	///////// LED /////////
	output		[3:0] LED,
		
	 		
	//////// Highspeed ADC_DAC //////
	 
   output 		    ADC_CLK_A,
	input    [13:0] ADC_DA,
	output			 ADC_OEB_A,
	input				 ADC_OTR_A,
	
	output			 ADC_CLK_B,
	input	 	[13:0] ADC_DB,
	output			 ADC_OEB_B,
	input				 ADC_OTR_B,
		
	output			 DAC_CLK_A,
	output   [13:0] DAC_DA,
	output			 DAC_WRT_A,
	
	output 			 DAC_CLK_B,
	output   [13:0] DAC_DB,
	output			 DAC_WRT_B,
	
	output			 DAC_MODE,
	output			 OSC_SMA_ADC4,
	output			 POWER_ON,
	output			 SMA_DAC4,
	
	//////// HPS ////////////
	output      [14:0] HPS_DDR3_ADDR,
   output      [2:0]  HPS_DDR3_BA,
   output             HPS_DDR3_CAS_N,
   output             HPS_DDR3_CKE,
   output             HPS_DDR3_CK_N,
   output             HPS_DDR3_CK_P,
   output             HPS_DDR3_CS_N,
   output      [3:0]  HPS_DDR3_DM,
   inout       [31:0] HPS_DDR3_DQ,
   inout       [3:0]  HPS_DDR3_DQS_N,
   inout       [3:0]  HPS_DDR3_DQS_P,
   output             HPS_DDR3_ODT,
   output             HPS_DDR3_RAS_N,
   output             HPS_DDR3_RESET_N,
   input              HPS_DDR3_RZQ,
   output             HPS_DDR3_WE_N,
	
	// Entradas y salidas de ADC 2308	
	output	adc_cs_n,
	output	adc_sclk,
	output	adc_din,
	input 	adc_dout,
	
	output watch
);



/* =============================================================================
 * ======================== Ruteo de Señales ==================================
 *
 * Descripción general:
 *   Esta sección define cómo se rutean las señales dentro del sistema.
 *   Cada destino (procesamiento, DAC o FIFOs) puede tomar su entrada desde
 *   diferentes fuentes de datos, permitiendo una arquitectura flexible.
 *
 * Fuentes disponibles:
 *   - adc_2308              : datos desde el ADC 2308
 *   - adc_hs                : datos desde el ADC de alta velocidad
 *   - simulacion            : datos simulados
 *   - procesada_1           : señal procesada (canal 1)
 *   - procesada_2           : señal procesada (canal 2)
 *   - avgd_signal           : señal promediada
 *   - dds_compiler_sen      : salida seno del DDS
 *   - dds_compiler_cos      : salida coseno del DDS
 *   - referencia_seno       : señal de referencia senoidal
 *   - referencia_coseno     : señal de referencia cosenoidal
 *   - datos_procesamiento   : datos ya preparados para etapa de cálculo
 *   - open                  : sin señal (vacío)
 *
 * Señales de control principales:
 *   - fuente_procesamiento  : selecciona qué fuente alimenta la etapa de cálculo
 *   - fuente_dac            : define qué fuente se envía al DAC
 *   - fuente_fifo0_32bit    : fuente que alimenta el FIFO0 de 32 bits
 *   - fuente_fifo1_32bit    : fuente que alimenta el FIFO1 de 32 bits
 *   - fuente_fifo0_64bit    : fuente que alimenta el FIFO0 de 64 bits
 *   - fuente_fifo1_64bit    : fuente que alimenta el FIFO1 de 64 bits
 *
 * Funcionamiento:
 *   - Cada destino recibe un paquete {dato, valid} generado mediante un bloque
 *     combinacional de selección (tipo multiplexer).
 *   - Los datos y sus señales de validez se mantienen sincronizados en todo el
 *     ruteo, asegurando consistencia en el sistema.
 *   - Este esquema permite reconfigurar fácilmente qué señales se procesan,
 *     visualizan o almacenan en cada FIFO.
 *
 * Observaciones:
 *   - Se agregaron fuentes adicionales (avgd_signal, DDS y referencias).
 *   - El control del ruteo se realiza desde la etapa de control (HPS/NIOS).
 *   - Se incluye lógica para sincronizar el ADC HS con el procesamiento.
 *
 * =============================================================================
 */


// Posibilidades...
parameter adc_2308 = 0;
parameter adc_hs = 1;
parameter simulacion = 2;
parameter procesada_1 = 3;
parameter procesada_2 = 4;
parameter avgd_signal = 5;
parameter dds_compiler_sen = 6;
parameter dds_compiler_cos = 7;
parameter referencia_seno = 8;
parameter referencia_coseno = 9;
parameter datos_procesamiento = 10;
parameter open = 11;

// Fuentes de señal para cada etapa del proceso

// Este determina de donde vienen los datos para el procesamiento: 
wire [31:0] fuente_procesamiento;	// Lo define la etapa de control pueden ser simulada, adc_2308,adc_hs

parameter fuente_dac = dds_compiler_sen ;	

parameter fuente_fifo0_32bit = datos_procesamiento;
wire fuente_fifo1_32bit = avgd_signal;

parameter fuente_fifo0_64bit = procesada_1;
parameter fuente_fifo1_64bit = procesada_2;

// Valores para el procesamiento:

wire [31:0] data_adc_hs = (SW[0] == 0)? data_canal_b: data_canal_a;

wire [31:0] data_in_procesamiento = (fuente_procesamiento == adc_2308)? data_adc_2308 : 
												(fuente_procesamiento == adc_hs)? data_adc_hs_reg : 
												(fuente_procesamiento == simulacion)? datos_simulados : 0;
												
wire data_in_procesamiento_valid =  (fuente_procesamiento == adc_2308)? data_adc_2308_valid : 
												(fuente_procesamiento == adc_hs)? data_adc_hs_valid_reg : 
												(fuente_procesamiento == simulacion)? datos_simulados_valid : 0; 
												

// Prueba medio desprolija para sincronizar referencia y data_in_procesamiento...
	
reg [31:0] data_adc_hs_reg;
reg data_adc_hs_valid_reg;

always @ (posedge clk_custom)
begin

	data_adc_hs_reg <= data_adc_hs;
	data_adc_hs_valid_reg <= data_adc_valid;

end
	


///////////////////////// Entradas del DAC ////////////////////////////////////:

wire [31:0] data_in_dac = aux_dac[32:1];
wire data_in_dac_valid = aux_dac[0];


wire [32:0] aux_dac	= 	(fuente_dac == adc_2308) ? {data_adc_2308,data_adc_2308_valid} :
								(fuente_dac == adc_hs) ? {data_adc_hs,data_adc_valid} :
								(fuente_dac == simulacion) ? {datos_simulados,datos_simulados_valid} :
								(fuente_dac == procesada_1) ? {data_procesada1,data_procesada1_valid} :
								(fuente_dac == procesada_2) ? {data_procesada2,data_procesada2_valid} :
								(fuente_dac == avgd_signal) ? {data_promc,data_promc_valid} :
								(fuente_dac == dds_compiler_sen) ? {sen_dds_compiler_14b,dds_compiler_valid} :
								(fuente_dac == dds_compiler_cos) ? {cos_dds_compiler_14b,dds_compiler_valid} :
								(fuente_dac == referencia_seno) ? {referencia_sen,referencia_valid} :
								(fuente_dac == referencia_coseno) ? {referencia_cos,referencia_valid} :
								(fuente_dac == datos_procesamiento) ? {data_in_procesamiento,data_in_procesamiento_valid} : 0;

///////////////////////// Entrada de memorias FIFO ////////////////////////////////////:

wire [31:0] data_in_fifo0_32bit = aux_fifo0_32b [32:1];
wire data_in_fifo0_32bit_valid = aux_fifo0_32b[0];


wire [32:0] aux_fifo0_32b = (fuente_fifo0_32bit == adc_2308) ? {data_adc_2308,data_adc_2308_valid} :
									 (fuente_fifo0_32bit == adc_hs) ? {data_adc_hs,data_adc_valid} :
									 (fuente_fifo0_32bit == simulacion) ? {datos_simulados,datos_simulados_valid} :
									 (fuente_fifo0_32bit == procesada_1) ? {data_procesada1,data_procesada1_valid} :
									 (fuente_fifo0_32bit == procesada_2) ? {data_procesada2,data_procesada2_valid} :
									 (fuente_fifo0_32bit == avgd_signal) ? {data_promc,data_promc_valid} :
									 (fuente_fifo0_32bit == dds_compiler_sen) ? {sen_dds_compiler_14b,dds_compiler_valid} :
									 (fuente_fifo0_32bit == dds_compiler_cos) ? {cos_dds_compiler_14b,dds_compiler_valid} :
									 (fuente_fifo0_32bit == referencia_seno) ? {referencia_sen,referencia_valid} :
									 (fuente_fifo0_32bit == referencia_coseno) ? {referencia_cos,referencia_valid} :
									 (fuente_fifo0_32bit == datos_procesamiento) ? {data_in_procesamiento,data_in_procesamiento_valid} : 0;
									 
									 
wire [31:0] data_in_fifo1_32bit = aux_fifo1_32b [32:1];
wire data_in_fifo1_32bit_valid = aux_fifo1_32b[0];


wire [32:0] aux_fifo1_32b = (fuente_fifo1_32bit == adc_2308) ? {data_adc_2308,data_adc_2308_valid} :
									 (fuente_fifo1_32bit == adc_hs) ? {data_adc_hs,data_adc_valid} :
									 (fuente_fifo1_32bit == simulacion) ? {datos_simulados,datos_simulados_valid} :
									 (fuente_fifo1_32bit == procesada_1) ? {data_procesada1,data_procesada1_valid} :
									 (fuente_fifo1_32bit == procesada_2) ? {data_procesada2,data_procesada2_valid} :
									 (fuente_fifo1_32bit == avgd_signal) ? {data_promc,data_promc_valid} :
									 (fuente_fifo1_32bit == dds_compiler_sen) ? {sen_dds_compiler_14b,dds_compiler_valid} :
									 (fuente_fifo1_32bit == dds_compiler_cos) ? {cos_dds_compiler_14b,dds_compiler_valid} :
									 (fuente_fifo1_32bit == referencia_seno) ? {referencia_sen,referencia_valid} :
									 (fuente_fifo1_32bit == referencia_coseno) ? {referencia_cos,referencia_valid} :
									 (fuente_fifo1_32bit == datos_procesamiento) ? {data_in_procesamiento,data_in_procesamiento_valid} : 0;

									 
wire [63:0] data_in_fifo0_64bit = aux_fifo0_64b [64:1];
wire data_in_fifo0_64bit_valid = aux_fifo0_64b[0];


wire [64:0] aux_fifo0_64b = (fuente_fifo0_64bit == adc_2308) ? {data_adc_2308,data_adc_2308_valid} :
									 (fuente_fifo0_64bit == adc_hs) ? {data_adc_hs,data_adc_valid} :
									 (fuente_fifo0_64bit == simulacion) ? {datos_simulados,datos_simulados_valid} :
									 (fuente_fifo0_64bit == procesada_1) ? {data_procesada1,data_procesada1_valid} :
									 (fuente_fifo0_64bit == procesada_2) ? {data_procesada2,data_procesada2_valid} :
									 (fuente_fifo0_64bit == avgd_signal) ? {data_promc,data_promc_valid} :
									 (fuente_fifo0_64bit == dds_compiler_sen) ? {sen_dds_compiler_14b,dds_compiler_valid} :
									 (fuente_fifo0_64bit == dds_compiler_cos) ? {cos_dds_compiler_14b,dds_compiler_valid} :
									 (fuente_fifo0_64bit == referencia_seno) ? {referencia_sen,referencia_valid} :
									 (fuente_fifo0_64bit == referencia_coseno) ? {referencia_cos,referencia_valid} :
									 (fuente_fifo0_64bit == datos_procesamiento) ? {data_in_procesamiento,data_in_procesamiento_valid} : 0;

									 
wire [63:0] data_in_fifo1_64bit = aux_fifo1_64b [64:1];
wire data_in_fifo1_64bit_valid = aux_fifo1_64b[0];


wire [64:0] aux_fifo1_64b = (fuente_fifo1_64bit == adc_2308) ? {data_adc_2308,data_adc_2308_valid} :
									 (fuente_fifo1_64bit == adc_hs) ? {data_adc_hs,data_adc_valid} :
									 (fuente_fifo1_64bit == simulacion) ? {datos_simulados,datos_simulados_valid} :
									 (fuente_fifo1_64bit == procesada_1) ? {data_procesada1,data_procesada1_valid} :
									 (fuente_fifo1_64bit == procesada_2) ? {data_procesada2,data_procesada2_valid} :
									 (fuente_fifo1_64bit == avgd_signal) ? {data_promc,data_promc_valid} :
									 (fuente_fifo1_64bit == dds_compiler_sen) ? {sen_dds_compiler_14b,dds_compiler_valid} :
									 (fuente_fifo1_64bit == dds_compiler_cos) ? {cos_dds_compiler_14b,dds_compiler_valid} :
									 (fuente_fifo1_64bit == referencia_seno) ? {referencia_sen,referencia_valid} :
									 (fuente_fifo1_64bit == referencia_coseno) ? {referencia_cos,referencia_valid} :
									 (fuente_fifo1_64bit == datos_procesamiento) ? {data_in_procesamiento,data_in_procesamiento_valid} : 0;


									 

/* =============================================================================
 * =========================== DDS Compiler ===================================
 *
 * Descripción general:
 *   Esta sección implementa dos instancias del módulo DDS (Direct Digital
 *   Synthesizer) para generar señales sinusoidales y cosenoidales usadas en
 *   el sistema:
 *     - Un DDS para el DAC de salida.
 *     - Un DDS para las señales de referencia (Lock-In).
 *
 * Parámetros:
 *   - B_dds_dac : Ancho de palabra de salida hacia el DAC (14 bits).
 *   - B_dds_ref : Ancho de palabra de salida de las referencias (16 bits).
 *
 * Señales principales:
 *   - sen_dds_compiler_14b, cos_dds_compiler_14b :
 *       Señales seno y coseno generadas para el DAC.
 *   - sen_dds_compiler_ca_coupled, cos_dds_compiler_ca_coupled :
 *       Señales seno y coseno de referencia en 32 bits (convertidas a signed).
 *   - referencia_sen, referencia_cos :
 *       Alias para las señales de referencia.
 *   - dds_compiler_valid :
 *       Señal de validez de los datos del DDS hacia el DAC.
 *   - referencia_valid :
 *       Señal de validez de los datos de referencia.
 *   - sync_referencias :
 *       Pulso de cruce por cero, útil para sincronización.
 *
 * Funcionamiento:
 *   - El DDS del DAC funciona continuamente habilitado por la señal `enable`.
 *   - El DDS de referencias se habilita según la fuente seleccionada:
 *       • Si fuente_procesamiento = simulación → habilitado por `enable`.
 *       • En otro caso → habilitado por la validez del ADC HS.
 *   - Ambos DDS reciben un `incremento_fase` que determina la frecuencia de
 *     salida (f_out = delta_phase * f_clk / 2^B_acumulador).
 *
 * Observaciones:
 *   - Esta sección genera tanto las señales analógicas de salida (DAC) como
 *     las referencias internas requeridas por el procesamiento Lock-In.
 *   - Se asegura que las referencias estén acopladas en fase con la señal de
 *     entrada mediante el pulso de sincronización.
 *
 * Diagrama simplificado:
 *
 *              		 +--------------------+
 *   delta_phase_dac --->|      DDS DAC       |---> seno/coseno (14b) ---> DAC
 *                       +--------------------+
 *                                ^
 *                                |
 *                       enable (global)
 *
 *              		 +--------------------+
 *   delta_phase_ref --->|   DDS Referencia   |---> referencia_sen/cos (32b)
 *                       |  (con sync zero)   |---> referencia_valid
 *                       +--------------------+
 *                                ^
 *                                |
 *                  enable_ref (según fuente seleccionada)
 *
 * =============================================================================
 */


parameter B_dds_dac = 14;
parameter B_dds_ref = 16;


wire signed [31:0] sen_dds_compiler_ca_coupled = $signed (sen_ca_aux) ;
wire signed [31:0] cos_dds_compiler_ca_coupled = $signed (cos_ca_aux) ;

wire signed [31:0] referencia_sen = sen_dds_compiler_ca_coupled;
wire signed [31:0] referencia_cos = cos_dds_compiler_ca_coupled;


wire signed [B_dds_ref-1:0] sen_ca_aux,cos_ca_aux;

wire signed [31:0] sen_dds_compiler_14b ;
wire signed [31:0] cos_dds_compiler_14b ;

wire dds_compiler_valid,referencia_valid,sync_referencias;


dds_compiler_module #(	
	.B_out(B_dds_dac)
) generador_sinusoidal_para_dac
(
	.clk(clk_custom),
	.reset_n(reset_n),
	.enable(enable),	
	
	.incremento_fase(delta_phase_dac),	 // round(f_deseada * 2^B_acumulador/f_clk);
	
	.data_out_seno(sen_dds_compiler_14b),
	.data_out_coseno(cos_dds_compiler_14b),	
	
	.data_out_valid(dds_compiler_valid)
	
);

wire enable_ref = (fuente_procesamiento == simulacion)? enable : data_adc_valid;


dds_compiler_module #(	
	.B_out(B_dds_ref)
) generador_sinusoidal_para_referencias
(
	.clk(clk_custom),
	.reset_n(reset_n),
	.enable(enable_ref),	
	
	.incremento_fase(delta_phase_ref),	 // round(f_deseada * 2^B_acumulador/f_clk);
	
	.zero_cross(sync_referencias),
	
	.data_out_seno_ca_coupled(sen_ca_aux),
	.data_out_coseno_ca_coupled(cos_ca_aux),	
	
	.data_out_valid(referencia_valid)
	
);


/* =============================================================================
 * ========================== Interfaz de control =============================
 *
 * Descripción general:
 *   Esta sección implementa la interfaz de control del sistema, que gestiona
 *   la activación, reinicio y configuración de todos los bloques de procesamiento
 *   y adquisición de datos.
 *
 * Funcionalidad destacada:
 *   • Combina señales de control físicas y de software para habilitar el sistema.
 *   • Genera el reloj interno (`clk_custom`) usado por los módulos de adquisición.
 *   • Permite reconfigurar parámetros del sistema desde el Nios o HPS:
 *       - Fuente de procesamiento
 *       - Parámetros de promediado y filtrado
 *       - Configuración del DDS
 *       - Parámetros de simulación y selección de resultados
 *   • Recibe resultados procesados de 32 y 64 bits para almacenamiento o visualización.
 *   • Incluye interfaces hacia la memoria DDR3 del HPS para lectura y escritura.
 * =============================================================================
 */


wire enable;
	assign enable = enable_from_control && ready_to_calculate;
wire reset_n;
	assign reset_n = !reset_from_control && reset_physical;

	
wire enable_from_control;
wire clk_custom;
wire reset_from_control;
wire reset_physical = KEY[0];


// Algunos parametros reconfigurables...
wire led_test;
wire [31:0] sim_noise;
wire [31:0] M;
wire [31:0] N_ma_CALI;
wire [31:0] N_ca_CALI;
wire [31:0] N_LI;
wire [31:0] delta_phase_dac,delta_phase_ref;
wire seleccion_resultado;

// Este flag determina como controlo las referencias y el DAC!
wire [31:0] dds_in_data_sim;


control nios (

	 // Logica de control
	 .clk						(clk),
	 .reset_n					(reset_physical),	
	 .enable					(enable_from_control),
	 .clk_custom				(clk_custom),
	 .reset_from_control		(reset_from_control),
	 .calculo_finalizado 		(calculo_finalizado),
	 
	 // Parametros reconfigurables
	 .parameter_out_0				(fuente_procesamiento),
	 .parameter_out_1				(M),
	 .parameter_out_2				(N_ma_CALI),
	 .parameter_out_3				(N_ca_CALI),
	 .parameter_out_4				(sim_noise),
	 .parameter_out_5				(seleccion_resultado),
	 .parameter_out_6				(N_LI),
	 .parameter_out_7				(delta_phase_ref),
	 .parameter_out_8				(delta_phase_dac),
	 .parameter_out_9 				(dds_in_data_sim),
	 .parameter_out_10				(led_test),
	 
	 
	 .parameter_in_0				(n_datos_promediados),
	 
	
	 // Resultados de procesamiento de 32 bits
	 .result_0_32_bit			(data_in_fifo0_32bit),
	 .result_0_32_bit_valid		(data_in_fifo0_32bit_valid),
	
	 .result_1_32_bit			(data_in_fifo1_32bit),
	 .result_1_32_bit_valid 	(data_in_fifo1_32bit_valid),
	 
	 .result_0_64_bit			(data_in_fifo0_64bit),
	 .result_0_64_bit_valid		(data_in_fifo0_64bit_valid),
	 
	 .result_1_64_bit			(data_in_fifo1_64bit),
	 .result_1_64_bit_valid		(data_in_fifo1_64bit_valid),
	 
	  // Memoria DDR3 del HPS
	 .HPS_DDR3_ADDR         (HPS_DDR3_ADDR),                          //          memory.mem_a
	 .HPS_DDR3_BA           (HPS_DDR3_BA),                         //                .mem_ba
	 .HPS_DDR3_CK_P         (HPS_DDR3_CK_P),                         //                .mem_ck
	 .HPS_DDR3_CK_N         (HPS_DDR3_CK_N),                       //                .mem_ck_n
	 .HPS_DDR3_CKE          (HPS_DDR3_CKE),                        //                .mem_cke
	 .HPS_DDR3_CS_N         (HPS_DDR3_CS_N),                       //                .mem_cs_n
	 .HPS_DDR3_RAS_N        (HPS_DDR3_RAS_N),                      //                .mem_ras_n
	 .HPS_DDR3_CAS_N        (HPS_DDR3_CAS_N),                      //                .mem_cas_n
	 .HPS_DDR3_WE_N         (HPS_DDR3_WE_N),                       //                .mem_we_n
	 .HPS_DDR3_RESET_N      (HPS_DDR3_RESET_N),                    //                .mem_reset_n
	 .HPS_DDR3_DQ           (HPS_DDR3_DQ),                         //                .mem_dq
	 .HPS_DDR3_DQS_P        (HPS_DDR3_DQS_P),                        //                .mem_dqs
	 .HPS_DDR3_DQS_N        (HPS_DDR3_DQS_N),                      //                .mem_dqs_n
	 .HPS_DDR3_ODT          (HPS_DDR3_ODT),                        //                .mem_odt
	 .HPS_DDR3_DM           (HPS_DDR3_DM),                         //                .mem_dm
	 .HPS_DDR3_RZQ          (HPS_DDR3_RZQ),                      //                
                  //                
		
);

/* =============================================================================
 * ===================== Interfaz de datos de entrada ==========================
 *
 * Descripción general:
 *   Esta sección implementa la interfaz principal de adquisición y simulación
 *   de datos, incluyendo:
 *     - Entradas de control y reloj.
 *     - Configuración de parámetros de simulación y muestreo.
 *     - Generación de datos simulados con ruido opcional.
 *     - Interfaz de salida de datos para ADC/DAC de alta velocidad.
 *     - Manejo del ADC externo (2308).
 *     - Sincronización de señales de referencia mediante retardo ajustable.
 *
 * Funcionalidad destacada:
 *   • Permite seleccionar entre datos simulados o generados por el DDS como
 *     fuente de entrada.
 *   • Incorpora un generador de ruido digital parametrizable.
 *   • Sincroniza los datos de simulación con las referencias del lock-in.
 *   • Expone interfaces Avalon Streaming para datos de simulación, ADC HS y
 *     ADC 2308.
 *   • Incluye conexiones directas a los conversores analógico-digital y
 *     digital-analógico.
 * =============================================================================
 */




data_in data(

	// Entradas de control
	.reset_n(reset_n),
	.enable(enable),
	
	// Entradas de reloj
	.clk_sim(clk_custom),
	.clk_dac(clk_custom),
	.clk_adc(clk_custom),
	.clk_adc_2308(clk_custom),
		
	// Parametros de configuracion -> Podrian conectarse a el Nios o HPS si quisieramos...
	.simulation_noise_bits(sim_noise),
	.ptos_x_ciclo_sim(M),
	.metodo_ruido(0),
	.ptos_x_ciclo_dac(M),
	.sincronizar_adc_con_dac(1),
	.f_muestreo_2308(1000),
	.sel_ch_2308(0),	
	
	// Salida avalon streaming simulacion	
	.simulation_data_valid(datos_simulados_old_valid),
	.simulation_data(datos_simulados_old),
	.noise(noise),
	.sync_dat_simulada(sync_dat_simulada),
	
	// Salida avalon streaming ADC
	.data_canal_a(data_canal_a),
	.data_canal_b(data_canal_b),
	.data_adc_valid(data_adc_valid),
	
	// Salida avalon streaming	ADC 2308
	.data_adc_2308_valid(data_adc_2308_valid),
	.data_adc_2308(data_adc_2308),
		
	
	// Entradas y salidas del ADC/DAC HIghSPEED
	.ADC_CLK_A(ADC_CLK_A),
	.ADC_DA(ADC_DA),
	.ADC_OEB_A(ADC_OEB_A),
	.ADC_OTR_A(ADC_OTR_A),
	
	.ADC_CLK_B(ADC_CLK_B),
	.ADC_DB(ADC_DB),
	.ADC_OEB_B(ADC_OEB_B),
	.ADC_OTR_B(ADC_OTR_B),
		
	.DAC_CLK_A(DAC_CLK_A),
	.DAC_DA(DAC_DA),
	.DAC_WRT_A(DAC_WRT_A),
	
	.DAC_CLK_B(DAC_CLK_B),
	.DAC_DB(DAC_DB),
	.DAC_WRT_B(DAC_WRT_B),
	
	.DAC_MODE(DAC_MODE),
	.OSC_SMA_ADC4(OSC_SMA_ADC4),
	.POWER_ON(POWER_ON),
	.SMA_DAC4(SMA_DAC4),
	
	// Entradas digitales para el DAC
	.lu_table_input(!dds_in_data_sim),
	.digital_data_in(data_in_dac),
	.digital_data_in_valid(data_in_dac_valid),
	
	// Entradas y salidas del ADC 2308
	.adc_cs_n(adc_cs_n),
	.adc_sclk(adc_sclk),
	.adc_din(adc_din),
	.adc_dout(adc_dout)

	
);


////// Delay para acomodar la señal sync //////

wire sync_dat_simulada;
wire sync_dat_simulada_retrasada;

///// Si se usan las referencias internas del modulo lockin habria que atrasar el sync! /////
delay_axi_streaming#(
	
	.delay(12),
	.width(1)

	) delay_sync(
	
	.clk(clk_custom),
   .reset_n(reset_n),
   .bypass(0),
   .data_in(sync_dat_simulada),    
   .data_out(sync_dat_simulada_retrasada),

);

////// Salidas de datos simulados //////

wire [31:0] noise;

wire [31:0] datos_simulados_old;
wire datos_simulados_old_valid;

wire [31:0] datos_simulados = (dds_in_data_sim)? ( sen_dds_compiler_14b + noise ): datos_simulados_old;
wire datos_simulados_valid = (dds_in_data_sim)? dds_compiler_valid : datos_simulados_old_valid;
wire sync_procesamiento = (dds_in_data_sim) ? sync_referencias : sync_dat_simulada_retrasada;

///// Salidas de los ADC HS ////////
wire [31:0] data_canal_a;
wire [31:0] data_canal_b;
wire data_adc_valid;

///// Salidas de ADC 2308 ////////
wire [31:0] data_adc_2308;
wire data_adc_2308_valid;


/* =============================================================================
 * ======================= Procesamiento de señal CA-LI ========================
 *
 * Descripción general:
 *   Esta sección implementa el bloque de procesamiento de señal para la
 *   adquisición CA-LI, que realiza:
 *     - Filtrado y cálculo de señales procesadas.
 *     - Promediado coherente de la señal.
 *     - Sincronización con referencias externas generadas por DDS o simulación.
 *	   - Lock-in en fase y cuadratura para le señal procesada coherentemente
 * Parametros importantes:
 *
 *	.parameter_in_1(N_ma_CALI)   -> Cantida de ciclos promediados en el Lockin (filtro MA)
 *	.parameter_in_2(N_ca_CALI)   -> Cantidad de ciclos promediados coherentemente
 *
 * Funcionalidad destacada:
 *   • Recibe la señal de entrada desde la interfaz de datos (simulada o ADC).
 *   • Procesa la señal a través de los módulos CALI para obtener dos salidas
 *     principales de 64 bits y una señal auxiliar promediada de 32 bits.
 *   • Gestiona señales de control como `ready_to_calculate` y `processing_finished`.
 *   • Sincroniza los resultados con el sistema de referencia del lock-in.
 * =============================================================================
 */


wire sync_cali = sync_procesamiento;

signal_processing_CALI signal_processing_CALI_inst(

	.clk(clk_custom),
	.reset_n(reset_n),
	.enable_gral(enable),	
	
	.bypass(0),
	
	.referencia_externa(dds_in_data_sim),
	.sync(sync_cali),
	.referencia_externa_sen(referencia_sen),
	.referencia_externa_cos(referencia_cos),
	.referencia_externa_valid(referencia_valid),
	
	
	.data_in(data_in_procesamiento),
	.data_in_valid(data_in_procesamiento_valid),
	
	.data_out1(data_procesada1_CALI),
	.data_out1_valid(data_procesada1_CALI_valid),
	
	.data_out2(data_procesada2_CALI),
	.data_out2_valid(data_procesada2_CALI_valid),
	
	.aux_signal(data_promc),
	.aux_signal_valid(data_promc_valid),
	
	.parameter_in_0(M),
	.parameter_in_1(N_ma_CALI),
	.parameter_in_2(N_ca_CALI),
	
	.parameter_out_0(sync_avgd_signal),
	
	.ready_to_calculate(ready_to_calculate_CALI),
	.processing_finished(calculo_finalizado_CALI)

);

///// Salidas de procesamiento ////////
wire [63:0] data_procesada1_CALI,data_procesada2_CALI;
wire data_procesada1_CALI_valid,data_procesada2_CALI_valid;
wire ready_to_calculate_CALI;
wire calculo_finalizado_CALI;

///// Señal promediada coherentemente /////
wire [31:0] data_promc;
wire data_promc_valid;
wire sync_avgd_signal;

/* =============================================================================
 * ========================== Procesamiento de señal LI ========================
 *
 * Descripción general:
 *   Esta sección implementa el bloque de procesamiento de señal para el
 *   procesamiento LI (Lock-In), que realiza:
 *     - Lock-in en fase y cuadratura para le señal procesada coherentemente
 *			- Multiplicación por referencias
 *			- Filtro de media movil
 * 
 * Parametros importantes:
 *   .parameter_in_1(N_LI)   -> Cantidad de ciclos promediados en el MAF
 *
 * Funcionalidad destacada:
 *   • Recibe la señal de entrada desde la interfaz de datos (simulada o ADC).
 *   • Procesa la señal a través del módulo LI para obtener dos salidas
 *     principales de 64 bits.
 *   • Calcula el número de datos promediados (`n_datos_promediados`) para la
 *     salida coherente.
 *   • Gestiona señales de control como `ready_to_calculate` y `processing_finished`.
 *   • Sincroniza los resultados con el sistema de referencia del lock-in.
 * =============================================================================
 */


wire sync_li = sync_procesamiento;

signal_processing_LI signal_processing_LI_inst(

	.clk(clk_custom),
	.reset_n(reset_n),
	.enable_gral(enable),	
	
	.bypass(0),
	
	.referencia_externa(dds_in_data_sim),
	.sync(sync_li),
	.referencia_externa_sen(referencia_sen),
	.referencia_externa_cos(referencia_cos),
	.referencia_externa_valid(referencia_valid),
	
	.data_in(data_in_procesamiento),
	.data_in_valid(data_in_procesamiento_valid),
	
	.data_out1(data_procesada1_LI),
	.data_out1_valid(data_procesada1_LI_valid),
	
	.data_out2(data_procesada2_LI),
	.data_out2_valid(data_procesada2_LI_valid),
	
	.parameter_in_0(M),
	.parameter_in_1(N_LI),
	
	.parameter_out_0(n_datos_promediados),
	
	.ready_to_calculate(ready_to_calculate_LI),
	.processing_finished(calculo_finalizado_LI)

);


///// Salidas de procesamiento ////////
wire [63:0] data_procesada1_LI,data_procesada2_LI;
wire data_procesada1_LI_valid,data_procesada2_LI_valid;
wire ready_to_calculate_LI;
wire calculo_finalizado_LI;
wire [31:0] n_datos_promediados;



/* =============================================================================
 * =================== Ruteo de señales de procesamiento ========================
 *
 * Descripción general:
 *   Esta sección selecciona qué conjunto de señales de procesamiento se
 *   utiliza como salida final del sistema, según el parámetro
 *   `seleccion_resultado`:
 *     - Si `seleccion_resultado == 0`, se usan las señales del procesamiento
 *       CA-LI (CALI).
 *     - Si `seleccion_resultado == 1`, se usan las señales del procesamiento
 *       LI (Lock-In).
 *
 * Funcionalidad destacada:
 *   • Rutea las salidas de 64 bits de los módulos de procesamiento
 *     (`data_procesada1`, `data_procesada2`) hacia los FIFOs y DAC.
 *   • Rutea las señales de validez (`_valid`) correspondientes.
 *   • Rutea las señales de control (`ready_to_calculate`, `calculo_finalizado`)
 *     según la selección.
 * =============================================================================
 */


///// Salidas de procesamiento ////////
wire [63:0] data_procesada1 = (seleccion_resultado == 0)?  data_procesada1_CALI: data_procesada1_LI;
wire [63:0] data_procesada2 = (seleccion_resultado == 0)?  data_procesada2_CALI: data_procesada2_LI;
wire data_procesada1_valid = (seleccion_resultado == 0)?  data_procesada1_CALI_valid: data_procesada1_LI_valid;
wire data_procesada2_valid = (seleccion_resultado == 0)?  data_procesada2_CALI_valid: data_procesada2_LI_valid;
wire ready_to_calculate = (seleccion_resultado == 0)? ready_to_calculate_CALI : ready_to_calculate_LI;
wire calculo_finalizado = (seleccion_resultado == 0)? calculo_finalizado_CALI : calculo_finalizado_LI;


/* ================================================================================
 * ======================= Cosas adicionales =====================
 *  Para ver si la placa esta andando y bien configurada se agrega un titileo de LED
 *  También se puede rutear los LED a distintas señales para ver que hacen
 ================================================================================ */


////////////////////////////////////////////////
// ====== Contador para ver si clk anda  =========
////////////////////////////////////////////////

reg [31:0] count;
always @ (posedge clk_custom)
begin
	count <= (count == 65000000)? 0 : count+1;
end

assign LED[0] = ( count > (65000000 >> 1) );

////////////////////////////////////////////////
// ====== Algunos LED para ver cositas  =========
////////////////////////////////////////////////
assign LED[3] = led_test;

assign LED[2] = calculo_finalizado;

assign LED[1] = 0;
	 
assign watch = sync_procesamiento;

endmodule
	 