.data
TIME: .word 50000000
COUNT: .word 0

.text
.equ    HEX, 0xff200020
.equ    wait, 10000000

####################
# Exception handler
.section .exceptions, "ax"
    subi    sp, sp, 36          # allocate stack
    stw     et, 0(sp)           # save all the registers we will use in our handler
    stw     r3, 4(sp)
    stw     r4, 8(sp)
    stw     r5, 12(sp)
    stw     r6, 16(sp)
    stw     r16, 20(sp)
    stw     r18, 24(sp)
    stw     r20, 28(sp)
    stw     r22, 32(sp)

    rdctl   et, ipending        # Check for external interrupt
    beq     et, r0, skip_dec    # if internal go to skip_dec
    subi    ea, ea, 4           # decrement ea one instruction if external

  skip_dec:                     # check if external or internal interrupt (external = button and internal = timer)
    movi    r5, 0b1 << 1        # IRQ1: buttons
    and     r5, et, r5
    bne     r5, r0, handle_button # if ext->button

    movi    r5, 0b1 << 0        # IRQ0: timer
    and     r5, et, r5
    bne     r5, r0, handle_timer

    br      leave_isr           # unknown interrupt?

  handle_timer:
    movia   r4, 0xff202000      # timer0 MMIO
    movi    r5, 0b10            # RUN=1, TO=0

    movia   r16, COUNT
    movi    r18, 1
    stw     r18, 0(r16)         # store new COUNT
    movia   r16, 0              # clear r16

    sthio   r5, 0(r4)           # Clear timer interrupt
    br      leave_isr

  handle_button:
    # stop and reset time
    movia   r20, 0xff202000
    ldwio   r5, 4(r20)
    ori     r5, r5, 0b1000    #bitmask to the stop bit
    stwio   r5, 4(r20)
    ldwio   r5, 0(r20)
    ori     r5, r5, 0b1       #bitmask to TO register to reset timer to 0
    stwio   r5, 0(r20)

    # Figure out which push button was pressed
    movia   r4, 0xff200050      # button mmio address
    ldwio   et, 12(r4)          # edge capture register

    movia   r5, TIME
    ldwio   r18, 0(r5)
    movi    r5, 2
    beq     et, r0, done_btn    # if no button press
    beq     et, r5, btn_1       # if btn1 pressed

  btn_0:                        # else, its btn0
    movia   r6, 20000000
    beq     r18, r6, done_btn

    movia   r6, 10000000
    sub     r18, r18, r6

    br      done_btn

  btn_1:
    movia   r6, 80000000
    beq     r18, r6, done_btn

    movia   r6, 10000000
    add     r18, r18, r6

  done_btn:
    movia   r5, TIME            # r5 =  address of delay time (TIME)
    stw     r18, 0(r5)          # reset delay time (TIME) to new delay time

    # give timer new delay time
    sthio   r18, 8(r20)         # low counter
    srli    r18, r18, 16        # get the high 16 bits
    sthio   r18, 12(r20)        # high counter

    # start the timer
    ldwio   r5, 4(r20)
    ori     r5, r5, 0xb100
    stwio   r5, 4(r20)

    stwio   et, 12(r4)          # Clear the push button interrupt
                                # Note: despite documentation,
                                # you must write 1s to clear edgecapture reg

  leave_isr:                    # epilogue
    ldw     r22, 32(sp)
    ldw     r20, 28(sp)
    ldw     r18, 24(sp)
    ldw     r16, 20(sp)
    ldw     r6, 16(sp)          # restore used registers
    ldw     r5, 12(sp)
    ldw     r4, 8(sp)
    ldw     r3, 4(sp)
    ldw     et, 0(sp)
    addi    sp, sp, 36          # deallocate stack
    eret

.text
.global DELAY
DELAY:
  movia r13, COUNT
  ldw   r12, 0(r13)
  beq   r12, r0, DELAY      # loop DELAY until there is a timer interrupt
  ret

.global _start
_start:
    movia   sp, 0x04000000 - 4

    # 1.1 Configure peripheral (push buttons)
    movia   r16, 0xff200050 # PUSH_BTN base addr
    movi    r7, 0b11        # mask bits for push buttons
    stwio   r7, 8(r16)      # interrupt mask register (push buttons)

    # 1.2 Configure timer0
    movia   r16, 0xff202000 # stores location of the HEX display into r16
    movia   r7, 50000000    # 100M * 100MHz = 1 Hz
    sthio   r7, 8(r16)      # low counter start
    srli    r7, r7, 16      # get high 16 bits
    sthio   r7, 12(r16)     # high counter start

    movi    r7, 0b111       # START=1, CONT=1, ITO=1
    sthio   r7, 4(r16)
    movi    r7, 0b10        # RUN=1

    # 2 enable peripheral to generate interrupts
    movi    r7, 0b1 << 1    # IRQ #1 (Push buttons)
    ori     r7, r7, 0b1 << 0# IRQ #0 (interval timer)
    wrctl   ienable, r7

    # 3. turn on interrupts globally
    movi    r7, 1
    wrctl   status, r7

    # set
    movia   r22, COUNT
    movia   r16, HEX

    movi    r4, 0
loop:
      slli	r4, r4, 8     # shift r4 left by 8 bits
      addi	r4, r4, 0x76  # store the H value into r4  (r4=r4+H(inhex))
      stwio	r4, 0(r16)    # store the value of r4 into r20 or into the HEX display
      stw   r0, 0(r22)    # set r2 as Delay -> the amount to delay in busy_wait
      call  DELAY         # calls the Busy wait function

      #repeat this with all the letters and patterns
      slli	r4, r4, 8
      addi	r4, r4, 0x79  # store E into r4
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      slli	r4, r4, 8
      addi	r4, r4, 0x38   # store L into r4
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      slli	r4, r4, 8
      addi	r4, r4, 0x38   # store L into r4
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      slli	r4, r4, 8
      addi	r4, r4, 0x3F   # store O into r4
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      slli	r4, r4, 8
      addi	r4, r4, 0x7F   # store B into r4
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      slli	r4, r4, 8
      addi	r4, r4, 0x3E   # store U into r4
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      slli	r4, r4, 8
      addi	r4, r4, 0x71   # store F into r4
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      slli	r4, r4, 8
      addi	r4, r4, 0x71   # store F into r4
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      slli	r4, r4, 8
      addi	r4, r4, 0x6D   # store S into r4
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      slli	r4, r4, 8
      addi	r4, r4, 0x40   # store - into r4
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      slli	r4, r4, 8
      addi	r4, r4, 0x40   # store - into r4
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      slli	r4, r4, 8
      addi	r4, r4, 0x40   # store - into r4
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      movia	r4, 0x49494949
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      movia r4, 0x36363636
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      movia	r4, 0x49494949
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      movia r4, 0x36363636
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      movia	r4, 0x49494949
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      movia r4, 0x36363636
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      movia r4, 0x7f7f7f7f
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      movia r4, 0x00000000
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      movia r4, 0x7f7f7f7f
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      movia r4, 0x00000000
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      movia r4, 0x7f7f7f7f
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

      movia r4, 0x00000000
      stwio	r4, 0(r16)
      stw   r0, 0(r22)
      call  DELAY

    br      loop
