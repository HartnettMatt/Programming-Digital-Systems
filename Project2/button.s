# My sincerest apologies to anyone who has to read this spaghetti
.data
#p1 has the first pattern, which is meant to scroll from right to left
p1:
     .word 0x79
     .word 0x49
     .word 0x49
     .word 0x49
     .word 0x00
     .word 0x00
     .word 0x00
     .word 0x00
# p2 has the second pattern, which is meant to scroll from left to right
p2:
    .word 0x4f
    .word 0x49
    .word 0x49
    .word 0x49
    .word 0x00
    .word 0x00
    .word 0x00
    .word 0x00
.text
# Define I/O:
.equ	HEX,	0xFF200020
.equ  KEY,  0xFF200050
.global _start
_start:
  movia	r2, KEY			# Address of buttons
  movia	r3, HEX	    # Address of HEX[3:0]
  call reset

# The busy-wait that provides a delay and checks if the buttons have been changed
busy_loop0:
# Counter loop that holds the program off
  addi r20, r20, 1
  blt r20, r19, busy_loop0
  movia r20, 0

# Check to see if the buttons have been changed
  ldwio r13, 0(r2)
  bne r4, r13, change

# Hold point after changing between rtl or ltr
sequence:
  beq r6, r0, ltr

# The right to left sequence
rtl:
# Get the next word in the array
  movia r5, p1
  muli  r10, r9, 4
  add   r5, r5, r10
  ldw   r8, 0(r5)

# Store the word into r11 and push the old value to the left
  slli  r11, r11, 8
  add   r11, r11, r8
  stwio	r11, 0(r3)

# Advance counter and loop
  addi r9, r9, 1
  blt	r9, r7, busy_loop0
  br _start

# The left to right sequence
ltr:
# Get the next word in the array
  movia r5, p2
  muli  r10, r9, 4
  add   r5, r5, r10
  ldw   r8, 0(r5)

# Store the word into r11 and push the old value to the right
  srli  r11, r11, 8
  slli  r8, r8, 24
  add   r11, r11, r8
  stwio	r11, 0(r3)

# Advance counter and loop
  addi r9, r9, 1
  blt	r9, r7, busy_loop0
  br _start

# Switches r6, the control register for rtl versus ltr
change:
  call reset
  nor r6, r6, r12
  br sequence

#Cleans up registers that are used intermittedly as counters and I/O values
  reset:
    movia r7, 8          # Number of characters
    movia r9, 0          # Counter in rtl and ltr loops
    movia r11, 0         # Value to be pushed onto the HEX display
    movia r20, 0         # Counter used in busy-wait loop
    movia r19, 0x150000  # Maximum value of r20 in busy-wait loop
    ldwio r4, 0(r2)      # Check the value of the buttons
    stwio	r0, 0(r3)      # Clear the HEX display
    ret


.end
