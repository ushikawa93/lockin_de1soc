/* =================================================================================
 * ==============================  adc_driver ===============================
 * Este módulo controla un ADC de alta velocidad. 
 * Toma la señal de reloj CLK_65 y señales de habilitación, 
 * y genera las salidas del ADC con registro intermedio para sincronización. 
 * También produce señales de salida Avalon streaming: data_canal_a, data_canal_b
 * y data_valid para indicar datos válidos.
//================================================================================= */

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

//reg en_reg; always @ (posedge CLK_65) en_reg <= (!reset_n)? 0: enable;


always @ (posedge CLK_65 or negedge reset_n) 
begin

	if(!reset_n)
	begin
		r_ADC_DA <= 0;
		r_ADC_DB <= 0;
		data_valid_reg <= 0;
	
	end
	else
	begin			
		r_ADC_DA <= ADC_DA;
		r_ADC_DB <= ADC_DB;
		
		if (enable)	
			data_valid_reg <= 1;	
		else
			data_valid_reg <= 0;	
	end
	
end


//=======================================================
//  Salidas
//=======================================================

assign data_canal_a =  r_ADC_DA;
assign data_canal_b =  r_ADC_DB;
assign data_valid = data_valid_reg;


endmodule






