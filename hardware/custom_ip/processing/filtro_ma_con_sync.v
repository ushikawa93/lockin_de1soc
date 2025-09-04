/*==============================================================================
 Módulo: filtro_ma_con_sync
 ------------------------------------------------------------------------------

 Descripción:
 -------------
 Implementa un **filtro de media móvil sincronizado** para señales de streaming 
 tipo Avalon.  
 Acumula `frames_integracion` ciclos de señal (cada uno con `ptos_x_ciclo` puntos) 
 y entrega la suma acumulada como salida, junto con señales de validación y 
 control.

 Características:
 -----------------
 - Entrada/salida tipo Avalon Streaming (data + valid).  
 - Acumulación de datos con control de habilitación (`enable`).  
 - Control mediante señal de inicio (`start_signal`) y conteo de frames.  
 - Señales auxiliares de control: `ready_to_calculate`, `calculo_finalizado`, 
   `datos_promediados`.  
 - Reset síncrono y asíncrono.  
 - Conteo interno de frames promediados y acumulación de datos de 64 bits.

 Parámetros internos:
 ---------------------
 - M : Cantidad de puntos por ciclo de señal (`ptos_x_ciclo`).  
 - N : Número de frames a integrar (`frames_integracion`).  
 - ignore_cycles : Ciclos iniciales de start a ignorar (default = 1).

 Entradas:
 ----------
 - clock             : Reloj del sistema.  
 - reset_n           : Reset activo en bajo.  
 - enable            : Habilita la operación del filtro.  
 - ptos_x_ciclo      : Puntos por ciclo de señal (M).  
 - frames_integracion: Número de ciclos a integrar (N).  
 - data_valid        : Señal de validez de entrada.  
 - data              : Datos de entrada (64 bits).  
 - start_signal      : Señal de inicio de cálculo.

 Salidas:
 ---------
 - data_out           : Resultado acumulado (64 bits).  
 - data_out_valid     : Indica validez de `data_out`.  
 - ready_to_calculate  : Señal de control que indica que el módulo está listo.  
 - calculo_finalizado : Flag activo cuando se completa la integración.  
 - datos_promediados  : Número de muestras acumuladas hasta el momento.

 Notas:
 -------
 - El módulo acumula las muestras solo cuando `start_signal` está activo y 
   el proceso no ha terminado (`finish`).  
 - `start_count` controla el inicio efectivo del cálculo después de ignorar 
   los ciclos iniciales.  
 - `datos_promediados` permite conocer cuántas muestras válidas han sido 
   sumadas.  
 - `acumulador` es de 64 bits para evitar saturación durante la suma de múltiples 
   frames.  

==============================================================================*/


module filtro_ma_con_sync(

	// Entradas de control
	input clock,
	input reset_n,
	input enable,
	
	// Parametros de configuracion
	input [31:0] ptos_x_ciclo,
	input [31:0] frames_integracion,
	
	// Entrada avalon streaming 
	input data_valid,
	input [63:0] data,	
	
	input start_signal,
		
	// Salida avalon streaming
	output [63:0] data_out,
	output data_out_valid,

	// Salidas auxiliares
	output ready_to_calculate,
	output calculo_finalizado,
	output [31:0] datos_promediados

);


//=======================================================
// Parametros de configuracion 
//=======================================================


wire [31:0] M;	assign M = ptos_x_ciclo;				// Puntos por ciclo de señal
wire [31:0] N; 	assign N = frames_integracion;		// Frames de integracion // Largo del lockin M*N	

reg [63:0] acumulador;

reg [31:0] datos_promediados_reg;

reg finish,finish_1,data_out_valid_reg,start;

// Registro las entradas... es mas prolijo trabajar con las entradas registradas
reg signed [63:0] data_in_reg; 
    always @ (posedge clock) data_in_reg <= (!reset_n)? 0: $signed(data);
    
reg data_valid_reg; always @ (posedge clock) data_valid_reg <= (!reset_n)? 0: data_valid;
reg start_signal_reg; always @ (posedge clock) start_signal_reg <= (!reset_n)? 0: start_signal;

always @ (posedge clock or negedge reset_n)
begin

	if(!reset_n)
	begin		
		data_out_valid_reg <= 0;
		acumulador <= 0;
		datos_promediados_reg <= 0;
	end
	
	else if (enable)
	begin
		
		if(data_valid_reg && !finish && start)
		begin
			acumulador <= acumulador + data_in_reg;
			data_out_valid_reg <= 1;
			datos_promediados_reg <= datos_promediados_reg + 1;
		end
		else if(!data_valid_reg && !finish)
		begin
			data_out_valid_reg <= 0;			
		end
	end		
	
end

// Este cacho de codigo cuenta cuantas señales de start llegan
// Cuando me lleguen N señales de start pongo en alto la señal de finish
// y ahi la cosa deja de calcular...

reg [31:0] start_count;
parameter ignore_cycles = 1;

always @ (posedge clock or negedge reset_n)
begin

    if(!reset_n)
    begin
        start_count <= 0;
        finish <= 0;
		  finish_1 <= 0;
        start <= 0;
    end
    else if(enable)
    begin  
	 
		  finish <= finish_1;
                
        if(start_count >= 1+ignore_cycles)
            start <= 1;
        
        if(start_signal_reg && !finish)
        begin
            start_count <= start_count + 1;            
            finish_1 <= (start_count == N+ignore_cycles)? 1:0;
        end
    end
end

// Salidas
assign data_out_valid = data_out_valid_reg;
assign data_out = acumulador;
assign ready_to_calculate = 1;
assign calculo_finalizado = finish;
assign datos_promediados = datos_promediados_reg;


endmodule