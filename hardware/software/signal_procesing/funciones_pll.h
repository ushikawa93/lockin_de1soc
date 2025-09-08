
/*
================================================================================
 Módulo de reconfiguración del PLL
 Archivo: funciones_pll.h
--------------------------------------------------------------------------------
 Este archivo define las funciones necesarias para controlar y reconfigurar el
 PLL integrado en el SoC-FPGA. Permite ajustar la frecuencia de salida en tiempo
 de ejecución a partir de una frecuencia de referencia conocida.

 Elementos principales:
 
   **Estructura Pll_parameters:**
     - Contiene los valores M, N y C que definen la relación de división/multiplicación.
     - Fórmula base: Fout = (M / (N * C0)) * Fin

   **Funciones de configuración directa:**
     - configurar_pll(): función de alto nivel que recibe la frecuencia deseada 
       en MHz y calcula automáticamente los parámetros necesarios.
     - setClockDivider(): configura un divisor externo de clock.

   **Funciones de bajo nivel (parámetros internos del PLL):**
     - setM(), setN(), setC(): setean individualmente cada parámetro.
     - setMNC(): permite setear M, N y C al mismo tiempo.
     
   **Cálculo automático de parámetros:**
     - calculatePll_parameters(): obtiene M, N y C adecuados según la frecuencia 
       deseada y la de referencia, asegurando que:
         - fvco = (Fin * M / N) ∈ [300, 1600] MHz
         - fpfd = (Fin / N) ∈ [5, 325] MHz

 Uso recomendado:
   - Llamar a configurar_pll(frec_deseada, *pll_reconfig) para ajustar el PLL 
     sin preocuparse por los detalles internos. El segundo parámetro es un puntero
     a la dirección de memoria donde esta el pll

================================================================================
*/



struct Pll_parameters{
    int M, N, C;
};

//--------------- Funcion para setear el divisor del reloj -------------------------------//
int setClockDivider (int divisor_deseado,int*clk_divider_addr);

//--------------- Funcion para configurar todo abstrayendome de como se hace -------------------------------//
double configurar_pll(int frec_deseada,int* pll_reconfig);


//--------------- Funciones para cambiar parametros del PLL -------------------------------//
//-------------------- Fout = M/ (N*C0) * Fin ---------------------------------------------//

void setM(int M, int* pll_reconfig);
void setN(int N, int* pll_reconfig);
void setC(int C,int counter_number, int* pll_reconfig);
void setMNC(int M, int N, int C, int counter_number, int* pll_reconfig);

//--------------- Funcion para calcular parametros del PLL segun f_deseada -------------------------------//
//------------------------------- Fout = M/ (N*C0) * Fin -------------------------------------------------//
//--------------- Asegura que -> fvco = (fin * M/N) este en rango -> [300;1600]MHz -----------------------//
//--------------- Asegura que -> fpfd = fin/N este en rango -> [5;325]MHz --------------------------------//
struct Pll_parameters calculatePll_parameters(int frec_deseada,int frec_referencia);



