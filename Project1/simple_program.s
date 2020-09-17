	.text
	.equ	LEDs,		0xFF200000
	.equ	SWITCHES,	0xFF200040
	.global _start
_start:
	movia	r2, LEDs			# Address of LEDs
	movia	r3, SWITCHES	# Address of switches

LOOP:
	ldwio	r4, (r3)		# Read the state of switches

	srli r5, r4, 5  	# r5 stores SW[10:5] 0000001111100000
	andi r6, r4, 31   # r6 stores SW[4:0] 0000000000011111

	add r4, r5, r6		# replace r4 with the sum of the switches

	stwio	r4, (r2)		# Display the state on LEDs
	br		LOOP

	.end
