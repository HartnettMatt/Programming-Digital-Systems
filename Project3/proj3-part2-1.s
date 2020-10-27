.equ JTAG_UART_BASE, 0xFF201000
.data
WELCOME:    .ascii "Enter name for grade: \0"
HELLO:      .ascii "Hello, \0"
YOUR_GRADE: .ascii ". Your grade is: \0"
ENDL:        .ascii "\n\0"

.text
# char read_chr();
read_chr:
    movia   r8, JTAG_UART_BASE
    ldwio   r9, 0(r8)
    andi    r10, r9, 0x8000
    beq     r10, zero, read_chr     # keep reading if RAVAIL == 0
    andi    r2, r9, 0xff            # return data
    ret

# void write_chr(char c);
write_chr:
    movia   r8, JTAG_UART_BASE
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


# void read_line(char *str)
read_line:
    addi    sp, sp, -0x10
    stw     ra, 12(sp)
    stw     fp, 8(sp)
    addi    fp, sp, 8
    stw     r4, -4(fp)  # -4(fp) = str
                        # -8(fp) = c
  read_line_L1:
    call    read_chr        # read a character
    stw     r2, -8(fp)      # store c to the stack

    # echo back to UART
    mov     r4, r2
    call    write_chr

    ldw     r8, -8(fp)              # c
    movi    r9, 0x0a                # '\n'
    beq     r8, r9, done_read_line  # if (c == '\n') break

    ldw     r10, -4(fp)         # str
    stb     r8, 0(r10)          # *str = c
    addi    r10, r10, 1         # str++
    stw     r10, -4(fp)

    br      read_line_L1


  done_read_line:
    # write '\0' to end of string
    ldw     r10, -4(fp)     # str
    stb     zero, 0(r10)    # *str = '\0'

    mov     sp, fp
    ldw     fp, 0(sp)
    ldw     ra, 4(sp)
    addi    sp, sp, 8
    ret



grade:
    addi    sp, sp, -0x18   # allocate 24 bytes
    stw     ra, 20(sp)      # store ra
    stw     fp, 16(sp)      # store fp
    addi    fp, sp, 16      # setup our fp
                            # we'll allocate 3 bytes for grade (-3(fp), -2(fp), -1(fp))
                            # and 10 bytes for name (-4(fp), -5(fp), ... , -13(fp)), leaving 3 bytes unused
    # Store "F-\0" to grade[]
    movi    r8, 0x46      # F
    stb     r8, -3(fp)
    movi    r8, 0x2d      # -
    stb     r8, -2(fp)
    stb     zero, -1(fp) # '\0'

    addi    r4, fp, -13
    call    read_line    # read_line(name)

    # Null terminate name, just in case
    stb     zero, -4(fp)

    movia   r4, HELLO
    call    write_str

    addi    r4, fp, -13
    call    write_str

    movia   r4, YOUR_GRADE
    call    write_str

    addi    r4, fp, -3
    call    write_str

    mov     sp, fp
    ldw     ra, 4(sp)
    ldw     fp, 0(sp)
    addi    sp, sp, 8
    ret


.global _start
_start:
    movia   sp, 0x03FFFFFC

LOOP:
    movia   r4, WELCOME
    call    write_str

    call    grade

    movia   r4, ENDL
    call    write_str
    br      LOOP
