/* ==========================================================================
 * ============================ GCL =========================================
 *  Descripción general:
 *    Este módulo implementa un Generador Congruencial Lineal (GCL) para
 *    producir números pseudoaleatorios de 32 bits. La salida se entrega
 *    en 64 bits por compatibilidad y se acompaña de una señal de validez.
 *
 *  Entradas:
 *    - i_Clk: reloj principal de operación.
 *    - i_Enable: habilita la generación de datos.
 *    - i_seed: semilla inicial para la generación de números aleatorios.
 *
 *  Salidas:
 *    - o_Data: número pseudoaleatorio generado (64 bits, menor de 32 bits
 *              efectivo en los bits menos significativos).
 *    - o_Data_valid: indica cuando la salida `o_Data` es válida.
 *
 *  Funcionamiento:
 *    1. Se registra la semilla de entrada al activarse `i_Enable`.
 *    2. Se realiza la multiplicación lineal y se atrasa la señal de validez.
 *    3. Se suma la constante `c` y se aplica la operación módulo `m` para
 *       generar el siguiente número pseudoaleatorio.
 *    4. La señal de validez se propaga con tres ciclos de retardo para
 *       sincronizar con los cálculos internos.
 *
 *  Observaciones:
 *    - Parámetros típicos: m = 2^32, a = 69069, c = 1.
 *    - Adecuado para generar ruido en simulaciones de sistemas digitales.
 * ========================================================================== */

module GCL(
	input i_Clk,
	input i_Enable,
	input [31:0] i_seed,
	
	output reg [63:0] o_Data,
	output reg o_Data_valid
	);
	
	reg data_valid_1; initial data_valid_1 = 0;
	reg data_valid_2; initial data_valid_2 = 0;
	reg data_valid_3; initial data_valid_3 = 0;
	
	reg [32:0] reg_seed;
	
	parameter [32:0] m = 2 ** 32;
	parameter [32:0] a = 69069;
	parameter [32:0] c = 1;
	
	
	reg [63:0] reg_mult;
	reg [63:0] reg_suma;
		
   initial o_Data = 0;
   always @ (posedge i_Clk)
   if(i_Enable)
	begin
		
		// Registro entradas 
		reg_seed <= i_seed;
		data_valid_1 <= 1;
		
		// Calculo multiplicacion y pospongo entradas
		reg_mult <= a * reg_seed;
		data_valid_2 <= data_valid_1;
		
		// Calculo suma y pospongo entradas
		reg_suma <= reg_mult + c;
		data_valid_3 <= data_valid_2;
		
		// Calculo Salida
		o_Data <= reg_suma % m;
		o_Data_valid <= data_valid_3;
	end
	else
	begin
		data_valid_1 <= 0;
		data_valid_2 <= 0;
		data_valid_3 <= 0;
		o_Data_valid <= 0;
	end
		
	
	
endmodule