/* ==========================================================================
 * ============================ CLOCK DIVIDER ===============================
 *  Descripción general:
 *    Este módulo genera un clock de salida a partir de un clock de entrada,
 *    dividiendo su frecuencia por un valor configurable. Permite bypass cuando
 *    el divisor es 1, de modo que la señal de entrada se transmite directamente.
 *
 *  Entradas:
 *    - clock_in: reloj base a dividir.
 *    - divisor: valor de división (16 bits). Si divisor = 1, no se divide.
 *
 *  Salidas:
 *    - clock_out: reloj resultante dividido.
 *
 *  Funcionamiento:
 *    1. Se almacena el divisor en un registro sincrónico.
 *    2. Se evalúa un bypass si el divisor <= 1.
 *    3. Un contador incremental genera la señal de salida con un ciclo
 *       de trabajo aproximado de 50% (clock_generado cambia de 0 a 1 a la mitad
 *       del periodo definido por divisor).
 *    4. Si bypass está activo, clock_out sigue a clock_in; de lo contrario,
 *       sigue a clock_generado.
 *
 *  Observaciones:
 *    - El ciclo de trabajo es exacto cuando divisor es par; si es impar,
 *      el ciclo de alto/bajo puede variar ligeramente.
 *    - Ideal para generar clocks de baja frecuencia desde un PLL o reloj rápido.
 * ========================================================================== */
 
module Clock_divider
(
input clock_in,
input [15:0] divisor,
output clock_out
);

reg [15:0] divisor_reg;
	always @ (posedge clock_in)	divisor_reg <= divisor ;
	
reg clock_generado,bypass;

always @ (posedge clock_in)
	bypass <= (divisor_reg > 1)? 1'b0 : 1'b1 ;
		
assign clock_out = (bypass == 1'b1) ? clock_in : clock_generado;

reg[15:0] counter=16'd0;


always @(posedge clock_in)
begin

 counter <= counter + 16'd1;
 
 if(counter >= (divisor_reg-1))
	counter <= 16'd0;

	clock_generado <= (counter < (divisor_reg >> 1))? 1'b0 : 1'b1 ;

end
endmodule