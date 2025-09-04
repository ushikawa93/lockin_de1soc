/*
    Clase `filters` para filtros FIR predefinidos

    Descripción:
    ------------
    Esta clase encapsula diferentes filtros FIR (Finite Impulse Response) de 33
    coeficientes predefinidos para frecuencias de corte específicas. Permite
    seleccionar filtros Pasa-bajos o Pasa-altos según la necesidad del usuario.

    Propiedades:
    ------------
    - Filtros Pasa-bajos (PB) con frecuencias de corte normalizadas: 0.05, 0.1, 0.15, 0.2, 0.25, 0.3
    - Filtros Pasa-altos (PA) con frecuencias de corte normalizadas: 0.05, 0.1, 0.15, 0.2, 0.25, 0.3
    - `zero_array`: arreglo de 33 ceros, devuelto como fallback si no se encuentra el filtro solicitado

    Métodos públicos:
    ----------------
    - `int* getfiltro(int w, int high_low)`: Devuelve un puntero al arreglo de coeficientes del filtro
        Parámetros:
        - `w`: frecuencia de corte deseada expresada como porcentaje (ej: 15 para 0.15)
        - `high_low`: tipo de filtro (0 = Pasa-bajos, 1 = Pasa-altos)
        Retorna:
        - Puntero a un arreglo de 33 coeficientes del filtro correspondiente.
        - Si no existe el filtro para los parámetros dados, retorna `zero_array`.
    
    Uso típico:
    -----------
        filters filtros;
        int* coeficientes = filtros.getfiltro(15, 0); // Devuelve PB_0_15

    Notas:
    ------
    - Los coeficientes están precalculados y codificados manualmente.
    - La clase no depende de ninguna librería externa.
*/

class filters
{
    private:

        // Filtros Pasa-bajos
        int PB_0_05 [33] = {83,	118,	188,	306,	482,	724,	1031,	1400,	1820,	2272,	2737,	3189,	3604,	3957,	4227,	4395,	4453,	4395,	4227,	3957,	3604,	3189,	2737,	2272,	1820,	1400,	1031,	724,	482,	306,	188,	118,	83};
        int PB_0_1 [33] = {-101,	-125,	-165,	-207,	-222,	-169,	0,	325,	835,	1533,	2391,	3352,	4334,	5241,	5975,	6453,	6619,	6453,	5975,	5241,	4334,	3352,	2391,	1533,	835,	325,	0,	-169,	-222,	-207,	-165,	-125,	-101};
        int PB_0_15 [33] = {98,	87,	52,	-40,	-219,	-480,	-757,	-927,	-825,	-293,	766,	2339,	4277,	6314,	8115,	9355,	9797,	9355,	8115,	6314,	4277,	2339,	766,	-293,	-825,	-927,	-757,	-480,	-219,	-40,	52,	87,	98};
        int PB_0_2 [33] = {-62,	0,	100,	240,	354,	316,	-1,	-614,	-1339,	-1785,	-1463,	0,	2651,	6097,	9567,	12147,	13100,	12147,	9567,	6097,	2651,	0,	-1463,	-1785,	-1339,	-614,	-1,	316,	354,	240,	100,	0,	-62};
        int PB_0_25 [33] = { -1,	-88,	-172,	-180,	0,	382,	761,	739,	-1,	-1331,	-2496,	-2353,	0,	4546,	10088,	14654,	16422,	14654,	10088,	4546,	0,	-2353,	-2496,	-1331,	-1,	739,	761,	382,	0,	-180,	-172,	-88,	-1};
        int PB_0_3 [33] = {61,	123,	100,	-78,	-355,	-436,	-1,	842,	1335,	578,	-1460,	-3311,	-2646,	1976,	9546,	16682,	19607,	16682,	9546,	1976,	-2646,	-3311,	-1460,	578,	1335,	842,	-1,	-436,	-355,	-78,	100,	123,	61};

        // Filtros Pasa-altos
        int PA_0_05 [33] = {-62,	-88,	-139,	-226,	-356,	-534,	-760,	-1032,	-1341,	-1674,	-2016,	-2349,	-2655,	-2915,	-3113,	-3238,	62309,	-3238,	-3113,	-2915,	-2655,	-2349,	-2016,	-1674,	-1341,	-1032,	-760,	-534,	-356,	-226,	-139,	-88,	-62};
        int PA_0_1 [33] = {99,	123,	162,	204,	219,	166,	-1,	-323,	-827,	-1517,	-2365,	-3315,	-4286,	-5183,	-5908,	-6381,	58900,	-6381,	-5908,	-5183,	-4286,	-3315,	-2365,	-1517,	-827,	-323,	-1,	166,	219,	204,	162,	123,	99};
        int PA_0_15 [33] = {-100,	-88,	-54,	39,	219,	481,	760,	931,	828,	294,	-771,	-2351,	-4299,	-6346,	-8156,	-9402,	55793,	-9402,	-8156,	-6346,	-4299,	-2351,	-771,	294,	828,	931,	760,	481,	219,	39,	-54,	-88,	-100};
        int PA_0_2 [33] = {61,	0,	-101,	-241,	-355,	-317,	-1,	612,	1337,	1782,	1461,	0,	-2649,	-6093,	-9561,	-12138,	52360,	-12138,	-9561,	-6093,	-2649,	0,	1461,	1782,	1337,	612,	-1,	-317,	-355,	-241,	-101,	0,	61};
        int PA_0_25 [33] = {-1,	87,	171,	178,	-1,	-382,	-760,	-739,	-1,	1327,	2491,	2348,	-1,	-4539,	-10072,	-14630,	49182,	-14630,	-10072,	-4539,	-1,	2348,	2491,	1327,	-1,	-739,	-760,	-382,	-1,	178,	171,	87,	-1};
        int PA_0_3 [33] = {-62,	-124,	-101,	78,	355,	436,	0,	-845,	-1340,	-581,	1463,	3320,	2653,	-1983,	-9576,	-16733,	45888,	-16733,	-9576,	-1983,	2653,	3320,	1463,	-581,	-1340,	-845,	0,	436,	355,	78,	-101,	-124,	-62};

        int zero_array [33] = {0};

    public:
        int* getfiltro(int w,int high_low)     // 0<w<1.0 -> Se ingresa en entero 0.15 = 15, como un porcentaje. high_low = 1 para pasa-altos y 0 para pasa-bajos
        {
            if(high_low == 0)
            {
                switch (w)
                {
                case 5:
                    return PB_0_05;
                case 10:
                    return PB_0_1;
                case 15:
                    return PB_0_15;
                case 20:
                    return PB_0_2;
                case 25:
                    return PB_0_25;
                case 30:
                    return PB_0_3;
                default:
                    break;
                }

            }
            if(high_low == 1)
            {
                switch (w)
                {
                case 5:
                    return PA_0_05;
                case 10:
                    return PA_0_1;
                case 15:
                    return PA_0_15;
                case 20:
                    return PA_0_2;
                case 25:
                    return PA_0_25;
                case 30:
                    return PA_0_3;
                default:
                    break;
                }

            }

            
            return zero_array;

        }

};
