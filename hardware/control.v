/* =========================================================================
 * ====================== Módulo de Control ================================
 *  Descripción general:
 *    Este módulo coordina el funcionamiento de los diferentes bloques del
 *    sistema, incluyendo la lógica de procesamiento, el NIOS/HPS y la
 *    interfaz con memoria DDR3. Controla el enable general, el reset, y
 *    genera el clock custom a partir del PLL y un divisor.
 *
 *  Señales principales:
 *    - clk, reset_n: reloj principal y reset síncrono.
 *    - enable, clk_custom, reset_from_control: señales de control hacia otros
 *      módulos.
 *    - result_?_64_bit, result_?_32_bit y sus flags valid: resultados de
 *      procesamiento de 64 y 32 bits.
 *    - parameter_in_0 .. parameter_in_4: parámetros recibidos desde la lógica
 *      hacia el sistema de control.
 *    - parameter_out_0 .. parameter_out_39: parámetros enviados desde el
 *      sistema de control hacia la lógica.
 *    - HPS_DDR3_*: interfaz de memoria DDR3 para el HPS.
 *
 *  Funcionamiento:
 *    1. Instancia y configura el QSYS system que incluye NIOS, HPS, FIFOs
 *       y PLL.
 *    2. Gestiona la transferencia de datos entre los módulos de procesamiento
 *       y el sistema de control.
 *    3. Genera un clock custom mediante un divisor para los módulos que lo
 *       requieren.
 *    4. Facilita la configuración de parámetros desde y hacia la lógica
 *       mediante interfaces memory-mapped.
 *
 *  Observaciones:
 *    - La mayor parte de la lógica de control se encuentra dentro del QSYS,
 *      este módulo actúa principalmente como envoltorio y ruteo de señales.
 *    - El divisor de clock externo permite obtener frecuencias menores que
 *      las provistas por el PLL.
 * ========================================================================== */


module control (

	input clk,
	input reset_n,
	
		
	// Logica de control de modulos
	output enable,
	output clk_custom,
	output reset_from_control,
	input  calculo_finalizado,
	
	// Resultados de procesamiento de 64 bits
	input [63:0] result_0_64_bit,
	input result_0_64_bit_valid,
	input [63:0] result_1_64_bit,
	input result_1_64_bit_valid,
	
	// Resultados de procesamiento de 32 bits
	input [31:0] result_0_32_bit,
	input result_0_32_bit_valid,
	input [31:0] result_1_32_bit,
	input result_1_32_bit_valid,
	
	// Parametros desde logica hacia sistema de control
	input [31:0] parameter_in_0,
	input [31:0] parameter_in_1,
	input [31:0] parameter_in_2,
	input [31:0] parameter_in_3,
	input [31:0] parameter_in_4,

	// Parametros desde sistema de control hacia la lógica
	output [31:0] parameter_out_0,
	output [31:0] parameter_out_1,
	output [31:0] parameter_out_2,
	output [31:0] parameter_out_3,
	output [31:0] parameter_out_4,
	output [31:0] parameter_out_5,
	output [31:0] parameter_out_6,
	output [31:0] parameter_out_7,
	output [31:0] parameter_out_8,
	output [31:0] parameter_out_9,

	output [31:0] parameter_out_10,
	output [31:0] parameter_out_11,
	output [31:0] parameter_out_12,
	output [31:0] parameter_out_13,
	output [31:0] parameter_out_14,
	output [31:0] parameter_out_15,
	output [31:0] parameter_out_16,
	output [31:0] parameter_out_17,
	output [31:0] parameter_out_18,
	output [31:0] parameter_out_19,
	
	output [31:0] parameter_out_20,	
	output [31:0] parameter_out_21,
	output [31:0] parameter_out_22,
	output [31:0] parameter_out_23,
	output [31:0] parameter_out_24,
	output [31:0] parameter_out_25,
	output [31:0] parameter_out_26,
	output [31:0] parameter_out_27,
	output [31:0] parameter_out_28,
	output [31:0] parameter_out_29,
	
	output [31:0] parameter_out_30,
	output [31:0] parameter_out_31,
	output [31:0] parameter_out_32,
	output [31:0] parameter_out_33,
	output [31:0] parameter_out_34,
	output [31:0] parameter_out_35,
	output [31:0] parameter_out_36,
	output [31:0] parameter_out_37,
	output [31:0] parameter_out_38,
	output [31:0] parameter_out_39,
	
	// Parametros necesarios para el HPS
	//////// HPS ////////////
	output      [14:0] HPS_DDR3_ADDR,
   output      [2:0]  HPS_DDR3_BA,
   output             HPS_DDR3_CAS_N,
   output             HPS_DDR3_CKE,
   output             HPS_DDR3_CK_N,
   output             HPS_DDR3_CK_P,
   output             HPS_DDR3_CS_N,
   output      [3:0]  HPS_DDR3_DM,
   inout       [31:0] HPS_DDR3_DQ,
   inout       [3:0]  HPS_DDR3_DQS_N,
   inout       [3:0]  HPS_DDR3_DQS_P,
   output             HPS_DDR3_ODT,
   output             HPS_DDR3_RAS_N,
   output             HPS_DDR3_RESET_N,
   input              HPS_DDR3_RZQ,
   output             HPS_DDR3_WE_N
	
);

// Custom clock afectado por el PLL y el divisor del reloj
assign clk_custom = clk_post_divisor;

wire reset_from_control_reg,enable_wire;
assign reset_from_control = reset_from_control_reg;


/* =============================================================================================
 * ============================ Qsys system ====================================================
 * La mayor parte del control esta en un QSYS que instancia el NIOS, el HPS, los FIFO y el PLL.
 * Hay tambien un ip que controla los parámetros configurables con un memory mapped.
 * Para que QSYS pueda detectarlo bien tendria que estar en una carpeta ip/
 * ============================================================================================= 
 */


procesador nios2 (
        .clk_clk                             (clk),                             	//                       clk.clk
        .clk_custom_in_clk                   (clk_post_divisor),                 //             clk_custom_in.clk
        .clk_custom_out_clk                  (clk_pre_divisor),                  //            clk_custom_out.clk
        
		  .enable_export                       (enable_wire),                      //                    enable.export
        .divisor_clock_export                (divisor_clk),                 		//             divisor_clock.export
		  .finalizacion_export                 (calculo_finalizado),               //              finalizacion.export
	  
		  .reset_reset_n                       (reset_n),                       	//                     reset.reset_n
        .reset_fifos_reset                   (reset_from_control_reg),           //               reset_fifos.reset
        .reset_op_export                     (reset_from_control_reg),           //                  reset_op.export
       
		  .fifo0_64_bit_down_in_valid          (result_0_64_bit_valid),          //      fifo0_64_bit_down_in.valid
        .fifo0_64_bit_down_in_data           (result_0_64_bit[31:0]),           //                          .data
        .fifo0_64_bit_up_in_valid            (result_0_64_bit_valid),            //        fifo0_64_bit_up_in.valid
        .fifo0_64_bit_up_in_data             (result_0_64_bit[63:32]),             //                          .data
      		
		  .fifo1_64_bit_down_in_valid          (result_1_64_bit_valid),          //      fifo1_64_bit_down_in.valid
        .fifo1_64_bit_down_in_data           (result_1_64_bit[31:0]),           //                          .data
        .fifo1_64_bit_up_in_valid            (result_1_64_bit_valid),            //        fifo1_64_bit_up_in.valid
        .fifo1_64_bit_up_in_data             (result_1_64_bit[63:32]),             //                          .data
        
		  .fifo0_32_bit_in_valid             	(result_0_32_bit_valid),             //         fifo1_32_bit_in_1.valid
        .fifo0_32_bit_in_data              	(result_0_32_bit),              //                          .data
       
		  .fifo1_32_bit_in_valid               (result_1_32_bit_valid),               //           fifo1_32_bit_in.valid
        .fifo1_32_bit_in_data                (result_1_32_bit),                //                          .data
    
		  .result1_64_bit_up_in_export         (result_1_64_bit[63:32]),         //      result1_64_bit_up_in.export
        .result1_64_bit_down_in_export       (result_1_64_bit[31:0]),       //    result1_64_bit_down_in.export
        .result0_64_bit_up_in_export         (result_0_64_bit[63:32]),         //      result0_64_bit_up_in.export
        .result0_64_bit_down_in_export       (result_0_64_bit[31:0]),       //    result0_64_bit_down_in.export
		 
		  .result0_32_bit_in_export            (result_0_32_bit),            //         result0_32_bit_in.export
        .result1_32_bit_in_export            (result_1_32_bit),             //         result1_32_bit_in.export
		  
    
		
		  // Paramteros para configurar cosas desde el NIOS o HPS a la FPGA:
		  .parameters_user_interface_dataout_0 (parameter_out_0), // parameters_user_interface.dataout_0
        .parameters_user_interface_dataout_1 (parameter_out_1), //                          .dataout_1
        .parameters_user_interface_dataout_2 (parameter_out_2), //                          .dataout_2
        .parameters_user_interface_dataout_3 (parameter_out_3), //                          .dataout_3
        .parameters_user_interface_dataout_4 (parameter_out_4), //                          .dataout_4
        .parameters_user_interface_dataout_5 (parameter_out_5), //                          .dataout_5
        .parameters_user_interface_dataout_6 (parameter_out_6), //                          .dataout_6
        .parameters_user_interface_dataout_7 (parameter_out_7), //                          .dataout_7
        .parameters_user_interface_dataout_8 (parameter_out_8), //                          .dataout_8
        .parameters_user_interface_dataout_9 (parameter_out_9), //                          .dataout_9
		  
		  .parameters_1_user_interface_dataout_0 (parameter_out_10), // parameters_1_user_interface.dataout_0
        .parameters_1_user_interface_dataout_1 (parameter_out_11), //                            .dataout_1
        .parameters_1_user_interface_dataout_2 (parameter_out_12), //                            .dataout_2
        .parameters_1_user_interface_dataout_3 (parameter_out_13), //                            .dataout_3
        .parameters_1_user_interface_dataout_4 (parameter_out_14), //                            .dataout_4
        .parameters_1_user_interface_dataout_5 (parameter_out_15), //                            .dataout_5
        .parameters_1_user_interface_dataout_6 (parameter_out_16), //                            .dataout_6
        .parameters_1_user_interface_dataout_7 (parameter_out_17), //                            .dataout_7
        .parameters_1_user_interface_dataout_8 (parameter_out_18), //                            .dataout_8
        .parameters_1_user_interface_dataout_9 (parameter_out_19), //                            .dataout_9
		  
		  .parameters_2_user_interface_dataout_0 (parameter_out_20), // parameters_1_user_interface.dataout_0
        .parameters_2_user_interface_dataout_1 (parameter_out_21), //                            .dataout_1
        .parameters_2_user_interface_dataout_2 (parameter_out_22), //                            .dataout_2
        .parameters_2_user_interface_dataout_3 (parameter_out_23), //                            .dataout_3
        .parameters_2_user_interface_dataout_4 (parameter_out_24), //                            .dataout_4
        .parameters_2_user_interface_dataout_5 (parameter_out_25), //                            .dataout_5
        .parameters_2_user_interface_dataout_6 (parameter_out_26), //                            .dataout_6
        .parameters_2_user_interface_dataout_7 (parameter_out_27), //                            .dataout_7
        .parameters_2_user_interface_dataout_8 (parameter_out_28), //                            .dataout_8
        .parameters_2_user_interface_dataout_9 (parameter_out_29), //                            .dataout_9
		  
		  .parameters_3_user_interface_dataout_0 (parameter_out_30), // parameters_1_user_interface.dataout_0
        .parameters_3_user_interface_dataout_1 (parameter_out_31), //                            .dataout_1
        .parameters_3_user_interface_dataout_2 (parameter_out_32), //                            .dataout_2
        .parameters_3_user_interface_dataout_3 (parameter_out_33), //                            .dataout_3
        .parameters_3_user_interface_dataout_4 (parameter_out_34), //                            .dataout_4
        .parameters_3_user_interface_dataout_5 (parameter_out_35), //                            .dataout_5
        .parameters_3_user_interface_dataout_6 (parameter_out_36), //                            .dataout_6
        .parameters_3_user_interface_dataout_7 (parameter_out_37), //                            .dataout_7
        .parameters_3_user_interface_dataout_8 (parameter_out_38), //                            .dataout_8
        .parameters_3_user_interface_dataout_9 (parameter_out_39), //                            .dataout_9
       
		  // Salidas opcionales desde la FPGA al NIOS o HPS:
		  .parameters_user_interface_datain_10 (parameter_in_0), //                          .datain_10
		  .parameters_user_interface_datain_11 (parameter_in_1), //                          .datain_11
        .parameters_user_interface_datain_12 (parameter_in_2), //                          .datain_12
        .parameters_user_interface_datain_13 (parameter_in_3), //                          .datain_13
        .parameters_user_interface_datain_14 (parameter_in_4), //                          .datain_14
        .parameters_user_interface_datain_15 (), //                          .datain_15
		  
        .parameters_1_user_interface_datain_10 (), //                          .datain_10
		  .parameters_1_user_interface_datain_11 (), //                          .datain_11
        .parameters_1_user_interface_datain_12 (), //                          .datain_12
        .parameters_1_user_interface_datain_13 (), //                          .datain_13
        .parameters_1_user_interface_datain_14 (), //                          .datain_14
        .parameters_1_user_interface_datain_15 (), //                          .datain_15

        .parameters_2_user_interface_datain_10 (), //                          .datain_10
		  .parameters_2_user_interface_datain_11 (), //                          .datain_11
        .parameters_2_user_interface_datain_12 (), //                          .datain_12
        .parameters_2_user_interface_datain_13 (), //                          .datain_13
        .parameters_2_user_interface_datain_14 (), //                          .datain_14
        .parameters_2_user_interface_datain_15 (), //                          .datain_15
		  
        .parameters_3_user_interface_datain_10 (), //                          .datain_10
		  .parameters_3_user_interface_datain_11 (), //                          .datain_11
        .parameters_3_user_interface_datain_12 (), //                          .datain_12
        .parameters_3_user_interface_datain_13 (), //                          .datain_13
        .parameters_3_user_interface_datain_14 (), //                          .datain_14
        .parameters_3_user_interface_datain_15 (), //                          .datain_15
		  
		  
		  // Cosas para la memoria DDR3 del HPS
		  .memory_mem_a                          (HPS_DDR3_ADDR),                          //          memory.mem_a
		  .memory_mem_ba                         (HPS_DDR3_BA),                         //                .mem_ba
		  .memory_mem_ck                         (HPS_DDR3_CK_P),                         //                .mem_ck
		  .memory_mem_ck_n                       (HPS_DDR3_CK_N),                       //                .mem_ck_n
		  .memory_mem_cke                        (HPS_DDR3_CKE),                        //                .mem_cke
		  .memory_mem_cs_n                       (HPS_DDR3_CS_N),                       //                .mem_cs_n
		  .memory_mem_ras_n                      (HPS_DDR3_RAS_N),                      //                .mem_ras_n
		  .memory_mem_cas_n                      (HPS_DDR3_CAS_N),                      //                .mem_cas_n
		  .memory_mem_we_n                       (HPS_DDR3_WE_N),                       //                .mem_we_n
		  .memory_mem_reset_n                    (HPS_DDR3_RESET_N),                    //                .mem_reset_n
		  .memory_mem_dq                         (HPS_DDR3_DQ),                         //                .mem_dq
		  .memory_mem_dqs                        (HPS_DDR3_DQS_P),                        //                .mem_dqs
		  .memory_mem_dqs_n                      (HPS_DDR3_DQS_N),                      //                .mem_dqs_n
		  .memory_mem_odt                        (HPS_DDR3_ODT),                        //                .mem_odt
	     .memory_mem_dm                         (HPS_DDR3_DM),                         //                .mem_dm
		  .memory_oct_rzqin                      (HPS_DDR3_RZQ)                      //                
      

	 );

reg enable_reg;

always @ (posedge clk_post_divisor)
begin
	enable_reg <= enable_wire;
end
	 
assign enable = enable_reg;
	 	 
/* ================================================================================
 * ============================ Divisor del clock =================================
 * Lo unico externo al QSYS aca es un divisor del clock para lograr frecuencias 
 * mas bajas que las que logra el PLL (1-65 MHz)
 * ================================================================================
 */

wire [31:0] divisor_clk;
wire clk_pre_divisor;
wire clk_post_divisor;

Clock_divider clk_div(

	.clock_in(clk_pre_divisor),
	.clock_out(clk_post_divisor),
	.divisor(divisor_clk)
);

endmodule

