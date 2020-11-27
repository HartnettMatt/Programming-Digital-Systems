.text
# void sort(signed int *array, unsigned int length);
sort:
  subi		sp, sp, 8
  stw			ra, 4(sp)
  stw     r4, 0(sp)
repeat:
  movi     r10, 1
  movi     r11, 0
loop:
  ldw     r8, 0(r4)
  ldw     r9, 4(r4)
  blt     r8, r9, skip
  stw     r9, 0(r4)
  stw     r8, 4(r4)
  movi    r11, 1
skip:
  addi    r4, r4, 4

  addi    r10, r10, 1
  blt     r10, r5, loop

  subi    r5, r5, 1
  ldw     r4, 0(sp)
  bne     r11, r0, repeat

    ldw   r4, 0(sp)
    ldw   ra, 4(sp)
    addi  sp, sp, 8
  ret
