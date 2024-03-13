/*
	Clase que controla las entradas y salidas de la FPGA.
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
