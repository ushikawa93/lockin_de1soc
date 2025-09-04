/*==============================================================================
 Módulo: dds_compiler_module
 ------------------------------------------------------------------------------

 Descripción:
 -------------
 Generador de señal digital basado en la técnica de **Direct Digital Synthesis** (DDS).
 Este módulo implementa un acumulador de fase y una tabla de búsqueda (LU table) 
 para obtener las señales seno y coseno cuantizadas a una resolución configurable.

 Características:
 -----------------
 - Generación de señales senoidales y cosenoidales de salida con resolución ajustable.
 - Control de frecuencia mediante incremento de fase (word de control).
 - Opción de retornar a cero en caso de overflow del acumulador de fase.
 - Salidas disponibles en modo normal (0–Vmax) y en modo CA acoplado (centradas en cero).
 - Señal de validación de datos (`data_out_valid`).
 - Señal de cruce por cero (`zero_cross`) para sincronización externa.

 Parámetros:
 ------------
 - res_f              : Resolución en frecuencia (Hz).
 - f_clk              : Frecuencia de reloj del sistema (Hz).
 - B_acumulador       : Bits del acumulador de fase (ceil(log2(f_clk/res_f))).
 - B_out              : Bits de las señales de salida seno/coseno.
 - B_depth_lu_table   : Bits de dirección de la tabla de búsqueda (determina SFDR).
 - B_lu_table         : Bits de cuantización de los valores en la tabla.
 - return2zero        : Habilita retorno a cero en overflow del acumulador (1=activo).

 Entradas:
 ----------
 - clk                : Reloj del sistema.
 - reset_n            : Reset activo en bajo.
 - enable             : Habilita la actualización del DDS.
 - incremento_fase    : Word de control de frecuencia 
                        (≈ f_deseada * 2^B_acumulador / f_clk).

 Salidas:
 ---------
 - zero_cross                  : Señal activa en cruce por cero.
 - data_out_seno               : Señal senoidal (no firmada).
 - data_out_coseno             : Señal cosenoidal (no firmada).
 - data_out_valid              : Flag de validez de datos de salida.
 - data_out_seno_ca_coupled    : Señal senoidal firmada, centrada en cero.
 - data_out_coseno_ca_coupled  : Señal cosenoidal firmada, centrada en cero.

==============================================================================*/

module dds_compiler_module #(

	parameter res_f = 0.5,
	parameter f_clk = 65000000,
	parameter B_acumulador = 27,	// Esto es ceil(log2(f_clk/res_f))
	
	parameter B_out = 16,							// bits de la señal de salida
	parameter B_depth_lu_table = 14,				// B_depth_lu_table = ceil (S/6)	(Con 12 esto se logra un S=70 dB (spurious free dinamic range) )
	parameter B_lu_table = 16,						// Bits de cuantizacion de la LU table
	
	parameter return2zero = 0
	
)

(

	input clk,
	input reset_n,
	input enable,
	
	input [B_acumulador-1:0] incremento_fase,	// round(f_deseada * 2^B_acumulador/f_clk);
	
	output zero_cross,
	
	output [B_out-1:0] data_out_seno,
	output [B_out-1:0] data_out_coseno,
	output data_out_valid,
	
	output signed [B_out-1:0] data_out_seno_ca_coupled,
	output signed [B_out-1:0] data_out_coseno_ca_coupled
);


parameter mean_value = 2**(B_out-1)-1;	

reg [B_out-1:0] data_out_seno_reg,data_out_cos_reg;
reg data_out_valid_reg,data_out_ca_coupled_valid_reg;

reg [B_acumulador-1:0] acumulador_fase,acumulador_fase_reg;
wire [B_depth_lu_table-1:0] acumulador_fase_truncado;

reg signed [B_out-1:0] data_out_seno_ca_coupled_reg,data_out_coseno_ca_coupled_reg;

always @ (posedge clk)
begin
	
	if(!reset_n)
	begin
	
		acumulador_fase <= 0;
		acumulador_fase_reg <= 0;
		
		data_out_valid_reg <= 0;
	
	end
	else if(enable)
	begin
		
		if(return2zero== 1)
			if( (acumulador_fase + incremento_fase) < acumulador_fase)
				acumulador_fase <= 0;
			else
				acumulador_fase <= acumulador_fase + incremento_fase;			
		else
			acumulador_fase <= acumulador_fase + incremento_fase;
			
		acumulador_fase_reg  <= acumulador_fase;
		
		data_out_seno_reg <= sen[(B_lu_table-1) : (B_lu_table - B_out)];	// Tomo los B_out digitos mas significativos del dato
		data_out_cos_reg <= cos[(B_lu_table-1) : (B_lu_table - B_out)];	// Tomo los B_out digitos mas significativos del dato
		
		data_out_seno_ca_coupled_reg <= sen[(B_lu_table-1) : (B_lu_table - B_out)] - mean_value;
		data_out_coseno_ca_coupled_reg <= cos[(B_lu_table-1) : (B_lu_table - B_out)] - mean_value;
		
		data_out_valid_reg <= 1;
		
	end

end

assign acumulador_fase_truncado =  acumulador_fase >> (B_acumulador-B_depth_lu_table);
wire [B_lu_table-1:0] sen,cos;

lu_table #(
        .B_depth_lu_table(B_depth_lu_table),  // log2(depth_lu_table). Determina S
        .B_lu_table(B_lu_table)         		 // Bits de cuantizacion de la LU table
) lu
(


	.clk(clk),
	.reset_n(reset_n),
	
	.address(acumulador_fase_truncado),
	
	.sen(sen),
	.cos(cos)

);



assign data_out_seno = data_out_seno_reg;
assign data_out_coseno = data_out_cos_reg;
assign data_out_valid = data_out_valid_reg;

assign data_out_seno_ca_coupled = data_out_seno_ca_coupled_reg;
assign data_out_coseno_ca_coupled = data_out_coseno_ca_coupled_reg;


assign zero_cross = ((acumulador_fase_reg > acumulador_fase) );

endmodule


