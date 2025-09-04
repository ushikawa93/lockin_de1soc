/* ==========================================================================
 * ========================= LOCKIN_PIPELINED ===============================
 *  Descripción general:
 *    Este módulo implementa un Lock-in amplifier digital con procesamiento
 *    en pipeline. Calcula simultáneamente la componente en fase y en cuadratura
 *    de una señal de entrada mediante multiplicación con referencias seno y 
 *    coseno predefinidas y acumulación de resultados sobre un número configurable
 *    de puntos por ciclo y frames de integración.
 *
 *  Entradas:
 *    - clock: reloj del sistema.
 *    - reset: reset síncrono.
 *    - configuracion: word de 51 bits que define parámetros del Lock-in:
 *        - [0]: origen de datos (1 = simulado, 0 = ADC)
 *        - [8:1]: cantidad de bits de ruido en simulación
 *        - [24:9]: puntos por ciclo de señal
 *        - [32:25]: largo del Lock-in (frames de integración)
 *        - [33]: canal ADC (1 = canal a, 0 = canal b)
 *        - [49:34]: cantidad de ciclos promediados coherentemente
 *    - data_valid: indica que el dato de entrada es válido.
 *    - data: señal de entrada (signed 32 bits)
 *
 *  Salidas:
 *    - data_out_fase: componente en fase acumulada (signed 64 bits)
 *    - data_valid_fase: indica que data_out_fase es válida
 *    - data_out_cuad: componente en cuadratura acumulada (signed 64 bits)
 *    - data_valid_cuad: indica que data_out_cuad es válida
 *    - fifos_llenos: indica que se completó el llenado de los FIFOs internos
 *
 *  Funcionamiento:
 *    1. Al recibir un dato válido, se calcula el índice de referencia según la
 *       configuración de puntos por ciclo y frames de integración.
 *    2. Se multiplican los datos entrantes por las referencias seno y coseno
 *       correspondientes.
 *    3. Los productos se guardan en arreglos circulares y se acumulan mediante
 *       un acumulador tipo FIFO deslizante.
 *    4. Las salidas de fase y cuadratura se actualizan en la última etapa del
 *       pipeline.
 *    5. La señal fifos_llenos indica cuándo se completó el llenado del buffer
 *       interno y se pueden procesar los resultados.
 *
 *  Observaciones:
 *    - Los arrays de referencias se inicializan desde archivos hexadecimales.
 *    - Para inferencia correcta de bloques DSP, algunas señales no se inicializan
 *      explícitamente.
 *    - El pipeline tiene 6 etapas, optimizando el throughput de la operación.
 * ========================================================================== */

module lockin_pipelined(

	input clock,
	input reset,
	
	input [50:0]	 configuracion,
	
	input data_valid,
	input signed [31:0] data,	
		
	output reg signed [63:0] data_out_fase,
	output reg data_valid_fase,
	
	output reg signed [63:0] data_out_cuad,
	output reg data_valid_cuad,
	
	output fifos_llenos
	
);
//=======================================================
// Parametros de configuracion de los módulos
//=======================================================


wire origen_datos = configuracion[0];								// 1 para datos simulados, 0 para adc
wire [7:0] simulation_noise = configuracion[8:1];				// Cantidad de bits de ruido en la simulacion
wire [15:0] ptos_x_ciclo = configuracion[24:9];					// Ctdad de puntos por ciclo de señal
wire [7:0] frames_integracion = configuracion[32:25];			// Largo del Lock In
wire adc_channel = configuracion[33];								// 1 canal a, 0 canal b
wire [15:0] frames_prom_coherente = configuracion[49:34];	// Cantidad de ciclos promediados coherentemente 


//=======================================================
// Reg/Wire declarations
//=======================================================

parameter buf_tam = 2048;					// Con 4096 ya me paso de la cantidad de bloques de ram que hay
parameter ref_mean_value = 32767;
parameter delay=5;

wire [15:0] M = ptos_x_ciclo;				// Puntos por ciclo de señal
wire [7:0] N = frames_integracion;		// Frames de integracion // Largo del lockin M*N	

reg [15:0] interval;
	always @ (posedge clock) interval = 2048/M; // Para poder cambiar el largo de la secuencia sin tener que leer otro archivo
														  						

reg signed [63:0] acum_fase;	// Son un poco mas largos para que no haya overflow
reg signed [63:0] acum_cuad;


// Estos dos los implementa bien como roms asi como estan...
reg [15:0]  ref_sen   [0:2047];	initial	$readmemh("LU_Tables/x2048_16b.mem",ref_sen);
reg [15:0] 	ref_cos   [0:2047];	initial	$readmemh("LU_Tables/y2048_16b.mem",ref_cos);
 
reg [15:0] index_ref,index_ref_2,i,index_lockin;

reg signed [63:0] data_in_2_etapa;
reg signed [63:0] data_in_3_etapa;
reg signed [63:0] data_in_5_etapa_fase;
reg signed [63:0] data_in_5_etapa_cuad;
reg signed [63:0] data_out_5_etapa_fase;
reg signed [63:0] data_out_5_etapa_cuad;

reg signed [63:0] array_prod_fase [0:buf_tam-1];
reg signed [63:0] array_prod_cuad [0:buf_tam-1];


reg signed [63:0] ref_fase_actual;
reg signed [63:0] ref_cuad_actual;

reg habilitar; initial habilitar=1;

// Por algun motivo estos junto con ref_fase_actual y data_in_2_etapa no hay que inicializarlos, e inicializarlos
// hace que no se infieran bien los dsp blocks, asique bueno...
reg signed [63:0] prod_fase;
reg signed [63:0] prod_cuad;

// Registro las entradas... es mas prolijo trabajar con las entradas registradas

reg signed [31:0] data_in_reg; always @ (posedge clock) data_in_reg <= (!reset)? 0: data;
reg signed data_valid_reg; always @ (posedge clock) data_valid_reg <= (!reset)? 0: data_valid;

always @ (posedge clock)
begin
	data_valid_fase <= (data_valid_reg && (habilitar));
	data_valid_cuad <= (data_valid_reg && (habilitar));	
end
	
//=======================================================
// Algoritmo principal
//=======================================================

always @ (posedge clock or negedge reset)
begin

	
	if(!reset)
	begin
		acum_fase<=0;
		acum_cuad<=0;
		
		prod_fase<=0;
		prod_cuad<=0;
		data_in_2_etapa<=0;
		data_in_3_etapa<=0;
		
		data_in_5_etapa_fase<=0;
		data_in_5_etapa_cuad<=0;
		data_out_5_etapa_fase<=0;
		data_out_5_etapa_cuad<=0;
			
		index_ref <= 0; index_lockin <= 0; i=0; index_ref_2<=0;
		habilitar <= 1;		
	end
		
	else if(data_valid_reg && habilitar)
	begin
	
		habilitar <= (index_lockin == ((M*N)-1)+delay)? 0:1; 
		
		index_ref <= (index_ref == (M-1))? 0: index_ref+1;
		index_lockin <= index_lockin + 1;
		
		
		//calcular indice de la referencia (1 etapa)
		
			index_ref_2 <= index_ref*interval;	
			data_in_2_etapa <= data_in_reg;			
		
		//registrar dato entrante (2 etapa)
			
			ref_fase_actual <= ref_sen[index_ref_2]-ref_mean_value;
			ref_cuad_actual <= ref_cos[index_ref_2]-ref_mean_value;
			data_in_3_etapa <= data_in_2_etapa;
					

		//registrar productos (3 etapa)
		
			prod_fase <= data_in_3_etapa * ref_fase_actual;
			prod_cuad <= data_in_3_etapa * ref_cuad_actual;
			
				
		//guardar dato en arreglo (4 etapa)
						
			array_prod_fase[index_lockin] <= prod_fase;
			array_prod_cuad[index_lockin] <= prod_cuad;

			
			data_in_5_etapa_fase <= prod_fase;
			data_in_5_etapa_cuad <= prod_cuad;
			
			data_out_5_etapa_fase <= array_prod_fase[index_lockin];
			data_out_5_etapa_cuad <= array_prod_cuad[index_lockin];
			
		// Actualizar acumulador (5 etapa)
				
			acum_fase <= acum_fase + data_in_5_etapa_fase - data_out_5_etapa_fase;		
			acum_cuad <= acum_cuad + data_in_5_etapa_cuad - data_out_5_etapa_cuad;		

				
		// Actualizar salida (6 etapa)
		
			data_out_fase <= acum_fase;			
			data_out_cuad <= acum_cuad;			
				
	end 
	
	else if(!habilitar)	// Clear arrays	
	begin
	
		array_prod_fase[i]<=0;
		array_prod_cuad[i]<=0;
		i<=i+1;	
		
	end
		
end

//=======================================================
//  Circuiteria registros de status 
//=======================================================

assign fifos_llenos = ((data_valid_reg && !habilitar))? 1:0;

endmodule


	
	