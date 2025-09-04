/* ==========================================================================
 * ============================ MULTIPLICATE_REF_2 ===========================
 *  Descripción general:
 *    Este módulo multiplica una señal de entrada por sus referencias 
 *    seno y coseno obtenidas de la ROM de referencias, produciendo las 
 *    componentes de fase y cuadratura en streaming.
 *
 *  Entradas:
 *    - clock: reloj del sistema.
 *    - reset_n: reset activo en bajo.
 *    - enable: habilita la operación de multiplicación.
 *    - ptos_x_ciclo: cantidad de puntos por ciclo de señal, usado para 
 *      calcular la referencia correcta.
 *    - data: señal de entrada a multiplicar (signed 32 bits).
 *    - data_valid: indica que `data` es válida.
 *
 *  Salidas:
 *    - data_out_seno: resultado de multiplicar `data` por la referencia seno.
 *    - data_out_coseno: resultado de multiplicar `data` por la referencia coseno.
 *    - data_valid_multiplicacion: indica que las salidas son válidas.
 *
 *  Funcionamiento:
 *    1. Se leen las referencias seno y coseno desde el módulo `referencias`.
 *    2. La señal de entrada `data` se multiplica por cada referencia.
 *    3. La salida de fase (`data_out_seno`) y cuadratura (`data_out_coseno`) se
 *       generan en streaming junto con la señal de validación.
 *    4. Por el momento, la multiplicación para la cuadratura está comentada y
 *       `data_out_coseno` entrega directamente la referencia seno.
 *
 *  Observaciones:
 *    - Está diseñado para integrarse con módulos Lock-In o filtros posteriores.
 *    - Se recomienda habilitar `enable` para que el pipeline de multiplicación funcione.
 * ========================================================================== */

module multiplicate_ref_2(

	// Entradas de control
	input clock,
	input reset_n,
	input enable,
	
	// Parametros de configuracion
	input [15:0] ptos_x_ciclo,
	
	// Referencia externa
	input referencia_externa,
	input sync,
	input signed [31:0] referencia_externa_sen,
	input signed [31:0] referencia_externa_cos,
	input referencia_externa_valid,
	
	// Entrada avalon streaming
	input signed [31:0] data,	
	input data_valid,	
		
	// Salidas avalon streaming 
	output signed [63:0] data_out_seno,
	output signed [63:0] data_out_coseno,
	output data_valid_multiplicacion	

);

wire signed [31:0] ref_seno_int;
wire signed [31:0] ref_cos_int;

referencias ref(

	// Entradas de control
	.clock(clock),
	.reset_n(reset_n),
	.enable(enable),
	
	// Parametro configurable
	.pts_x_ciclo(ptos_x_ciclo),

	// Entrada de sincronizacion
	.avanzar_en_tabla(data_valid),
	
	.data_out_seno(ref_seno_int),
	.data_out_cos(ref_cos_int)
	
);

wire signed [31:0] ref_seno = (referencia_externa)? referencia_externa_sen:ref_seno_int;
wire signed [31:0] ref_cos = (referencia_externa)? referencia_externa_cos:ref_cos_int;


wire data_valid_seno,data_valid_cos;


multiplicador prod_fase(

	// Entradas de control
	.clock(clock),
	.reset_n(reset_n),
	.enable(enable),
	
	// Entrada avalon streaming
	.data_a(data),
	.data_b(ref_seno),
	.data_valid(data_valid),	
		
	// Salidas avalon streaming 
	.data_out(data_out_seno),
	.data_valid_multiplicacion(data_valid_seno)	

);


multiplicador prod_cuadratura(

	// Entradas de control
	.clock(clock),
	.reset_n(reset_n),
	.enable(enable),
	
	// Entrada avalon streaming
	.data_a(data),
	.data_b(ref_cos),
	.data_valid(data_valid),	
		
	// Salidas avalon streaming 
	.data_out(data_out_coseno),
	.data_valid_multiplicacion(data_valid_cos)	


);


assign data_valid_multiplicacion = data_valid_seno && data_valid_cos;


endmodule

