
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
	input [31:0] 	 digital_data_in,
	input 			 digital_data_in_valid,
	
	
	// Interfaces de salida de datos:
	
	// Simulacion
	output simulation_data_valid,
	output [31:0] simulation_data,
	
	// ADC highspeed
	output	[13:0] data_canal_a,
	output	[13:0] data_canal_b,
	output			 data_adc_valid,
	
	// ADC 2308
	output	[31:0] data_adc_2308,
	output			 data_adc_2308_valid


);


/////////////////////////////////////////////////
// ================ Datos simulados ===============
/////////////////////////////////////////////////

data_source data_sim(

	// Entradas de control
	.clock(clk_sim),
	.reset_n(reset_n),
	.enable(enable),
	
	// Parametros de configuracion
	.simulation_noise(simulation_noise_bits),
	.ptos_x_ciclo(ptos_x_ciclo_sim),
	.seleccion_ruido(metodo_ruido),
	
	// Salida avalon streaming
	.data_valid(simulation_data_valid),
	.data(simulation_data),
	
);


/////////////////////////////////////////////////
// ===================== DAC ===================
/////////////////////////////////////////////////
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



/////////////////////////////////////////////////
// ===================== ADC  ===================
/////////////////////////////////////////////////
/*
	Si se quiere usar este ADC el clk_custom setea la frecuencia de muestreo 
	la señal data_adc_valid sirve para sincronizar el procesamiento de 
	etapas posteriores.

*/

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


/////////////////////////////////////////////////
// ===================== ADC 2308 ===================
/////////////////////////////////////////////////
/*
	Si se quiere usar este ADC el clk_custom debe estar en 40 MHz...
	La frecuencia de muestreo queda dada por f_muestreo y la señal
	data_adc_2308_valid sirve para sincronizar el procesamiento de 
	etapas posteriores.

*/
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
