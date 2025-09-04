/*
================================================================================
 Clase de control de entradas y salidas de la FPGA
 Archivo: FPGA_IO_simple.h
--------------------------------------------------------------------------------
 Esta clase encapsula la interacción con los registros mapeados de la FPGA
 usando /dev/mem, permitiendo leer y escribir parámetros de forma sencilla 
 desde software, así como configurar el PLL interno.

 Funcionalidad principal:
   - Mapear la FPGA en memoria usando mmap.
   - Leer y escribir registros y parámetros en direcciones específicas.
   - Configurar la frecuencia del clock principal mediante un PLL.
   - Facilitar la abstracción de las operaciones de bajo nivel.

Definiciones incluidas:
   - Constructor: mapea la FPGA en memoria.
   - Destructor: libera el mapeo.
   - WriteFPGA(ADDRESS, OFFSET, value): escribe un valor en la FPGA.
   - ReadFPGA(ADDRESS, OFFSET): lee un valor desde la FPGA.
   - ConfigurarPll(value): configura la frecuencia del PLL interno.

Uso típico:
   FPGA_IO_simple fpga;
   fpga.WriteFPGA(PARAMETERS_BASE, 3, 42);  // Escribe valor 42 en parámetro 3
   long val = fpga.ReadFPGA(RESULT0_32_BIT_BASE, 0); // Lee resultado 32-bit
   fpga.ConfigurarPll(50); // Configura PLL a ~50 MHz

================================================================================
*/


// Librerias para mmap y entradas/salidas
#include <sys/mman.h>
#include <fcntl.h>
#include <stdio.h>
#include "FPGA_macros.h"
#include "PLL.h"

typedef unsigned char uint8_t;  


class FPGA_IO_simple{
	
	private:
		// Mapeo general de /dev/mem/
		void * virtual_base;
		volatile unsigned long * puntero_a_variable;
		int fd;				
		PLL pll;	// Esta es una clase aparte porque configura varios parametros
	
	public:
		FPGA_IO_simple()
		{
			// Mapeo en memoria el dispositivo /dev/mem/
			fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ;		
			virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, HW_REGS_BASE );
		}
		
		~FPGA_IO_simple()
		{
			munmap( virtual_base, HW_REGS_SPAN );			
		}
		
		// Escribe en la FPGA el valor VALUE en la direccion ADDRES + OFFSET
		void WriteFPGA( unsigned long int ADDRESS, unsigned long int OFFSET, int value )
		{
			puntero_a_variable = (volatile unsigned long*)((uint8_t*)virtual_base + ( ( unsigned long  )( ALT_LWFPGASLVS_OFST + ADDRESS ) & ( unsigned long)( HW_REGS_MASK ) ) );
			*(puntero_a_variable + OFFSET) = value;
		}
		
		// Lee de la FPGA un valor en la direccion ADDRESS + OFFST
		long long int ReadFPGA(unsigned long int ADDRESS, unsigned long int OFFSET)
		{
			puntero_a_variable = (volatile unsigned long*)((uint8_t*)virtual_base + ( ( unsigned long  )( ALT_LWFPGASLVS_OFST + ADDRESS ) & ( unsigned long)( HW_REGS_MASK ) ) );
			return *(puntero_a_variable + OFFSET) ;
		}
		
		// Configura la frecuencia del clock principal a la deseada (o lo mas cerca que pueda)
		void ConfigurarPll(int value)
		{
			puntero_a_variable =  (volatile unsigned long*)((uint8_t*)virtual_base + ( ( unsigned long  )( ALT_LWFPGASLVS_OFST + PLL_RECONFIGURAR_BASE ) & ( unsigned long)( HW_REGS_MASK ) ) );
			pll.configurar_pll ( value , puntero_a_variable ) ; 
		}
		
		
				
};
