
module lu_table #(

	parameter B_depth_lu_table = 14,
	parameter B_lu_table = 16

)
(

	input clk,
	input reset_n,
	
	input [B_depth_lu_table-1:0] address,
	
	output [B_lu_table-1:0] sen,
	output [B_lu_table-1:0] cos

);


parameter depth_LU_table = 2**B_depth_lu_table; 	// Con esto se logra un S=70 (spurious free dinamic range) 

parameter c = 2**B_depth_lu_table/4;				// Punto en que el seno comienza a decrementar

parameter v_medio = 2**(B_lu_table-1)-1;

reg [B_lu_table-1:0] lu_table [0:depth_LU_table/4];	// Uso solo 1/4 de la tabla y hago alguna magia para ahorrar espacio

	
initial	
begin
		if (B_depth_lu_table == 12) $readmemh("LU_Tables/x4096_16b_cuarto_de_tabla.mem",lu_table);
		
		else if(B_depth_lu_table == 14) $readmemh("LU_Tables/x16384_16b_cuarto_de_tabla.mem",lu_table);
		
		else $readmemh("LU_Tables/x4096_16b_cuarto_de_tabla.mem",lu_table);	// Nunca deberia llegar aca
end
	
	
		
		
wire [B_depth_lu_table-1:0]  address_sen,address_cos;


assign address_sen = (address >= 0 && address < c) ? address :
							(address >= c && address < 2*c) ?  c - (address - c) :
							(address >= 2*c && address < 3*c) ?  (address - 2*c) :
							(address >= 3*c && address < 4*c) ? c - (address - 3*c) : 0;
							
assign address_cos = (address >= 0 && address < c) ? c - address :
							(address >= c && address < 2*c) ?  (address - c) :
							(address >= 2*c && address < 3*c) ?  c - (address - 2*c) :
							(address >= 3*c && address < 4*c) ? (address - 3*c) : 0;
    
							
					

assign sen = (address >= 0 && address < 2*c) ? v_medio + lu_table[address_sen] : 
				 (address >= 2*c && address < 4*c) ? v_medio - lu_table[address_sen] : 0 ;

assign cos = ((address >= 0 && address < c )||(address >= 3*c && address < 4*c )) ? v_medio + lu_table[address_cos] :
				 ((address >= c && address < 2*c )||(address >= 2*c && address < 3*c )) ? v_medio - lu_table[address_cos] : 0 ;



endmodule
