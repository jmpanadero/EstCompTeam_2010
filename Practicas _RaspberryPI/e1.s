.set    GPBASE,   0x20200000
        .set    GPFSEL0,  0x00
        .set    GPFSEL1,  0x04
	.set    GPFSEL2,  0x08
        .set    GPSET0,   0x1c
		.set	GPLEV0,	  0x34
		.set 	GPCLR0,   0x28
		.set 	STBASE,	  0x20003000
		.set 	STCLO, 	  0x04
.text
        ldr     r0, =GPBASE
/* guia bits          xx999888777666555444333222111000*/
	ldr	r1, =0b00001000000000000001000000000000
	str	r1, [r0, #GPFSEL0] @ Configura GPIO 9
/* guia bits          xx999888777666555444333222111000*/
	ldr	r1, =0b00000000000000000000000000001000
	str	r1, [r0, #GPFSEL1] @ Configura GPIO 11
/* guia bits          xx999888777666555444333222111000*/
        ldr   	r1, =0b00000000000000000000000001000000
        str	r1, [r0, #GPFSEL2]  @ Configura GPIO 22
/* guia bits          10987654321098765432109876543210*/
        ldr   	r1, =0b00000000010000000000101000000000
	ldr	r2, =STBASE
loop: 	str     r1, [r0, #GPSET0]   @ Enciende GPIOs
		mov 	r3, #0b0100
		mov 	r4, #0b1000
		ldr		r2, [r0, #GPLEV0]
		tst		r2, r3
		beq		ontwo
		tst		r2, r4
		beq		onseven
		b		loop
ontwo:	ldr		r5, =250000 @tiempo
        str     r1, [r0, #GPSET0]   @ Enciende GPIO 
		bl		reset
onseven: ldr		r5, =125000
		str     r1, [r0, #GPSET0]   @ Enciende GPIO 
		bl 		reset
reset:	str	r1,	[r0, #GPSET0]
		ldr r2, =STBASE
		ldr r3, [ r2, #STCLO ] @ Lee contador en r3
		add r7, r3, r5
		bl wait
		str r1, [r0, #GPCLR0]
		ldr r3, [ r2, #STCLO ] @ Lee contador en r3
		add r7, r3, r5
		bl wait
		b loop @de esta manera se mantiene pulsado y funciona
wait: 	ldr r3, [ r2, #STCLO ]
		cmp r3, r7
		blo wait
		bx	lr