/* ==========================================================================
 * ============================ MULTIPLICATE_REF ============================
 *  Descripción general:
 *    Este módulo multiplica una señal de entrada por sus referencias 
 *    seno y coseno almacenadas en tablas (LU tables), generando las 
 *    componentes de fase y cuadratura en streaming.
 *
 *  Entradas:
 *    - clock: reloj del sistema.
 *    - reset: reset activo en bajo.
 *    - enable: habilita la operación del módulo.
 *    - ptos_x_ciclo: cantidad de puntos por ciclo de señal, usado para 
 *      calcular correctamente los índices de las referencias.
 *    - data: señal de entrada a multiplicar (signed 32 bits).
 *    - data_valid: indica que `data` es válida.
 *
 *  Salidas:
 *    - data_out_seno: resultado de multiplicar `data` por la referencia seno.
 *    - data_out_coseno: resultado de multiplicar `data` por la referencia coseno.
 *    - data_valid_multiplicacion: indica que las salidas son válidas.
 *
 *  Funcionamiento:
 *    1. Se leen las referencias seno y coseno desde las tablas `ref_sen` y `ref_cos`.
 *    2. La señal de entrada se registra en varias etapas para sincronización.
 *    3. Se calculan los productos `data*ref_seno` y `data*ref_cos`.
 *    4. Se generan las salidas en streaming junto con la señal de validación.
 *
 *  Observaciones:
 *    - Se implementa en pipeline de 4 etapas para mejorar el timing.
 *    - `data_valid_multiplicacion` se genera solo cuando todas las etapas han procesado la entrada.
 * ========================================================================== */


module multiplicate_ref(

	// Entradas de control
	input clock,
	input reset_n,
	input enable,
	
	// Parametros de configuracion
	input [15:0] ptos_x_ciclo,
	
	// Entrada avalon streaming
	input signed [31:0] data,	
	input data_valid,	
		
	// Salidas avalon streaming 
	output reg signed [63:0] data_out_seno,
	output reg signed [63:0] data_out_coseno,
	output reg data_valid_multiplicacion	

);

//=======================================================
// Parametros de configuracion de los módulos
//=======================================================

parameter ref_mean_value = 32767;
wire [15:0] M = ptos_x_ciclo;				// Puntos por ciclo de señal

//=======================================================
// Reg/Wire declarations
//=======================================================

// Referencias seno y coseno en sendas LU table
reg [15:0]  ref_sen   [0:2047];	initial	$readmemh("LU_Tables/x2048_16b.mem",ref_sen);
reg [15:0] 	ref_cos   [0:2047];	initial	$readmemh("LU_Tables/y2048_16b.mem",ref_cos);

// Reg/Wire declarations 
reg [15:0] index_ref,index_ref_2;

reg signed [63:0] data_in_2_etapa;
reg signed [63:0] data_in_3_etapa;
reg signed [63:0] ref_fase_actual;
reg signed [63:0] ref_cuad_actual;

reg signed [63:0] prod_fase;
reg signed [63:0] prod_cuad;

reg data_valid_1,data_valid_2,data_valid_3;


reg [15:0] interval;
	always @ (posedge clock) interval = 2048/M; // Para poder cambiar el largo de la secuencia sin tener que leer otro archivo
	

// Registro las entradas... es mas prolijo trabajar con las entradas registradas
reg signed [31:0] data_in_reg; always @ (posedge clock) data_in_reg <= (!reset_n)? 0: data;
reg data_valid_reg; always @ (posedge clock) data_valid_reg <= (!reset_n)? 0: data_valid;


//=======================================================
// Algoritmo principal
//=======================================================

always @ (posedge clock or negedge reset_n)
begin
	
	if(!reset_n)
	begin		
	
		data_in_2_etapa<=0;
		data_in_3_etapa<=0;		
	
		index_ref<=0;
		index_ref_2<=0;
	
		data_valid_1<=0;
		data_valid_2<=0;
		data_valid_3<=0;	
		
	end
	else if(enable)
	begin
		if(data_valid_reg)
		begin
		
			index_ref <= (index_ref == (M-1))? 0: index_ref+1;
		
			//calcular indice de la referencia (1 etapa)
			
				index_ref_2 <= index_ref*interval;	
				data_in_2_etapa <= data_in_reg;		
				data_valid_1 <= 1;	
			
			//registrar dato entrante (2 etapa)
				
				ref_fase_actual <= ref_sen[index_ref_2]-ref_mean_value;
				ref_cuad_actual <= ref_cos[index_ref_2]-ref_mean_value;
				
				data_in_3_etapa <= data_in_2_etapa;
				data_valid_2 <= data_valid_1;
						

			//registrar productos (3 etapa)
			
				prod_fase <= data_in_3_etapa * ref_fase_actual;
				prod_cuad <= data_in_3_etapa * ref_cuad_actual;
				data_valid_3 <= data_valid_2;
				
			//registrar salidas (4 etapa)
			
				data_out_seno <= prod_fase;
				data_out_coseno <= prod_cuad;
				
		end
	end
end

always @ (posedge clock)
	data_valid_multiplicacion <= (data_valid_reg && data_valid_3);




endmodule
