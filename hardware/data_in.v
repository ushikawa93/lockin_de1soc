
/* =========================================================================
 * ============= Módulo de Entrada de Datos ================================
 *  Descripción general:
 *    Este módulo centraliza la adquisición de datos desde distintas fuentes,
 *    incluyendo:
 *      - Datos simulados (con ruido configurable)
 *      - ADC/DAC Highspeed
 *      - ADC 2308 embebido
 *    Permite sincronización de clocks, habilitación selectiva y parametrización
 *    de cada bloque.
 *
 *  Señales principales:
 *    - clk_*: distintos relojes para simulación, DAC, ADC y ADC 2308.
 *    - reset_n, enable: control de reset y habilitación general.
 *    - simulation_noise_bits, ptos_x_ciclo_sim, metodo_ruido: configuración
 *      de la generación de datos simulados.
 *    - ptos_x_ciclo_dac, sincronizar_adc_con_dac: configuración DAC/ADC
 *      highspeed.
 *    - f_muestreo_2308, sel_ch_2308: configuración ADC 2308.
 *    - ADC_*, DAC_*: señales físicas hacia los ADCs y DACs.
 *    - digital_data_in: datos digitales para DAC.
 *    - data_*: señales de salida avalon-streaming para simulación y ADCs.
 *
 *  Funcionamiento:
 *    1. Genera una señal simulada cuantizada de 14 bits, con ruido opcional.
 *    2. Controla la salida digital hacia el DAC highspeed, pudiendo usar
 *       look-up table o datos externos.
 *    3. Adquiere datos desde ADC highspeed y ADC 2308, aplicando la
 *       sincronización y habilitación correspondiente.
 *    4. Expone los datos adquiridos mediante interfaces streaming válidas
 *       para las etapas de procesamiento posteriores.
 *
 *  Observaciones:
 *    - La habilitación del ADC highspeed puede depender del DAC (sincronización)
 *      o ser independiente.
 *    - Se permite usar distintas fuentes de datos de manera simultánea o
 *      selectiva según la aplicación.
 * ==========================================================================
*/


module data_in(

	input clk_sim,
	input clk_dac,
	input clk_adc,
	input clk_adc_2308,
	
	input reset_n,
	input enable,
	
	// Parametros para datos simulados
	input [31:0] simulation_noise_bits,
	input [31:0] ptos_x_ciclo_sim,
	input 		 metodo_ruido,			// 0 -> LFSR ; 1 -> GCL	
	
	// Parametros de configuracion para ADC/DAC highspeed	
	input [15:0]	 ptos_x_ciclo_dac,
	input 			 sincronizar_adc_con_dac,
	
	// Parametros de configuracion para ADC 2308
	input [31:0]    f_muestreo_2308,
	input 			 sel_ch_2308,

	// Entradas y salidas de ADC/DAC highspeed	
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
	
	
	// Entradas y salidas de ADC 2308	
	output	adc_cs_n,
	output	adc_sclk,
	output	adc_din,
	input 	adc_dout,
	
	// Entradas digitales para el DAC
	input				 lu_table_input,
	input [31:0] 	 digital_data_in,
	input 			 digital_data_in_valid,
	
	
	// Interfaces de salida de datos:
	
	// Simulacion
	output simulation_data_valid,
	output [31:0] simulation_data,
	output [31:0] noise,
	output sync_dat_simulada,
	
	// ADC highspeed
	output	[13:0] data_canal_a,
	output	[13:0] data_canal_b,
	output			 data_adc_valid,
	
	// ADC 2308
	output	[31:0] data_adc_2308,
	output			 data_adc_2308_valid


);


/* ================================================================================
 * ============================ Datos simulados ===================================
 * Este módulo genera una señal sinusoidal cuantizada en 14 bits, 
 * posiblemente contaminada con ruido uniforme de simulation_noise_bits bits
 * Para generar el ruido se usa un algoritmo LFSR o un generador congruencial lineal,
 * segun el parámetro metodo ruido ( 0 -> LFSR ; 1 -> GCL	)
 * pts_x_ciclo setea cuantos puntos hay en cada periodo de la sinusoide
 * ================================================================================ */
 
data_source data_sim(

	// Entradas de control
	.clock(clk_sim),
	.reset_n(reset_n),
	.enable(enable),
	
	// Parametros de configuracion
	.simulation_noise(simulation_noise_bits),
	.ptos_x_ciclo(ptos_x_ciclo_sim),
	.seleccion_ruido(metodo_ruido),
	
	.noise(noise),
	
	// Salida avalon streaming
	.data_valid(simulation_data_valid),
	.data(simulation_data),
	
	.zero_cross(sync_dat_simulada)
	
);




/* ==============================================================
 * ====================== DAC ===================================
 * Driver del DAC Highspeed, la señal seleccion_dac determina 
 * si los datos que se convierten a analogico
 * son los de una LU table que tiene seteada
 * o los que le van entrando por digital_data_in
 * ============================================================== */

wire data_dac_valid;

dac_driver dac_HS(

	// Entradas de control
	.CLK_65(clk_dac),
	.reset_n(reset_n),
	.enable(enable),
	
	// Parametros de configuracion	
	.ptos_x_ciclo(ptos_x_ciclo_dac),
	.seleccion_dac(0),
	
	// Entrada digital (si no se usa una tabla de look up)...
	.lu_table_input(lu_table_input),
	.digital_data_in(digital_data_in),
	.digital_data_in_valid(digital_data_in_valid),
	
	// Entradas y salidas del DAC
	.DAC_CLK_A(DAC_CLK_A),
	.DAC_DA(DAC_DA),
	.DAC_WRT_A(DAC_WRT_A),
	
	.DAC_CLK_B(DAC_CLK_B),
	.DAC_DB(DAC_DB),
	.DAC_WRT_B(DAC_WRT_B),
	
	.DAC_MODE(DAC_MODE),
	.POWER_ON(POWER_ON),
	
	// Salidas
	.data_valid_dac_export(data_dac_valid)


);



/* ==============================================================
 * ====================== ADC ===================================
 * Si se quiere usar este ADC el clk_custom setea la frecuencia de muestreo 
 * la señal data_adc_valid sirve para sincronizar el procesamiento de 
 * etapas posteriores.
 * ============================================================== */

wire enable_adc = (sincronizar_adc_con_dac)? data_dac_valid : enable;

adc_driver adc_HS(
	
	// Entradas de control
	.CLK_65(clk_adc),
	.reset_n(reset_n),
	.enable(enable_adc),
	
	// Entradas y salidas del ADC/DAC	 
	.ADC_CLK_A(ADC_CLK_A),
	.ADC_DA(ADC_DA),
	.ADC_OEB_A(ADC_OEB_A),
	.ADC_OTR_A(ADC_OTR_A),
	
	.ADC_CLK_B(ADC_CLK_B),
	.ADC_DB(ADC_DB),
	.ADC_OEB_B(ADC_OEB_B),
	.ADC_OTR_B(ADC_OTR_B),
	
	// Salida avalon streaming
	.data_canal_a(data_canal_a),
	.data_canal_b(data_canal_b),
	.data_valid(data_adc_valid)



);



/* ==================================================================
 * ====================== ADC 2308 ==================================
 * 	Si se quiere usar este ADC el clk_custom debe estar en 40 MHz...
 *	La frecuencia de muestreo queda dada por f_muestreo y la señal
 *	data_adc_2308_valid sirve para sincronizar el procesamiento de 
 *	etapas posteriores.
 * ================================================================= */

embedded_adc adc_2308(

	// Entradas de control
	.clk(clk_adc_2308),
	.reset_n(reset_n),
	.enable(enable),
	
	// Parametros de configuracion	
	.fmuestreo(f_muestreo_2308),
	.sel_ch(sel_ch_2308),
	

	// Entradas y salidas del ADC
	.adc_cs_n(adc_cs_n),
	.adc_sclk(adc_sclk),
	.adc_din(adc_din),
	.adc_dout(adc_dout),
	
	// Salida avalon streaming	
	.data_stream_valid_adc(data_adc_2308_valid),
	.data_stream_adc(data_adc_2308)

);


endmodule
