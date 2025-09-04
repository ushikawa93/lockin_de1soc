/*==============================================================================
 Módulo: delay_axi_streaming
 ------------------------------------------------------------------------------

 Descripción:
 -------------
 Módulo que implementa un **retardo en serie** (pipeline) para señales de 
 streaming tipo Avalon o similares.  
 Permite retrasar `delay` ciclos una señal de entrada y su flag de validez, 
 con opción de bypass para transmitir directamente la entrada sin retardo.

 Características:
 -----------------
 - Soporta ancho de datos configurable (`width`).
 - Retardo configurable en número de ciclos (`delay`).
 - Manejo de señales de validación de datos (`data_in_valid` / `data_out_valid`).
 - Opción de bypass para saltar el retardo.
 - Pipeline simple implementado con registros en array.
 - Reset síncrono y reloj positivo.

 Parámetros:
 ------------
 - delay : Número de ciclos de retardo (default = 2).  
 - width : Ancho de los datos de entrada y salida (default = 32 bits).

 Entradas:
 ----------
 - clk           : Reloj del sistema.  
 - reset_n       : Reset activo en bajo.  
 - bypass        : Si está activo, transmite `data_in` directamente.  
 - data_in       : Señal de entrada a retrasar (`width` bits).  
 - data_in_valid : Flag de validez de `data_in`.

 Salidas:
 ---------
 - data_out       : Señal de salida retrasada (`width` bits).  
 - data_out_valid : Flag de validez de `data_out`.

 Notas:
 -------
 - La implementación utiliza un array de registros para almacenar el pipeline.  
 - El retardo efectivo es de `delay` ciclos de reloj.  
 - Cuando `bypass` está activo, `data_out` y `data_out_valid` reflejan 
   inmediatamente la entrada sin retardo.  

==============================================================================*/


module delay_axi_streaming #(	
	parameter delay = 2,
	parameter width = 32
)
(

    input clk,
    input reset_n,
    input bypass,

    input [width-1:0] data_in,
    input data_in_valid,
    
    output [width-1:0] data_out,
    output data_out_valid
    
);

reg [width-1:0] data_reg [delay-1:0];
reg data_valid_reg [delay-1:0];
integer i;

always @ (posedge clk)
begin
    
    data_reg[0] <= data_in;
    data_valid_reg[0] <= data_in_valid;
    
	 
	 for (i = 0; (i < delay-1) ; i = i + 1) begin
			data_reg[i+1] <= data_reg[i];
			data_valid_reg[i+1] <= data_valid_reg[i];    
	 end
	
	
end

assign data_out = (bypass)? data_in : data_reg[delay-1];
assign data_out_valid = (bypass)? data_in_valid : data_valid_reg[delay-1];

endmodule
