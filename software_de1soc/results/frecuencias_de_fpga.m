function frecuencia_real = frecuencias_de_fpga(frecuencia, M)
    min_divisor = 1;
    max_divisor = 1000;
    
    min_error = 10000000;
    frec_final = 1;
    divisor_final = 1;
    ready_flag = 0;
    
    for frec = 1:65
        for divisor = min_divisor:max_divisor
            error = abs(frecuencia - frec * 1000000 / (M * divisor));
            if error == 0
                ready_flag = 1;
                frec_final = frec;
                divisor_final = divisor;
                break;
            elseif error < min_error
                min_error = error;
                frec_final = frec;
                divisor_final = divisor;
            end
        end
        if ready_flag == 1
            break;
        end
    end
    
    frecuencia_real = frec_final*1e6 / (divisor_final*M);

end