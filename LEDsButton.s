.text
.equ LEDs,		0xFF200000
.equ BUTTONS,	0xFF200050
.global _start

_start:
	movia	r2, LEDs	#address of the LEDs
	movia	r3, BUTTONS #address of the buttons
    movia	r5, 0x3FF
	
OFF:
	ldwio 	r4, (r3)
    stwio 	r0, (r2)
	beq		r4, r0, OFF
ON:
	ldwio 	r4, (r3)
    stwio 	r5, (r2)
	beq		r4, r0, OFF
    br 		ON
    
    .end
