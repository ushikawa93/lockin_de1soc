/* ==========================================================================
 * ============================== LOCKIN ====================================
 *  Descripción general:
 *    Este módulo implementa un Lock-in amplifier digital simple para una
 *    señal de entrada en streaming. Calcula las componentes en fase y
 *    cuadratura mediante multiplicación por referencias seno y coseno
 *    almacenadas en ROM, y un esquema de acumulación tipo FIFO circular.
 *
 *  Entradas:
 *    - clock: reloj del sistema.
 *    - reset: reset síncrono.
 *    - CE: enable de entrada para procesar el dato.
 *    - data: señal de entrada (signed 32 bits).
 *
 *  Salidas:
 *    - data_out_fase: componente en fase acumulada (signed 32 bits).
 *    - data_valid_fase: indica que data_out_fase es válida.
 *    - data_out_cuad: componente en cuadratura acumulada (signed 32 bits).
 *    - data_valid_cuad: indica que data_out_cuad es válida.
 *
 *  Funcionamiento:
 *    1. La señal de entrada se multiplica por la referencia seno y coseno
 *       correspondiente según el índice de la tabla de ROM.
 *    2. Los productos se almacenan en RAM de puerto simple para poder restar
 *       la contribución anterior y sumar la nueva, implementando un filtro
 *       pasabajo tipo moving average de largo M+1.
 *    3. La salida de fase y cuadratura se actualiza en cada ciclo válido.
 *    4. El índice de la tabla de referencia se incrementa de manera circular.
 *
 *  Observaciones:
 *    - Se utiliza un FSM con 6 estados para pipeline: init, esperar,
 *      multiplicar, restar_anterior, sumar_nuevo y act_salida.
 *    - Las tablas de referencia se cargan mediante $readmemh desde ROM.
 *    - Este módulo es adecuado para longitudes de ventana fijas y relativamente
 *      pequeñas (M=31 por defecto).
 * ========================================================================== */

module lockin

	#(parameter Q_in = 12,
	  parameter M = 32,
     parameter N = 4,
	  parameter ref_mean_value = 32767,
	  parameter Q_productos = 32,
	  parameter Q_sumas = 32)
	
	( input clk,
	  input reset_n,
	
	  input [Q_in-1:0] x,
	  input x_valid,
	
	  output signed [Q_sumas-1:0] data_out_fase,
	  output signed [Q_sumas-1:0] data_out_cuad,
	  output data_out_valid

);





reg [15:0] ref_sen [0:M-1];
	initial	$readmemh("LU_tables/x32_16b.mem",ref_sen);

reg [15:0] ref_cos [0:M-1];
	initial	$readmemh("LU_tables/y32_16b.mem",ref_cos);
	
reg signed [Q_productos-1:0] ref_sen_actual;
reg signed [Q_productos-1:0] ref_cos_actual;

reg [7:0] n,n_1,n_2,k;

reg signed [Q_productos-1:0] prod_fase,prod_cuad;
reg signed [Q_sumas-1:0] acum_fase,acum_cuad;

reg [Q_productos-1:0] x_1;
reg x_valid_1,x_valid_2;

wire done_calculating;
	
always @ (posedge clk or negedge reset_n)
begin

	if (!reset_n)
	begin
		
		n <= 0;
		n_1 <= 0;
		n_2 <= 0;
		
		k <= 0;
		x_1 <= 0;
		
		acum_fase <= 0;
		acum_cuad <= 0;
		
		prod_fase <= 0;
		prod_cuad <= 0;
		
		ref_sen_actual <= 0;
		ref_cos_actual <= 0;
		
		x_valid_1 <= 0;
		x_valid_2 <= 0;
	
	end
	
	else if ((x_valid ) && !done_calculating)
	begin
	
		ref_sen_actual <= ref_sen [n] - ref_mean_value;
		ref_cos_actual <= ref_cos [n] - ref_mean_value;
		x_1 <= x;
		n <= (n == M-1)? 0:n+1;
		x_valid_1 <= x_valid;
		
		prod_fase <= x_1 * ref_sen_actual;
		prod_cuad <= x_1 * ref_cos_actual;
		n_1 <= n;
		x_valid_2 <= x_valid_1;
		
		acum_fase <= acum_fase + prod_fase;
		acum_cuad <= acum_cuad + prod_cuad;
		n_2 <= n_1;

		
		k <= (n_2 == M-1)? k+1:k;
		
	
	end

end

assign done_calculating = (k == N);

assign data_out_fase = acum_fase;
assign data_out_cuad = acum_cuad;

assign data_out_valid = done_calculating;

endmodule

