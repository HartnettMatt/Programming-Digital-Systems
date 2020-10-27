
.data

.text
.global sum_two
sum_two:
  add     r2, r4, r5
  ret

.global op_three
op_three:
  subi    sp, sp, 8
  stw     ra, 4(sp)

  stw     r6, 0(sp)
  call    op_two
  ldw     r6, 0(sp)

  mov     r4, r2
  mov     r5, r6
  call    op_two

  ldw     ra, 4(sp)
  addi    sp, sp, 8
  ret

.global fibonacci
fibonacci:
  subi      sp, sp, 12
  stw       ra, 8(sp)

  mov       r2, r0
  beq       r4, r0, return

  addi      r2, r2, 1
  beq       r4, r2, return

  stw       r4, 0(sp)
  subi      r4, r4, 1
  call      fibonacci
  mov       r8, r2
  ldw       r4, 0(sp)

  subi      r4, r4, 2
  stw       r8, 4(sp)
  call      fibonacci
  ldw       r8, 4(sp)

  add       r2, r8, r2

return:
  ldw     ra, 8(sp)
  addi    sp, sp, 12
  ret

.end
