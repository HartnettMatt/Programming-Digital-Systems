.text
_start:
    # Loading N into r4:
    movia   r4, N
    ldw     r4, 0(r4)
    movi    r2, 0

	movi	r5, 0
    movi	r6, 5
    
loop3:
    
    div		r7, r5, r6
    mul		r8, r7, r6
    sub		r8, r5, r8
    beq		r8, r0, skip_3

	add		r2, r2, r5
    
skip_3:
	addi	r5, r5, 3
	ble		r5, r4, loop3
    
    movi	r6, 3
	movi	r5, 0
loop5:
    div		r7, r5, r6
    mul		r8, r7, r6
    sub		r8, r5, r8
    beq		r8, r0, skip_5

	add		r2, r2, r5
    
skip_5:
	addi	r5, r5, 5
	ble		r5, r4, loop5

.data
N:  .word 16
