module trigger(

	input clk,
	input reset_n,

	input signed [31:0] data_in,
	input data_in_valid,
	
	output trigger
);

parameter nivel = 4000;

// Segunda opcion de trigger
// aca me fijo cuando la señal pasa un nivel y ahi la disparo
reg trigger_reg;
reg signed [31:0] data_in_reg;
reg [31:0] counter_level;

// Pequeña maquina de estados para evitar que dos trigger se habiliten muy juntos
// esto podría pasar por ruido por ejemplo
// por ahora lo soluciono asi capaz hay otro metodo mejor...
reg [2:0] state;
localparam idle=0,trigger_off=1;

always @ (posedge clk)
begin
    if(!reset_n || user_reset)
    begin
        state <= idle; 
        counter_level <= 0;
        trigger_reg <= 0;
        data_in_reg <= 0; 
    end       
    else 
    begin
      
        if(data_valid)
        begin    
        
          data_in_reg <= data_in;
    
          case(state)
            idle:
            begin
                counter_level <= 0;
                state <= ( (data_in > nivel) && (data_in_reg <= nivel) ) ? trigger_off : idle;
                trigger_nivel_reg <= ( (data_in > nivel) && (data_in_reg <= nivel) ) ? 1 : 0 ;
            end
            trigger_off:
            begin        
					trigger_nivel_reg <= 0;				
					//Solo el reset_n me saca de aca
				end
          endcase
       end
   end
end

endmodule
