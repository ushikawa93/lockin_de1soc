
module adc_driver(

	// Entradas de control
	input 			 CLK_65,
	input				 reset_n,
	input				 enable,
		

	// Entradas y salidas de ADC
   output 		    ADC_CLK_A,
	input    [13:0] ADC_DA,
	output			 ADC_OEB_A,
	input				 ADC_OTR_A,
	
	output			 ADC_CLK_B,
	input	 	[13:0] ADC_DB,
	output			 ADC_OEB_B,
	input				 ADC_OTR_B,
	
	
	// Interfaz avalon streaming de salida
	output	[13:0] data_canal_a,
	output	[13:0] data_canal_b,
	output			 data_valid


);


//=======================================================
//  ADC REG/WIRE declarations
//=======================================================

assign  ADC_CLK_B = CLK_65;  	    //PLL Clock to ADC_B
assign  ADC_CLK_A = CLK_65;  	    //PLL Clock to ADC_A

assign  ADC_OEB_A = 0; 		  	    //ADC_OEA	Output enables activos en bajo
assign  ADC_OEB_B = 0; 			    //ADC_OEB

reg	[13:0]	r_ADC_DA;
reg	[13:0]	r_ADC_DB;
reg 	data_valid_reg;

always @ (posedge CLK_65) 
begin

	r_ADC_DA <= ADC_DA;
	r_ADC_DB <= ADC_DB;
	data_valid_reg <= enable;
	
end


//=======================================================
//  Salidas
//=======================================================

assign data_canal_a =  r_ADC_DA;
assign data_canal_b =  r_ADC_DB;
assign data_valid = data_valid_reg;


endmodule






