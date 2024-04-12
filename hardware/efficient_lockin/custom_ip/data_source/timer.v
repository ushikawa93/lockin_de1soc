
module timer(

	input 		 clk,
	input 		 reset,
	input 		 enable,
	input [31:0] frecuencia_deseada,

	output reg sinc 
);

parameter POINTS = 1;
parameter clk_period = 40000000;

reg [31:0] clock_count; initial clock_count = 0;
reg	actualizar_clock_count; initial actualizar_clock_count=0;

wire [31:0] half_clock_count; assign half_clock_count = clock_count >> 1;

reg [31:0] counter; initial counter <= 0;

reg [31:0] frec_reg; initial frec_reg <= 0;

initial sinc = 0;

always @ (posedge clk)
begin

	frec_reg <= frecuencia_deseada;	
	
	if(frec_reg != frecuencia_deseada)	
		actualizar_clock_count <= 1;
		
		
	if(actualizar_clock_count)	begin
		clock_count <= (clk_period)/(POINTS * frec_reg);	
		actualizar_clock_count <= 0; end

	if(!reset)
		counter <= 0;
	else if (enable)
		counter <= (counter==(clock_count-1))? 0: counter+1;
		
	sinc = (counter > half_clock_count);
	
end


endmodule