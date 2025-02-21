
module embedded_adc(


	input clk,
	input reset_n,
	input enable,
	
	input [31:0] fmuestreo,
	input [3:0]  sel_ch,
	

	////////// ADC ////////
	output	adc_cs_n,
	output	adc_sclk,
	output	adc_din,
	input 	adc_dout,
	
	///// SALIDAS /////////
	
	output data_stream_valid_adc,
	output [31:0] data_stream_adc


);

////////////////// ADC ///////////////
// logica para el adc. Inculye timer, seleccion de canal //
// un divisor de frec (pq max clkadc=40 MHz) y el controlador // 


timer timer_adc(

	.clk(clk),
	.reset(reset_n),
	.enable(enable),
	.frecuencia_deseada(fmuestreo),
	.sinc(measure_start)
);

wire measure_start;

	
adc_ltc2308 adc_ltc2308_inst(
	.clk(clk), // max 40mhz

	// start measure
	.measure_start(measure_start), // posedge triggle
	.measure_done(measure_done),
	.measure_ch(sel_ch),
	.measure_dataread(dato_adc),	
	
	// adc interface
	.ADC_CONVST(adc_cs_n),
	.ADC_SCK(adc_sclk),
	.ADC_SDI(adc_din),
	.ADC_SDO(adc_dout) 
	
);

wire [15:0] dato_adc;
wire measure_done;


adc2streaming adc2streaming_inst(

	.clk(clk),
	.reset(reset_n),
	.sinc(measure_done),
	.data_in(dato_adc),
	
	.data_out0(data_stream_adc),
	.data_out_valid0(data_stream_valid_adc)
	
);


endmodule
