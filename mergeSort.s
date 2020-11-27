.text
# void sort(signed int *array, unsigned int length);
sort:
  subi		sp, sp, 20
  stw			ra, 16(sp)

# Base case of n <= 1
  movia   r8, 1
  ble     r5, r8, end

  movia   r8, 2
  div     r8, r5, r8
  sub     r9, r5, r8

split:


  end:
    ldw   ra, 16(sp)
    addi  sp, sp, 20
  ret
