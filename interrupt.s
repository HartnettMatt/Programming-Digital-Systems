.data
COUNT: .word 0
.text
.section .reset, "ax" # Reset section (address 0x0)
	br		_start
.section .exceptions, "ax" # ISR here
	subi 	sp, sp, 16
	stw		et, 0(sp)
	stw		r4, 4(sp)
	stw		r5, 8(sp)
	stw		r6, 12(sp)
	rdctl	et, ipending # check for external interrupts
	beq		et, r0, skip_dec
	subi		ea, ea, 4 #decrement exception address
skip_dec:
	# Check if a button pressed, and which one
handle_button:
	movia	r4, 0xff20050
	ldwio	et, 12(r4) # read from the edge capture of the button
	beq		et, r0, done_btn
	movia	r4, COUNT
	ldw		r6, 0(r4)
	movi 	r5, 1
	beq		et, r5, btn_0
btn_1:
	addi 	r6, r6, 1
	br 		done_btn
btn_0:
	subi		r6, r6, 1

done_btn:
	movia	r4, COUNT
	stw		r6, 0(r4)
	movia	r4, 0xff200000
	stwio	r6, 0(r4) # write to LEDs
	movia	r4, 0xff200050
	stwio	et, 12(r4) # clear the push button interrupt

leave_isr:
	ldw		r6, 12(sp)
	ldw		r5, 8(sp)
	ldw		r4, 4(sp)
	ldw		et, 0(sp)
	addi		sp, sp, 16
	eret # restores status register and returns to where ea left off
.global _start
_start:
	movia		sp, 0x3fffffc
	# 1. Configure the peripheral to generate interrupts
	movia		r4, 0xff20050
	movia		r5, 0b11
	stwio		r5, 8(r4)
	# 2. Enable peripheral to generate interrupts
	movi		r6, 0b10# set IRQ #1 (push buttons)
	wrctrl		ienable, r6 # Need a special command to write to control registers, this enables button interrupts
	# 3. Enable global interrupts - Processor Interrupt Enable (PIE)
	movi		r6, 0b1 # PIE is the first bit of the status register
	wrctrl		status, r6 # set PIE to 1
IDLE:
	br	 IDLE
