
/*
  funciones_pll.h

  Define funciones para reconfigurar el Pll
  Lo mejor es usar directamente configurar_pll()
  Le pones la frecuencia deseada en MHz y sale andando!

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



