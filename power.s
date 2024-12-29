# PURPOSE: Program to illustrate how functions work
# This program computes the value of 2^3 + 5^2

.section .data  # No data section needed for this program

.section .text
.globl _start

_start:
    # Calculate 2^3
    push $3
    push $2             # Push first argument (base)
    call power           # Call the power function
    addl $8, %esp        # Clean up the stack
    pushl %eax           # Save the result of 2^3 on the stack

    # Calculate 5^2
    push $2             # Push second argument (exponent)
    push $5             # Push first argument (base)
    call power           # Call the power function
    addl $8, %esp        # Clean up the stack

    # Combine results
    popl %ebx            # Retrieve the result of 2^3 from the stack into %ebx
    addl %eax, %ebx      # Add 5^2 (in %eax) to 2^3 (in %ebx)

    # Exit the program
    movl $1, %eax        # System call for exit
    int $0x80            # Invoke system call

# PURPOSE: Function to compute the value of a number raised to a power
# INPUT:
#   First argument - base number (in stack at 8(%ebp))
#   Second argument - exponent (in stack at 12(%ebp))
# OUTPUT:
#   Returns the result in %eax
# NOTES:
#   The exponent must be 1 or greater

.type power, @function
power:
    pushl %ebp           # Save old base pointer
    movl %esp, %ebp      # Set base pointer to current stack pointer
    subl $4, %esp        # Allocate space for local variable

    movl 8(%ebp), %ebx   # Load base number into %ebx
    movl 12(%ebp), %ecx  # Load exponent into %ecx
    movl %ebx, -4(%ebp)  # Initialize current result with base number

power_loop_start:
    cmpl $1, %ecx        # Check if exponent is 1
    je end_power         # If so, exit the loop

    movl -4(%ebp), %eax  # Load current result into %eax
    imull %ebx, %eax     # Multiply current result by base
    movl %eax, -4(%ebp)  # Store updated result back

    decl %ecx            # Decrement exponent
    jmp power_loop_start # Repeat loop

end_power:
    movl -4(%ebp), %eax  # Move final result to %eax (return value)
    movl %ebp, %esp      # Restore stack pointer
    popl %ebp           # Restore base pointer
    ret                  # Return to caller