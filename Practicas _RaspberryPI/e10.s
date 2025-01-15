.include  "inter.inc"
 
 .text
	 
/* Agrego vector interrupcion */
        ADDEXC  0x18, irq_handler

/* Inicializo la pila en modos IRQ y SVC */
        mov     r0, #0b11010010   @ Modo IRQ, FIQ&IRQ desact
        msr     cpsr_c, r0
        mov     sp, #0x8000
		
        mov     r0, #0b11010011   @ Modo SVC, FIQ&IRQ desact
        msr     cpsr_c, r0
        mov     sp, #0x8000000
	
	// Configurar GPIO27 y GPIO22 como salidas
	/* guia bits   xx999888777666555444333222111000*/
	ldr r0, =GPBASE
	ldr     r1, =0b00000000001000000000000001000000
	str     r1, [r0, #GPFSEL2]
		
	// Encender GPIO22 y GPIO27
	ldr r0, =GPBASE
	/* guia bits xx999888777666555444333222111000*/
	/* guia bits 10987654321098765432109876543210*/
	ldr r1,   =0b00001000010000000000000000000000
	str r1, [r0, #GPSET0]
	
	// Enable FE interrupts through GPIO2 and GPIO3
	ldr r0, =GPBASE
	/* guia bits 10987654321098765432109876543210*/
	ldr r1,   =0b00000000000000000000000000001100
	str r1, [r0, #GPFEN0]
	
/* Habilito interrupciones, local y globalmente */
	ldr     r0, =INTBASE
	mov     r1, #0b00000000000100000000000000000000
	str     r1, [r0, #INTENIRQ2]
	mov     r0, #0b01010011   @ Modo SVC, IRQ activo
	msr     cpsr_c, r0
	
/* Repetir para siempre */
bucle:  b       bucle

/* Rutina de tratamiento de interrupción */
irq_handler: push    {r0, r1,r2,r3}          @ Salvo registros
		// APAGAR GPIO27 y GPIO22
		ldr r0, =GPBASE
		/* guia bits 10987654321098765432109876543210*/
		ldr r1,   =0b00001000010000000000000000000000
		str r1, [r0, #GPCLR0]
		// Leer source de interrupcion
		ldr r2, [r0, #GPEDS0]
		/* guia bits 10987654321098765432109876543210*/
		ands r2,  #0b00000000000000000000000000000100
		ldreq r1, =0b00001000000000000000000000000000
		ldrne r1, =0b00000000010000000000000000000000
	
		str r1, [r0, #GPSET0]
		// TODO: Clear event
		ldr r0, =GPBASE
		mov r1, #0b00000000000000000000000000001100
		str r1, [r0, #GPEDS0]
		
        pop     {r0, r1,r2,r3}          @ Recupero registros
        subs    pc, lr, #4        @ Salgo de la RTI