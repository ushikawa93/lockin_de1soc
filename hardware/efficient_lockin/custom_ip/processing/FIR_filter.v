
module FIR_filter (

	input clk,
	input reset_n,
	input enable,
	input bypass,
	
	input [31:0] coef_0,
	input [31:0] coef_1,
	input [31:0] coef_2,
	input [31:0] coef_3,
	input [31:0] coef_4,
	input [31:0] coef_5,
	input [31:0] coef_6,
	input [31:0] coef_7,
	input [31:0] coef_8,
	input [31:0] coef_9,
	input [31:0] coef_10,
	input [31:0] coef_11,
	input [31:0] coef_12,
	input [31:0] coef_13,
	input [31:0] coef_14,
	input [31:0] coef_15,
	input [31:0] coef_16,
	input [31:0] coef_17,
	input [31:0] coef_18,
	input [31:0] coef_19,
	input [31:0] coef_20,
	input [31:0] coef_21,
	input [31:0] coef_22,
	input [31:0] coef_23,
	input [31:0] coef_24,
	input [31:0] coef_25,
	input [31:0] coef_26,
	input [31:0] coef_27,
	input [31:0] coef_28,
	input [31:0] coef_29,
	input [31:0] coef_30,
	input [31:0] coef_31,
	input [31:0] coef_32,

	input signed [31:0] data_in,
	input data_in_valid,
	
	output signed [31:0] data_out,
	output data_out_valid


);

parameter N = 32;

reg signed [31:0] coef [0:N];
reg signed [31:0] x [0:N];
integer i;
reg data_valid_reg;

reg signed [31:0] y,y_0,y_10,y_20,y_30;

always @ (posedge clk)
begin

	if (!reset_n)
	begin
	
		for (i = 0; i<= N; i = i+1)
		begin
			x[i]=0;		
		end
		
		coef[0] <= coef_0;
		coef[1] <= coef_1;
		coef[2] <= coef_2;
		coef[3] <= coef_3;
		coef[4] <= coef_4;
		coef[5] <= coef_5;
		coef[6] <= coef_6;
		coef[7] <= coef_7;
		coef[8] <= coef_8;		
		coef[9] <= coef_9;
		
		coef[10] <= coef_10;
		coef[11] <= coef_11;
		coef[12] <= coef_12;
		coef[13] <= coef_13;
		coef[14] <= coef_14;
		coef[15] <= coef_15;
		coef[16] <= coef_16;
		coef[17] <= coef_17;		
		coef[18] <= coef_18;
		coef[19] <= coef_19;
		
		coef[20] <= coef_20;
		coef[21] <= coef_21;
		coef[22] <= coef_22;
		coef[23] <= coef_23;
		coef[24] <= coef_24;
		coef[25] <= coef_25;
		coef[26] <= coef_26;
		coef[27] <= coef_27;
		coef[28] <= coef_28;
		coef[29] <= coef_29;
		
		coef[30] <= coef_30;
		coef[31] <= coef_31;
		coef[32] <= coef_32;
		
		y <= 0;
		y_0 <= 0;
		y_10 <= 0;
		y_20 <= 0;
		y_30 <= 0;

		data_valid_reg <= 0;
		
		
			
	end
	
	else if (enable)
	begin 
		
		if(data_in_valid)
		begin
		
			x[0] <= data_in;
		
			for (i = 0; i< N; i = i+1)
			begin
				x[i+1] <= x[i];					
			end

			y_0 <= coef[0] * x[0] +  coef[1] * x[1] +  coef[2] * x[2] +  coef[3] * x[3] +  coef[4] * x[4] +  coef[5] * x[5] +  coef[6] * x[6] +  coef[7] * x[7] +  coef[8] * x[8] +  coef[9] * x[9];  
			y_10 <= coef[10] * x[10] +  coef[11] * x[11] +  coef[12] * x[12] +  coef[13] * x[13] +  coef[14] * x[14] +  coef[15] * x[15] +  coef[16] * x[16] +  coef[17] * x[17] +  coef[18] * x[18] +  coef[19] * x[19];  
			y_20 <= coef[20] * x[20] +  coef[21] * x[21] +  coef[22] * x[22] +  coef[23] * x[23] +  coef[24] * x[24] +  coef[25] * x[25] +  coef[26] * x[26] +  coef[27] * x[27] +  coef[28] * x[28] +  coef[29] * x[29];  
			y_30 <= coef[30] * x[30] +  coef[31] * x[31] +  coef[32] * x[32];

			y <= y_0 + y_10 + y_20 + y_30;

			data_valid_reg <= 1;
		
		end
		else
			data_valid_reg <= 0;
	end

end


assign data_out = (bypass == 0) ?  y >>> 16: data_in;  //y >> 16 : data_in;
assign data_out_valid = (bypass == 0) ? data_valid_reg : data_in_valid;

endmodule
