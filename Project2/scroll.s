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
  movia r7, 18    # Number of characters
  movia r9, 0
  movia r11, 0
LOOP:
# Get the next word in the array
  movia r5, str
  muli  r10, r9, 4
  add   r5, r5, r10
  ldw   r8, 0(r5)

#Handle HEX[5:4]
    srli  r12, r11, 24
    slli  r13, r13, 8
    add   r13, r13, r12
    stwio r13, 0(r4)

#Store the word into r11
  slli  r11, r11, 8
  add   r11, r11, r8
  stwio	r11, 0(r3)

#Advance counter and loop
  addi r9, r9, 1
  blt	r9, r7, LOOP
break
.end
