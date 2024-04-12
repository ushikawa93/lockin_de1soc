
module procesador (
	clk_clk,
	clk_custom_in_clk,
	clk_custom_out_clk,
	divisor_clock_export,
	enable_export,
	fifo0_32_bit_in_valid,
	fifo0_32_bit_in_data,
	fifo0_32_bit_in_ready,
	fifo0_64_bit_down_in_valid,
	fifo0_64_bit_down_in_data,
	fifo0_64_bit_down_in_ready,
	fifo0_64_bit_up_in_valid,
	fifo0_64_bit_up_in_data,
	fifo0_64_bit_up_in_ready,
	fifo1_32_bit_in_valid,
	fifo1_32_bit_in_data,
	fifo1_32_bit_in_ready,
	fifo1_64_bit_down_in_valid,
	fifo1_64_bit_down_in_data,
	fifo1_64_bit_down_in_ready,
	fifo1_64_bit_up_in_valid,
	fifo1_64_bit_up_in_data,
	fifo1_64_bit_up_in_ready,
	finalizacion_export,
	memory_mem_a,
	memory_mem_ba,
	memory_mem_ck,
	memory_mem_ck_n,
	memory_mem_cke,
	memory_mem_cs_n,
	memory_mem_ras_n,
	memory_mem_cas_n,
	memory_mem_we_n,
	memory_mem_reset_n,
	memory_mem_dq,
	memory_mem_dqs,
	memory_mem_dqs_n,
	memory_mem_odt,
	memory_mem_dm,
	memory_oct_rzqin,
	parameters_1_user_interface_dataout_0,
	parameters_1_user_interface_dataout_1,
	parameters_1_user_interface_dataout_2,
	parameters_1_user_interface_dataout_3,
	parameters_1_user_interface_dataout_4,
	parameters_1_user_interface_dataout_5,
	parameters_1_user_interface_dataout_6,
	parameters_1_user_interface_dataout_7,
	parameters_1_user_interface_dataout_8,
	parameters_1_user_interface_dataout_9,
	parameters_1_user_interface_datain_10,
	parameters_1_user_interface_datain_11,
	parameters_1_user_interface_datain_12,
	parameters_1_user_interface_datain_13,
	parameters_1_user_interface_datain_14,
	parameters_1_user_interface_datain_15,
	parameters_2_user_interface_dataout_0,
	parameters_2_user_interface_dataout_1,
	parameters_2_user_interface_dataout_2,
	parameters_2_user_interface_dataout_3,
	parameters_2_user_interface_dataout_4,
	parameters_2_user_interface_dataout_5,
	parameters_2_user_interface_dataout_6,
	parameters_2_user_interface_dataout_7,
	parameters_2_user_interface_dataout_8,
	parameters_2_user_interface_dataout_9,
	parameters_2_user_interface_datain_10,
	parameters_2_user_interface_datain_11,
	parameters_2_user_interface_datain_12,
	parameters_2_user_interface_datain_13,
	parameters_2_user_interface_datain_14,
	parameters_2_user_interface_datain_15,
	parameters_3_user_interface_dataout_0,
	parameters_3_user_interface_dataout_1,
	parameters_3_user_interface_dataout_2,
	parameters_3_user_interface_dataout_3,
	parameters_3_user_interface_dataout_4,
	parameters_3_user_interface_dataout_5,
	parameters_3_user_interface_dataout_6,
	parameters_3_user_interface_dataout_7,
	parameters_3_user_interface_dataout_8,
	parameters_3_user_interface_dataout_9,
	parameters_3_user_interface_datain_10,
	parameters_3_user_interface_datain_11,
	parameters_3_user_interface_datain_12,
	parameters_3_user_interface_datain_13,
	parameters_3_user_interface_datain_14,
	parameters_3_user_interface_datain_15,
	parameters_user_interface_dataout_0,
	parameters_user_interface_dataout_1,
	parameters_user_interface_dataout_2,
	parameters_user_interface_dataout_3,
	parameters_user_interface_dataout_4,
	parameters_user_interface_dataout_5,
	parameters_user_interface_dataout_6,
	parameters_user_interface_dataout_7,
	parameters_user_interface_dataout_8,
	parameters_user_interface_dataout_9,
	parameters_user_interface_datain_10,
	parameters_user_interface_datain_11,
	parameters_user_interface_datain_12,
	parameters_user_interface_datain_13,
	parameters_user_interface_datain_14,
	parameters_user_interface_datain_15,
	reset_reset_n,
	reset_fifos_reset,
	reset_op_export,
	result0_32_bit_in_export,
	result0_64_bit_down_in_export,
	result0_64_bit_up_in_export,
	result1_32_bit_in_export,
	result1_64_bit_down_in_export,
	result1_64_bit_up_in_export);	

	input		clk_clk;
	input		clk_custom_in_clk;
	output		clk_custom_out_clk;
	output	[31:0]	divisor_clock_export;
	output		enable_export;
	input		fifo0_32_bit_in_valid;
	input	[31:0]	fifo0_32_bit_in_data;
	output		fifo0_32_bit_in_ready;
	input		fifo0_64_bit_down_in_valid;
	input	[31:0]	fifo0_64_bit_down_in_data;
	output		fifo0_64_bit_down_in_ready;
	input		fifo0_64_bit_up_in_valid;
	input	[31:0]	fifo0_64_bit_up_in_data;
	output		fifo0_64_bit_up_in_ready;
	input		fifo1_32_bit_in_valid;
	input	[31:0]	fifo1_32_bit_in_data;
	output		fifo1_32_bit_in_ready;
	input		fifo1_64_bit_down_in_valid;
	input	[31:0]	fifo1_64_bit_down_in_data;
	output		fifo1_64_bit_down_in_ready;
	input		fifo1_64_bit_up_in_valid;
	input	[31:0]	fifo1_64_bit_up_in_data;
	output		fifo1_64_bit_up_in_ready;
	input		finalizacion_export;
	output	[12:0]	memory_mem_a;
	output	[2:0]	memory_mem_ba;
	output		memory_mem_ck;
	output		memory_mem_ck_n;
	output		memory_mem_cke;
	output		memory_mem_cs_n;
	output		memory_mem_ras_n;
	output		memory_mem_cas_n;
	output		memory_mem_we_n;
	output		memory_mem_reset_n;
	inout	[7:0]	memory_mem_dq;
	inout		memory_mem_dqs;
	inout		memory_mem_dqs_n;
	output		memory_mem_odt;
	output		memory_mem_dm;
	input		memory_oct_rzqin;
	output	[31:0]	parameters_1_user_interface_dataout_0;
	output	[31:0]	parameters_1_user_interface_dataout_1;
	output	[31:0]	parameters_1_user_interface_dataout_2;
	output	[31:0]	parameters_1_user_interface_dataout_3;
	output	[31:0]	parameters_1_user_interface_dataout_4;
	output	[31:0]	parameters_1_user_interface_dataout_5;
	output	[31:0]	parameters_1_user_interface_dataout_6;
	output	[31:0]	parameters_1_user_interface_dataout_7;
	output	[31:0]	parameters_1_user_interface_dataout_8;
	output	[31:0]	parameters_1_user_interface_dataout_9;
	input	[31:0]	parameters_1_user_interface_datain_10;
	input	[31:0]	parameters_1_user_interface_datain_11;
	input	[31:0]	parameters_1_user_interface_datain_12;
	input	[31:0]	parameters_1_user_interface_datain_13;
	input	[31:0]	parameters_1_user_interface_datain_14;
	input	[31:0]	parameters_1_user_interface_datain_15;
	output	[31:0]	parameters_2_user_interface_dataout_0;
	output	[31:0]	parameters_2_user_interface_dataout_1;
	output	[31:0]	parameters_2_user_interface_dataout_2;
	output	[31:0]	parameters_2_user_interface_dataout_3;
	output	[31:0]	parameters_2_user_interface_dataout_4;
	output	[31:0]	parameters_2_user_interface_dataout_5;
	output	[31:0]	parameters_2_user_interface_dataout_6;
	output	[31:0]	parameters_2_user_interface_dataout_7;
	output	[31:0]	parameters_2_user_interface_dataout_8;
	output	[31:0]	parameters_2_user_interface_dataout_9;
	input	[31:0]	parameters_2_user_interface_datain_10;
	input	[31:0]	parameters_2_user_interface_datain_11;
	input	[31:0]	parameters_2_user_interface_datain_12;
	input	[31:0]	parameters_2_user_interface_datain_13;
	input	[31:0]	parameters_2_user_interface_datain_14;
	input	[31:0]	parameters_2_user_interface_datain_15;
	output	[31:0]	parameters_3_user_interface_dataout_0;
	output	[31:0]	parameters_3_user_interface_dataout_1;
	output	[31:0]	parameters_3_user_interface_dataout_2;
	output	[31:0]	parameters_3_user_interface_dataout_3;
	output	[31:0]	parameters_3_user_interface_dataout_4;
	output	[31:0]	parameters_3_user_interface_dataout_5;
	output	[31:0]	parameters_3_user_interface_dataout_6;
	output	[31:0]	parameters_3_user_interface_dataout_7;
	output	[31:0]	parameters_3_user_interface_dataout_8;
	output	[31:0]	parameters_3_user_interface_dataout_9;
	input	[31:0]	parameters_3_user_interface_datain_10;
	input	[31:0]	parameters_3_user_interface_datain_11;
	input	[31:0]	parameters_3_user_interface_datain_12;
	input	[31:0]	parameters_3_user_interface_datain_13;
	input	[31:0]	parameters_3_user_interface_datain_14;
	input	[31:0]	parameters_3_user_interface_datain_15;
	output	[31:0]	parameters_user_interface_dataout_0;
	output	[31:0]	parameters_user_interface_dataout_1;
	output	[31:0]	parameters_user_interface_dataout_2;
	output	[31:0]	parameters_user_interface_dataout_3;
	output	[31:0]	parameters_user_interface_dataout_4;
	output	[31:0]	parameters_user_interface_dataout_5;
	output	[31:0]	parameters_user_interface_dataout_6;
	output	[31:0]	parameters_user_interface_dataout_7;
	output	[31:0]	parameters_user_interface_dataout_8;
	output	[31:0]	parameters_user_interface_dataout_9;
	input	[31:0]	parameters_user_interface_datain_10;
	input	[31:0]	parameters_user_interface_datain_11;
	input	[31:0]	parameters_user_interface_datain_12;
	input	[31:0]	parameters_user_interface_datain_13;
	input	[31:0]	parameters_user_interface_datain_14;
	input	[31:0]	parameters_user_interface_datain_15;
	input		reset_reset_n;
	input		reset_fifos_reset;
	output		reset_op_export;
	input	[31:0]	result0_32_bit_in_export;
	input	[31:0]	result0_64_bit_down_in_export;
	input	[31:0]	result0_64_bit_up_in_export;
	input	[31:0]	result1_32_bit_in_export;
	input	[31:0]	result1_64_bit_down_in_export;
	input	[31:0]	result1_64_bit_up_in_export;
endmodule
