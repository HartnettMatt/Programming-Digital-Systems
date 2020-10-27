#include "address_map_nios2.h"
/*******************************************************************************
 * This program uses the JTAG UART port
 * 1. Prompts the user for their name
 * 2. Prints out a welcome message, and a grade for that user
 *
 * Example:
 * Enter name to receive grade: ERIC
 * Hello, ERIC. Your grade is: F-
 *
 * Can you provide a name that will receive a passing grade (A+)?
 *
 ******************************************************************************/

// Blocking read character from the JTAG UART port
char read_chr()
{
    // volatile int * is used to force ldwio/stwio instructions for those reads/writes
	int data;
	volatile int *JTAG_UART = (volatile int *) JTAG_UART_BASE;
	do {
		data = *(JTAG_UART);			// read the JTAG_UART data register
	} while (!(data & 0x00008000));		// if RVALID == 0, keep looping
	return ((char) data & 0xFF);
}

// Write a character to the JTAG UART port
void write_chr(char c)
{
	volatile int *JTAG_UART = (volatile int *) JTAG_UART_BASE;
	*(JTAG_UART) = c;
}

// Writes a NULL-terminated string (C-string) to the JTAG UART port
void write_str(char *str)
{
	for (str; *str != 0; str++) {
		write_chr(*str);
	}
}

// Reads characters from JTAG UART port until
// a line break ('\n') character is received.
// Stores the result in the string pointed to by str
void read_line(char *str)
{
	char c;
	while (1) {
		// Read one character
		c = read_chr();

		// Echo it back
		write_chr(c);

		if (c == '\n') {
			// If it's a line break, return.
			break;
		}
		// Store it in str
		*str++ = c;
	}
	*str = '\0';	// Null terminate the output string
}

// Hint: This function was hastily written,
// and may have mistakes that benefit the student
void grade()
{
	char name[10];
	char grade[3] = {'F', '-', '\0'};	// Everyone fails! Bah humbug!

	read_line(name);
	name[9] = '\0';		// Null terminate name, in case those
                        // students try something clever...

	write_str("Hello, ");
	write_str(name);

	// Deliver the bad news!
	write_str(". Your grade is: ");
	write_str(grade);
	write_str("\n");
}


int main(void)
{
	char *welcome_msg = "Enter name to receive grade:";

	while (1) {
		write_str(welcome_msg);
		grade();
		write_str("\n");
	}
}

