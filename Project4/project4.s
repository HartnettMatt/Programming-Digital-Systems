.data
DELAY: .word 35000000
COUNT: .word 0

.text
.equ    HEX, 0xff200020

# ISR:
.section .exceptions, "ax"
# ISR Prologue
    subi    sp, sp, 36
    stw     et, 0(sp)
    stw     r3, 4(sp)
    stw     r4, 8(sp)
    stw     r5, 12(sp)
    stw     r6, 16(sp)
    stw     r16, 20(sp)
    stw     r17, 24(sp)
    stw     r18, 28(sp)
    stw     r19, 32(sp)

    rdctl   et, ipending        # check for external interrupts
    beq     et, r0, skip_dec
    subi    ea, ea, 4           # decrement exception address

  skip_dec:
  # check if its a button (external) or the timer (internal)
  # IRQ1: buttons
    movi    r5, 0b10
    and     r5, et, r5
    bne     r5, r0, handle_button

    # IRQ0: interval timer
    movi    r5, 0b1
    and     r5, et, r5
    bne     r5, r0, handle_timer

    # should never get here
    br      leave_isr

  handle_timer:
    # interval timer location
    movia   r4, 0xff202000
    movi    r5, 0b10

    # Reset the counter
    movia   r16, COUNT
    movi    r17, 1
    stw     r17, 0(r16)
    movia   r16, 0

    # Clear the interrupt
    sthio   r5, 0(r4)
    br      leave_isr

  handle_button:
    # stop and reset time
    movia   r18, 0xff202000
    ldwio   r5, 4(r18)
    ori     r5, r5, 0b1000
    stwio   r5, 4(r18)
    ldwio   r5, 0(r18)
    ori     r5, r5, 0b1
    stwio   r5, 0(r18)

    movia   r4, 0xff200050
    ldwio   et, 12(r4)          # edge capture register

    movia   r5, DELAY
    ldw   r17, 0(r5)
    movi    r5, 2
    beq     et, r0, done_btn
    beq     et, r5, btn_1

  btn_0:                        # Speed up timer by .05 seconds
    movia   r6, 20000000
    beq     r17, r6, done_btn

    movia   r6, 5000000
    sub     r17, r17, r6

    br      done_btn

  btn_1:                        # Slow down timer by .05 seconds
    movia   r6, 50000000
    beq     r17, r6, done_btn

    movia   r6, 5000000
    add     r17, r17, r6

  done_btn:
    # Update memory (DELAY) to new delay time (r17)
    movia   r5, DELAY
    stw     r17, 0(r5)

    # Update interval timer delay time by splitting r17 in half
    # Counter start value (low)
    sthio   r17, 8(r18)
    srli    r17, r17, 16
    # Counter start value (high)
    sthio   r17, 12(r18)

    # start the timer
    ldwio   r5, 4(r18)
    ori     r5, r5, 0xb100
    stwio   r5, 4(r18)

    stwio   et, 12(r4)          # Button interrupt clear

  # ISR epilogue
  leave_isr:
    ldw     r19, 32(sp)
    ldw     r18, 28(sp)
    ldw     r17, 24(sp)
    ldw     r16, 20(sp)
    ldw     r6, 16(sp)
    ldw     r5, 12(sp)
    ldw     r4, 8(sp)
    ldw     r3, 4(sp)
    ldw     et, 0(sp)
    addi    sp, sp, 36
    eret

.text
.global wait
# Loops until counter finishes and generates an exception
wait:
  movia r13, COUNT
  ldw   r12, 0(r13)
  beq   r12, r0, wait
  ret

.global _start
_start:
    movia   sp, 0x3fffffc

    # 1. Configure peripheral (push buttons)
    movia   r16, 0xff200050     # Address of the buttons
    movi    r5, 0b11            # Value of interrupt mask
    stwio   r5, 8(r16)          # Change the interrupt mask register

    # 1. Configure peripheral (interval timer)
    movia   r16, 0xff202000     # Address of first interval timer
    movia   r5, 35000000        # Starting speed of .35 second delay
    # Split initial counter value into two parts (high and low)
    sthio   r5, 8(r16)
    srli    r5, r5, 16
    sthio   r5, 12(r16)
    # Configure counter control register
    movi    r5, 0b111
    sthio   r5, 4(r16)
    movi    r5, 0b10

    # 2. Enable peripheral to generate interrupts
    # Enable IRQ #0 (timer) and IRQ #1 (buttons)
    movi    r5, 0b11
    wrctl   ienable, r5

    # 3. Enable global interrupts with the PIE bit
    movi    r5, 1
    wrctl   status, r5

    # set
    movia   r19, COUNT
    movia   r16, HEX

    movi    r4, 0

# This loop creates the actual pattern that is displayed on HEX
loop:
      # H
      slli	r4, r4, 8     # move the previous character to the left
      addi	r4, r4, 0x76  # Add the "H" into r4
      stwio	r4, 0(r16)    # Display the new charcter
      stw   r0, 0(r19)
      call  wait         # Dalay for the time found in DELAY
      #repeat this sequence with the letters and patterns

      # E
      slli	r4, r4, 8
      addi	r4, r4, 0x79
      stwio	r4, 0(r16)
      stw   r0, 0(r19)
      call  wait

      # L
      slli	r4, r4, 8
      addi	r4, r4, 0x38
      stwio	r4, 0(r16)
      stw   r0, 0(r19)
      call  wait

      # L
      slli	r4, r4, 8
      addi	r4, r4, 0x38
      stwio	r4, 0(r16)
      stw   r0, 0(r19)
      call  wait

      # O
      slli	r4, r4, 8
      addi	r4, r4, 0x3F
      stwio	r4, 0(r16)
      stw   r0, 0(r19)
      call  wait

      # " "
      slli	r4, r4, 8
      addi	r4, r4, 0x00
      stwio	r4, 0(r16)
      stw   r0, 0(r19)
      call  wait

      # B
      slli	r4, r4, 8
      addi	r4, r4, 0x7F
      stwio	r4, 0(r16)
      stw   r0, 0(r19)
      call  wait

      # U
      slli	r4, r4, 8
      addi	r4, r4, 0x3E
      stwio	r4, 0(r16)
      stw   r0, 0(r19)
      call  wait

      # F
      slli	r4, r4, 8
      addi	r4, r4, 0x71
      stwio	r4, 0(r16)
      stw   r0, 0(r19)
      call  wait

      # F
      slli	r4, r4, 8
      addi	r4, r4, 0x71
      stwio	r4, 0(r16)
      stw   r0, 0(r19)
      call  wait

      # S
      slli	r4, r4, 8
      addi	r4, r4, 0x6D
      stwio	r4, 0(r16)
      stw   r0, 0(r19)
      call  wait

      # " "
      slli	r4, r4, 8
      addi	r4, r4, 0x00
      stwio	r4, 0(r16)
      stw   r0, 0(r19)
      call  wait

# infinite loop
    br      loop
