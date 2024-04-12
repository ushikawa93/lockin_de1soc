
module remove_mean_value(
input clock,
input reset,
input [15:0] data_in,
input CE,

output signed [31:0] data_out,
output reg data_valid
);

wire [31:0] read_data;
reg signed [31:0] data_reg;
reg write_ram_en;
reg [5:0] index; initial index=0;

single_port_ram data_mem(
	.data(data_in),
	.addr(index),
	.we(write_ram_en),
	.clk(clock),
	.q(read_data)
);

parameter M=31; 

reg [31:0] acumulador; initial acumulador=0;

reg [1:0] state; parameter init=0,esperar=1, act_tabla=2, act_salida=3; initial state = init;

assign data_out = data_reg - (acumulador >> 5);


always @ (posedge clock)
begin

	if(reset)
		state <= init;

	case(state)
	init:
	begin
		acumulador <= 0;
		index <= 0;
		data_reg <= 0;
		state <= esperar;
	end
	
	esperar:
	begin
		data_valid <= 0;
		if(CE)
		begin 
			write_ram_en <= 1;
			acumulador <= acumulador - read_data;
			data_reg <= data_in;
			state <= act_tabla;	
		end 
	end
		
	act_tabla:
	begin
		write_ram_en <= 0;
		state <= act_salida;			
	end
	
	act_salida:
	begin
		data_valid <= 1;
		acumulador <= acumulador + read_data;		
		index <= (index== M)? 0: index+1;
		state <= esperar;
	end
	
	endcase
	
	
end

endmodule
