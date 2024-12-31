# PURPOSE: Converts all letters in an input file to uppercase and writes them to an output file.
# PROCESSING:
# 1. Open input and output files.
# 2. Read chunks of data from the input file into a buffer.
# 3. Convert each character in the buffer to uppercase if it is a lowercase letter.
# 4. Write the modified buffer to the output file.
# 5. Repeat until the end of the input file.

.section .data
# Constants
.equ SYS_OPEN, 5             # System call numbers
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1

.equ O_RDONLY, 0             # Open file read-only
.equ O_CREAT_WRONLY_TRUNC, 03101 # Create/write-only/truncate flags
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2
.equ LINUX_SYSCALL, 0x80
.equ END_OF_FILE, 0          # Indicates EOF in read syscall
.equ NUMBER_ARGUMENTS, 2

.section .bss
# Buffer for file data (max size 500 bytes)
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE

.section .text
# Stack positions
.equ ST_SIZE_RESERVE, 8
.equ ST_FD_IN, -4
.equ ST_FD_OUT, -8
.equ ST_ARGC, 0
.equ ST_ARGV_0, 4
.equ ST_ARGV_1, 8
.equ ST_ARGV_2, 12

.globl _start
_start:
    # Save stack pointer and allocate space for file descriptors
    movl %esp, %ebp
    subl $ST_SIZE_RESERVE, %esp

# Open input file
open_fd_in:
    movl $SYS_OPEN, %eax
    movl ST_ARGV_1(%ebp), %ebx
    movl $O_RDONLY, %ecx
    movl $0666, %edx
    int $LINUX_SYSCALL
    movl %eax, ST_FD_IN(%ebp)

# Open output file
open_fd_out:
    movl $SYS_OPEN, %eax
    movl ST_ARGV_2(%ebp), %ebx
    movl $O_CREAT_WRONLY_TRUNC, %ecx
    movl $0666, %edx
    int $LINUX_SYSCALL
    movl %eax, ST_FD_OUT(%ebp)

# Main loop: read, convert, write
read_loop_begin:
    movl $SYS_READ, %eax
    movl ST_FD_IN(%ebp), %ebx
    movl $BUFFER_DATA, %ecx
    movl $BUFFER_SIZE, %edx
    int $LINUX_SYSCALL

    # Exit loop if end of file
    cmpl $END_OF_FILE, %eax
    jle end_loop

    # Convert buffer to uppercase
    pushl $BUFFER_DATA
    pushl %eax
    call convert_to_upper
    addl $8, %esp

    # Write the buffer to output file
    movl %eax, %edx
    movl $SYS_WRITE, %eax
    movl ST_FD_OUT(%ebp), %ebx
    movl $BUFFER_DATA, %ecx
    int $LINUX_SYSCALL
    jmp read_loop_begin

end_loop:
    # Close files
    movl $SYS_CLOSE, %eax
    movl ST_FD_OUT(%ebp), %ebx
    int $LINUX_SYSCALL

    movl $SYS_CLOSE, %eax
    movl ST_FD_IN(%ebp), %ebx
    int $LINUX_SYSCALL

    # Exit program
    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL

# Function: Convert buffer to uppercase
# Input: Buffer location and size passed on stack
# Output: Overwrites buffer with uppercase letters
convert_to_upper:
    pushl %ebp
    movl %esp, %ebp

    movl 12(%ebp), %eax      # Buffer address
    movl 8(%ebp), %ebx       # Buffer size
    movl $0, %edi            # Offset

    cmpl $0, %ebx
    je end_convert_loop

convert_loop:
    movb (%eax,%edi,1), %cl  # Current byte
    cmpb $'a', %cl
    jl next_byte
    cmpb $'z', %cl
    jg next_byte
    addb $'A' - 'a', %cl     # Convert to uppercase
    movb %cl, (%eax,%edi,1)
next_byte:
    incl %edi
    cmpl %edi, %ebx
    jne convert_loop

end_convert_loop:
    movl %ebp, %esp
    popl %ebp
    ret
