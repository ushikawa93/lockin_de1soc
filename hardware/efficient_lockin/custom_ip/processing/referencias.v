
module referencias(

	// Entradas de control
	input clock,
	input reset_n,
	input enable,
	
	// Parametro configurable
	input [31:0] pts_x_ciclo,

	// Entrada de sincronizacion
	input avanzar_en_tabla,
	
	output signed [31:0] data_out_seno,
	output signed [31:0] data_out_cos

);


//=======================================================
// Parametros de configuracion de los módulos
//=======================================================


parameter atenuacion = 0;
parameter B_lu_table = 24;
parameter ref_mean_value = 2**(B_lu_table-1)-1;

wire [15:0] M = pts_x_ciclo;				// Puntos por ciclo de señal


reg [15:0] interval;
	always @ (posedge clock) interval = 2048/M; // Para poder cambiar el largo de la secuencia sin tener que leer otro archivo
	

//=======================================================
// Reg/Wire declarations
//=======================================================

// Referencias seno y coseno en sendas LU table
reg [B_lu_table-1:0]  ref_sen   [0:2047];	initial if(B_lu_table == 16) $readmemh("LU_Tables/x2048_16b.mem",ref_sen); else $readmemh("LU_Tables/x2048_24b.mem",ref_sen);
reg [B_lu_table-1:0]  ref_cos   [0:2047];	initial if(B_lu_table == 16) $readmemh("LU_Tables/y2048_16b.mem",ref_cos); else $readmemh("LU_Tables/y2048_24b.mem",ref_cos);

reg [31:0] index,index_out;

reg signed [31:0] data_out_seno_reg;
reg signed [31:0] data_out_cos_reg;

//reg avanzar_en_tabla_reg; always @ (posedge clock) avanzar_en_tabla_reg <= (!reset_n)? 0: avanzar_en_tabla;


//=======================================================
// Algoritmo principal
//=======================================================

always @ (posedge clock or negedge reset_n)
begin
	
	if(!reset_n)
	begin		
		
		index <= 1;	
		data_out_seno_reg <= ref_sen[0];
		data_out_cos_reg <= ref_cos[0];

	end
	else if(enable)
	begin
		if(avanzar_en_tabla)
		begin
			
			index <= (index == (M-1))? 0: index+1;					
						
			data_out_seno_reg <= ref_sen[index*interval];
			data_out_cos_reg <= ref_cos[index*interval];
				
		end
	end
end

//=======================================================
// Salidas
//=======================================================

assign data_out_seno = (data_out_seno_reg - ref_mean_value) >>> atenuacion;
assign data_out_cos = (data_out_cos_reg - ref_mean_value) >>> atenuacion;



endmodule


