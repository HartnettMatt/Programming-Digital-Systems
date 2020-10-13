.data
str:
     .word 0x76
     .word 0x79
     .word 0x38
     .word 0x38
     .word 0x3f
     .word 0x00
     .word 0x7f
     .word 0x3E
     .word 0x71
     .word 0x71
     .word 0x6D
     .word 0x40
     .word 0x40
     .word 0x40
     .word 0x00
     .word 0x00
     .word 0x00
     .word 0x00
.text
.equ	LEDs,		0xFF200000
.equ	HEXa,	0xFF200020
.equ   HEXb, 0xFF200030
.global _start
_start:
  movia	r2, LEDs			# Address of LEDs
  movia	r3, HEXa	# Address of HEX[3:0]
  movia r4, HEXb  # Address of HEX[5:4]
reset:
  movia r7, 18    # Number of characters
  movia r9, 0
  movia r11, 0
  movia r21, 0
  movia r20, 0x150000

busy_loop0:
  addi r21, r21, 1
  blt r21, r20, busy_loop0
  movia r21, 0
hello:
# Get the next word in the array
  movia r5, str
  muli  r10, r9, 4
  add   r5, r5, r10
  ldw   r8, 0(r5)

#Store the word into r11
  slli  r11, r11, 8
  add   r11, r11, r8
  stwio	r11, 0(r3)

#Advance counter and loop
  addi r9, r9, 1
  blt	r9, r7, busy_loop0

movia r6, 1 # r6==0 => display pattern B, r6==1 => display pattern A
movia r7, 3 # Number of pattern A displays minus 1
movia r8, 0 # Counter of pattern A displays
busy_loop1:
  addi r21, r21, 1
  blt r21, r20, busy_loop1
  movia r21, 0
  beq r6, r0, pB
pA:
  movia r5, 0x49494949
  movia r6, 0
  stwio r5, 0(r3)
  addi r8, r8, 1
  br busy_loop1
pB:
  movia r5, 0x36363636
  movia r6, 1
  stwio r5, 0(r3)
  beq r7, r8, blank
  br busy_loop1

blank:
  movia r6, 1 # r6==0 => display all off, r6==1 => display all on
  movia r7, 3 # Number of pattern A displays minus 1
  movia r8, 0 # Counter of pattern A displays
  busy_loop2:
    addi r21, r21, 1
    blt r21, r20, busy_loop2
    movia r21, 0
    beq r6, r0, allOff
  allOn:
    movia r5, 0xffffffff
    movia r6, 0
    stwio r5, 0(r3)
    addi r8, r8, 1
    br busy_loop2
  allOff:
    movia r5, 0x0
    movia r6, 1
    stwio r5, 0(r3)
    beq r7, r8, reset
    br busy_loop2

break
.end
