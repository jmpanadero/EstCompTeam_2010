.set    GPBASE,   0x3F200000
        .set    GPFSEL0,  0x00
        .set    GPFSEL1,  0x04
        .set    GPSET0,   0x1c
		.set	GPLEV0,	  0x34
		.set 	GPCLR0,   0x28
		.set 	STBASE,	  0x3F003000
		.set 	STCLO, 	  0x04
.text
        ldr     r0, =GPBASE
		/* guia bits   xx999888777666555444333222111000 */
        ldr   	r1, =0b00001000000000000001000000000000
        str	r1, [r0, #GPFSEL0]  @ Configura GPIO 9
		/* guia bits   xx999888777666555444333222111000 */
		ldr		r1, =0b00000000001000000000000000000000
		str	r1, [r0, #GPFSEL1]
loop: 	mov 	r3, #0b0100
		mov 	r4, #0b1000
		ldr		r2, [r0, #GPLEV0]
		tst		r2, r3
		beq		ontwo
		tst		r2, r4
		beq		onseven
		b		loop
	  /* guia bits     10987654321098765432109876543210*/
ontwo:	mov   	r1, #0b00000000000000000000001000010000
		ldr		r5, =3816 @periodo del do
        str     r1, [r0, #GPSET0]   @ Enciende GPIO 9
		bl		reset
	  /* guia bits     10987654321098765432109876543210*/
onseven: ldr	r1, =0b00000000000000100000000000010000
		ldr		r5, =2558
		str     r1, [r0, #GPSET0]   @ Enciende GPIO 9
		bl 		reset
reset:	mov		r6,	#0b00000000000000000000000000010000
		str	r6,	[r0, #GPSET0]
		ldr r2, =STBASE
		ldr r3, [ r2, #STCLO ] @ Lee contador en r3
		add r7, r3, r5 @ r7= r3+ periodo
		bl wait
		str r6, [r0, #GPCLR0]
		ldr r3, [ r2, #STCLO ] @ Lee contador en r3
		add r7, r3, r5 @ r7= r3+ periodo
		bl wait
		b reset
wait: 	ldr r3, [ r2, #STCLO ]
		cmp r3, r7 @ Leemos CLO hasta alcanzar
		blo wait
		bx	lr