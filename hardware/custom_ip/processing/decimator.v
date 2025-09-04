/*==============================================================================
 Módulo: decimator
 ------------------------------------------------------------------------------

 Descripción:
 -------------
 Módulo **decimador** que reduce la tasa de muestreo de una señal digital.  
 Cada N-ésima muestra (definida por `decimate_value`) se transmite al 
 siguiente bloque, descartando las demás.  
 Mantiene una señal de validez (`data_out_valid`) para la salida y un flag 
 de finalización (`finish`) cuando se alcanza la profundidad máxima del buffer.

 Características:
 -----------------
 - Entrada/salida de 32 bits.
 - Control de decimación mediante `decimate_value`.
 - Señal de salida validada (`data_out_valid`).
 - Flag de finalización (`finish`) al alcanzar `FIFO_DEPTH`.
 - Reset síncrono y asíncrono.

 Parámetros:
 ------------
 - FIFO_DEPTH : Cantidad máxima de datos procesados antes de indicar `finish` 
                (default = 1024).

 Entradas:
 ----------
 - clk           : Reloj del sistema.
 - reset_n       : Reset global activo en bajo.
 - enable        : Habilita la operación del decimador.
 - data_in       : Señal de entrada a decimar (32 bits).
 - data_in_valid : Señal que indica validez de la entrada.
 - decimate_value: Factor de decimación (cada `decimate_value` muestras se toma 1).

 Salidas:
 ---------
 - data_out       : Salida decimada (32 bits).
 - data_out_valid : Señal de validez de `data_out`.
 - finish         : Flag activo cuando se han procesado `FIFO_DEPTH` muestras.

 Notas:
 -------
 - El contador interno `counter` controla la frecuencia de muestreo de salida.
 - `counter_data` lleva la cuenta total de muestras transmitidas.
 - Solo se transmite una muestra cada `decimate_value` entradas válidas.
 - Se puede reiniciar el proceso mediante `reset_n`.

==============================================================================*/


`timescale 1ns / 1ps

module decimator(

    input clk,
    input reset_n,
    input enable,

    input [31:0] data_in,
    input data_in_valid,
    
    input [31:0] decimate_value,
    
    output [31:0] data_out,
    output data_out_valid,
    
    output finish


    );

parameter FIFO_DEPTH = 1024;

reg [31:0] counter_data;
reg [31:0] counter;
reg [31:0] data_out_reg;
reg data_out_valid_reg;
reg finish_reg;

always @ (posedge clk or negedge reset_n)
begin

    if(!reset_n)
    begin
        counter <= 0;
        data_out_valid_reg <= 0;
        data_out_reg <= 0;
        counter_data <= 0;
        finish_reg <= 0;
    end
    else if (enable)
        if (data_in_valid)
        begin
            
            counter <= counter +1;
            if(counter == decimate_value-1)
                counter <= 0;
            
            if(counter == 0)
            begin
                data_out_reg <= data_in;
                data_out_valid_reg <= 1;                
                counter_data <= (counter_data == FIFO_DEPTH)? counter_data : counter_data + 1;
            end
            else
                data_out_valid_reg <= 0;
        end
        else
            data_out_valid_reg <= 0;
     else
        data_out_valid_reg <= 0;
        
end

assign data_out = data_out_reg;
assign data_out_valid = data_out_valid_reg;
assign finish = (counter_data == FIFO_DEPTH)? 1 : 0;


endmodule
