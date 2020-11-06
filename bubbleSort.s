.text


_start:
	movia		sp, 0x3fffffc
pass:
	movia		r16, N
	ldw			r17, 0(r16)
	subi		r17, r17, 1
	movia 		r16, SORT
loop:
	ldw			r18, 0(r16)
	addi		r16, r16, 4
	ldw			r19, 0(r16)
	ble			r18, r19, label1
	stw			r18, 0(r16)
	subi		r16, r16, 4
	stw			r19, 0(r16)
	addi		r16, r16, 4
label1:
	subi		r17, r17, 1
	bgt 		r17, r0, loop

	call 		check_sort
	beq			r2, r0, pass
	break
	
.global check_sort
# returns 0 if not sorted, 1 if sorted
check_sort:
	subi		sp, sp, 20
	stw			ra, 16(sp)
	stw			r16, 12(sp)
	stw			r17, 8(sp)
	stw			r18, 4(sp)
	stw			r19, 0(sp)
	
	movia		r16, N
	ldw			r17, 0(r16)
	subi		r17, r17, 1
	movia 		r16, SORT
	
loop1:
	ldw			r18, 0(r16)
	addi		r16, r16, 4
	ldw			r19, 0(r16)
	
	mov			r2, r0
	bge			r18, r19, end_check # failed, not sorted
	movia		r2, 1
	
	subi		r17, r17, 1
	bgt 		r17, r0, loop1
	
end_check:
	ldw			r19, 0(sp)
	ldw			r18, 4(sp)
	ldw			r17, 8(sp)
	ldw			r16, 12(sp)
	ldw			ra, 16(sp)
	addi		sp, sp, 20
	ret
	
.data
N: .word 5
SORT: .word 8, 3, 7, 2, 9
# Padding
.rept 100 .word 0
.endr