
.equ JTAG_UART_BASE, 0xFF201000
.data
STUDENT_NAME_LEN:   .word   0x4         # Length of STUDENT_NAME in bytes
STUDENT_NAME:       .ascii "\x45\x72\x69\x63"

BAD_GRADE:      .ascii "Your grade is an F-\n\0"
GOOD_GRADE:     .ascii "Your grade is an A+! Congrats!\n\0"

.text
# void write_chr(char c);
write_chr:
    movia   r8, JTAG_UART_BASE
  write_chr_L1:
	ldwio	r5, 4(r8)
	srli	r5, r5, 16
	beq		r5, r0, write_chr_L1
    stwio   r4, 0(r8)
    ret


# void write_str(char *str);
write_str:
    addi    sp, sp, -0xc
    stw     ra, 8(sp)
    stw     fp, 4(sp)
    addi    fp, sp, 4
    stw     r4, -4(fp)

  write_str_L1:
    ldw     r8, -4(fp)  # r8 = str
    ldbu    r4, 0(r8)   # *str
    beq     r4, zero, done_write_str    # if (*str == '\0') break

    addi    r8, r8, 1   # str++
    stw     r8, -4(fp)  # store str back to stack
    call    write_chr   # write_chr(*str)

    br write_str_L1
  done_write_str:
    mov     sp, fp
    ldw     fp, 0(sp)
    ldw     ra, 4(sp)
    addi    sp, sp, 8
    ret


# void vulnerable();
vulnerable:
    addi    sp, sp, -0x10
    stw     ra, 12(sp)
    stw     fp, 8(sp)
    addi    fp, sp, 8                   # allocate 8 bytes for local varialbes
                                        # we'll store a local name buffer here
                                        # that we copy from STUDENT_NAME
    
    # Copy STUDENT_NAME to local_name (-8(fp), -7(fp), ...)
    movia   r8, STUDENT_NAME            # r8 = &STUDENT_NAME[0]
    addi    r9, fp, -8                  # r9 = &-8(fp) = &local_name
    movia   r10, STUDENT_NAME_LEN
    ldw     r10, 0(r10)                 # r10 = length of STUDENT_NAME (len)
  vulnerable_L1:
    beq     r10, zero, vulnerable_done  # if we've read all the characters (len==0)
    ldb     r11, 0(r8)                  # read next byte from STUDENT_NAME
    stb     r11, 0(r9)

    addi    r8, r8, 1                   # increment both pointers (STUDENT_NAME and local_name)
    addi    r9, r9, 1
    addi    r10, r10, -1                # len--
    br      vulnerable_L1
    
  vulnerable_done:
    mov     sp, fp
    ldw     ra, 4(sp)                   # HINT...!!!
    ldw     fp, 0(sp)
    addi    sp, sp, 8
    ret
    
print_bad_grade:
    addi    sp, sp, -0x4
    stw     ra, 0(sp)
    movia   r4, BAD_GRADE
    call    write_str
    ldw     ra, 0(sp)
    addi    sp, sp, 0x4
    ret
    
print_good_grade:
    addi    sp, sp, -0x4
    stw     ra, 0(sp)
    movia   r4, GOOD_GRADE
    call    write_str
	break								# If you get here, you win!
    ldw     ra, 0(sp)
    addi    sp, sp, 0x4
    ret


.text
.global _start
_start:
    movia   sp, 0x03FFFFFC

LOOP:
    call    vulnerable
    
    call    print_bad_grade
    
    
  done:
    br done 

