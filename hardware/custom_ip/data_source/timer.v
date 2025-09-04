/* ==========================================================================
 * ============================ TIMER =======================================
 *  Descripción general:
 *    Este módulo genera una señal tipo "sinc" con una frecuencia deseada
 *    a partir de un reloj de entrada. La frecuencia de salida se ajusta
 *    dinámicamente según la entrada `frecuencia_deseada`.
 *
 *  Entradas:
 *    - clk: reloj base del sistema.
 *    - reset: resetea el contador y la salida.
 *    - enable: habilita la generación de la señal sinc.
 *    - frecuencia_deseada: frecuencia objetivo de la señal de salida.
 *
 *  Salidas:
 *    - sinc: señal periódica con ciclo de trabajo aproximadamente 50%.
 *
 *  Funcionamiento:
 *    1. La frecuencia deseada se almacena en un registro interno.
 *    2. Se calcula el número de ciclos del reloj base necesarios para
 *       generar un periodo de la señal de salida (`clock_count`).
 *    3. Un contador incrementa en cada flanco de reloj habilitado.
 *    4. La salida `sinc` se activa cuando el contador supera la mitad del
 *       periodo (`half_clock_count`) para mantener un ciclo de trabajo ~50%.
 *
 *  Observaciones:
 *    - Permite cambiar la frecuencia de salida dinámicamente.
 *    - Ideal para generar triggers o relojes lentos a partir de un PLL rápido.
 * ========================================================================== */

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