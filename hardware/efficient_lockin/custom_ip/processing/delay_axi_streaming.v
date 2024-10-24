

module delay_axi_streaming #(	
	parameter delay = 2,
	parameter width = 32
)
(

    input clk,
    input reset_n,
    input bypass,

    input [width-1:0] data_in,
    input data_in_valid,
    
    output [width-1:0] data_out,
    output data_out_valid
    
);

reg [width-1:0] data_reg [delay-1:0];
reg data_valid_reg [delay-1:0];
integer i;

always @ (posedge clk)
begin
    
    data_reg[0] <= data_in;
    data_valid_reg[0] <= data_in_valid;
    
	 
	 for (i = 0; (i < delay-1) ; i = i + 1) begin
			data_reg[i+1] <= data_reg[i];
			data_valid_reg[i+1] <= data_valid_reg[i];    
	 end
	
	
end

assign data_out = (bypass)? data_in : data_reg[delay-1];
assign data_out_valid = (bypass)? data_in_valid : data_valid_reg[delay-1];

endmodule
