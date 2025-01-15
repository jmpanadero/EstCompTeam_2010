        .set    GPBASE,   0x3F200000
        .set    GPFSEL2,  0x08
        .set    GPSET0,   0x1c
	.set	 GPLEV0,	0x34 /* Cambia si pulsas algun pulsador
	.set    GPCLR0,  0x28
	
.text
        ldr     r0, =GPBASE
/* guia bits           xx999888777666555444333222111000*/
        ldr   	r1, =0b00000000001000000000000001000000
        str	r1, [r0, #GPFSEL2]  @ Configura GPIO 22 y 27 
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00001000010000000000000000000000
        str     r1, [r0, #GPSET0]   @ Enciende GPIO 22 y 27

loop:	
	ldr	r1, [r0, #GPLEV0]
	ands	r2, r1, #0b00000000000000000000000000000100 /* Los bits valen ... 3 2 1 0. Refiriendos
	beq	pulsador1
	ands	r2, r1, #0b00000000000000000000000000001000
	beq	pulsador2
	b 	loop
	
pulsador1:	
/* guia bits           10987654321098765432109876543210*/
        ldr 	r1, =0b00000000010000000000000000000000
        str     r1, [r0, #GPSET0]   @ Enciende GPIO 27
/* guia bits           10987654321098765432109876543210*/
        ldr  	r1, =0b00001000000000000000000000000000
        str     r1, [r0, #GPCLR0]   @ Apaga GPIO 22
	b 	bucle

pulsador2:
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00001000000000000000000000000000
        str     r1, [r0, #GPSET0]   @ Enciende GPIO 22
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00000000010000000000000000000000
        str     r1, [r0, #GPCLR0]   @ Apaga GPIO 27
	b 	bucle
