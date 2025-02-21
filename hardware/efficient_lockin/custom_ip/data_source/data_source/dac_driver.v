
module dac_driver(

	// Entradas de control
	input 			 CLK_65,
	input				 reset_n,
	input				 enable,
	
	// Parametros de configuracion
	input [15:0]	 ptos_x_ciclo,
	input 			 seleccion_dac,		// 0 -> seno / 1 -> constante
	
	// Entrada digital (si no se usa una tabla de look up)...
	input				 lu_table_input,
	input [13:0] 	 digital_data_in,
	input 			 digital_data_in_valid,

	// Entradas y salidas del DAC
	output			 DAC_CLK_A,
	output   [13:0] DAC_DA,
	output			 DAC_WRT_A,
	
	output 			 DAC_CLK_B,
	output   [13:0] DAC_DB,
	output			 DAC_WRT_B,
	
	output			 DAC_MODE,
	output			 POWER_ON,

	
	// Salida para sincronizar modulos posteriores	
	output			 data_valid_dac_export


);

wire LU_table = lu_table_input;

//=======================================================
// Origen de los datos para el dac (LU table) 
//=======================================================


wire dato_dac_lu_table_valid;
wire [13:0] dato_dac_lu_table;
wire zero_cross;


data_source_dac data_s (

	.clock(CLK_65),
	.reset_n(reset_n),
	.CE(enable),
	
	.ptos_x_ciclo(ptos_x_ciclo),
	.seleccion_dac(seleccion_dac),
	
	.zero_cross(zero_cross),
	.data_valid(dato_dac_lu_table_valid),
	.data(dato_dac_lu_table)
	
);


//=======================================================
// Acondicionamiento de señal externa
//=======================================================

// Esto es para acomodar niveles de DAC y ADC (valores comentados)
parameter mult_factor = 1;	// 1189
parameter log2_div_factor = 0;	// con 10 es 2**10=1024, lo mismo que un right shift de 10

reg [31:0] digital_data_in_reg,digital_data_in_reg_1;
reg digital_data_in_valid_reg,digital_data_in_valid_reg_1;

always @ (posedge CLK_65)
begin
	
	digital_data_in_reg_1			<= digital_data_in * mult_factor;	
	digital_data_in_valid_reg_1	<= digital_data_in_valid;
	
	digital_data_in_reg 				<= digital_data_in_reg_1 >>> log2_div_factor ;
	digital_data_in_valid_reg	 	<= digital_data_in_valid_reg_1;
	
end




//=======================================================
// Seleccion de datos para el dac
//=======================================================

wire [13:0] dato_dac;
wire data_dac_valid;

assign dato_dac = (LU_table) ? dato_dac_lu_table : digital_data_in_reg;
assign data_dac_valid = (LU_table) ? dato_dac_lu_table_valid : digital_data_in_valid_reg;

reg [31:0] dato_dac_reg;
	
	always @ (posedge CLK_65)
	begin
		if(!reset_n)
		begin
			dato_dac_reg <= nivel_idle;
		end
		if(digital_data_in_valid_reg)
		begin
			dato_dac_reg <= dato_dac;
		end
				
	end

//=======================================================
//  DAC REG/WIRE declarations
//=======================================================



parameter nivel_idle = 8192;			// Cuando los DAC estan inactivos los pongo a este valor
												// esto es para que cuando arranque la cosa no tenga que hacer un salto muy grande...
												// si los pongo en 0 cuando arranca tiene que saltar al 8192, y no le da el slew rate a los OPA

assign  DAC_WRT_B = CLK_65;       //Input write signal for PORT B
assign  DAC_WRT_A = CLK_65;       //Input write signal for PORT A

assign  DAC_MODE = 1; 		        //Mode Select. 1 = dual port, 0 = interleaved.

assign  DAC_CLK_B = CLK_65; 	    //PLL Clock to DAC_B
assign  DAC_CLK_A = CLK_65; 	    //PLL Clock to DAC_A


assign  POWER_ON  = 1;            //Disable OSC_SMA

assign  DAC_DA = (data_dac_valid)? dato_dac : dato_dac_reg ; 
assign  DAC_DB = (data_dac_valid)? dato_dac : dato_dac_reg ; 



//=======================================================
//  Circuiteria del data_valid
//=======================================================

wire data_valid_adc;

//Desde el data_valid del source necesito 1 ciclo para que se acomode el DAC, y
//el ADC necesita un rato para acomodarse (En total hay "delay" ciclos de reloj con cosas que no tienen sentido)


parameter delay = 10;
reg [15:0] counter_pipeline;

always @ (posedge CLK_65)
	if(!reset_n)
		counter_pipeline <= 0;
	else if(data_dac_valid)
		counter_pipeline <= (counter_pipeline == delay)? counter_pipeline : counter_pipeline + 1;


//=======================================================
//  Salidas
//=======================================================

assign data_valid_dac_export = (data_dac_valid && (counter_pipeline == delay));


endmodule

