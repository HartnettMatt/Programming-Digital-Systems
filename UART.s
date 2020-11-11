.data
STR: .string "Hello, "

.text
_start:

.text
	movia 	r4, 0xff201000
	movia 	r7, STR
	movia 	r9, 7
    movia	r10, 0x0a

read_chr:
	ldwio 	r11, 0(r6)			 /* read the JTAG UART Data register */
	andi 	r8, r11, 0x8000		 /* check if there is new data */
	beq 	r8, r0, read_chr	 /* if no data, wait */
	add		r7, r7, r9
    stw		r11, 0(r7)
    sub		r7, r7, r9
    addi	r9, r9, 1
    beq		r11, r10, put_chr
    br 		read_chr

put_chr:
	ldwio 	r5, 4(r4) 			#read the control register
	srli	r5, r5, 16 			#Move WSPACE to low 16 bits
	beq		r5, r0, put_chr 	#Loop until WSPACE is 0 (busy wait)
	#FIFO isn't full
	ldb 	r6, 0(r7) 			#pull a character
	stwio 	r6, 0(r4) 			#put into UART
	addi 	r7, r7, 1 			#change byte offset
	subi 	r9, r9, 1 			#adjust counter
	bge 	r9, r0, put_chr 	#loop until enter

	break
