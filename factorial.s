.text
factorial:
    # Write your code here
	subi		sp, sp, 8
    stw			ra, 0(sp)

    # Base case of f(0) = 1
    movi		r2, 1
    beq			r0, r4, END

    stw			r4, 4(sp)  # store n
    subi		r4, r4, 1  # n-1
    call		factorial  # f(n-1)
    ldw			r4, 4(sp)  # retrieve n
    mul			r2, r4, r2 # calculate n*f(n-1)

END:
    ldw			ra, 0(sp)
    addi		sp, sp, 8
    ret
