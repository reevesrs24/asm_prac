# Purpose: This program converts an input file to an output file with all letters converted to uppercase
#
#
#

# Processing: 1) Open the input file
#             2) Open the ouput file
#             3) While were not at the end of the inut file
#                   a) read part of the file into our piece of memory
#                   b) go through each byte of memory, convert all lowercase letters to uppercase
#                   c) write the piece of memry to the output file
#

.section .data

# CONSTANTS  #
.equ OPEN, 5
.equ WRITE, 4
.equ READ, 3
.equ CLOSE, 6
.equ EXIT, 1

.equ OPEN_READ_ONLY, 0
.equ OPEN_CREATE_WRITE_ONLY_TRUNC, 03101 

.equ LINUX_SYSCALL, 0x80 # System call interrupt
.equ END_OF_FILE, 0 # This is the return value of read
                                # which means we've hit the end of the file

# BUFFERS #
.section .bss
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE # Assembler directive to reserve lengthbytes for a local common

# Program Code #
.section .text

.equ ST_SIZE_RESERVE, 8
.equ ST_FD_IN, 0
.equ ST_FD_OUT, 8
.equ ST_ARGC, 16 # Number of arguments
.equ ST_ARGV_0, 24 # Name of program
.equ ST_ARGV_1, 32 # Input File Name
.equ ST_ARGV_2, 40 # Output file name

.globl _start

_start:
    # Initiliaze Program #
    sub $ST_SIZE_RESERVE, %rsp # Allocate space for our pointers on the stack
    mov %rsp, %rbp

open_files:
open_fd_in:
    # Open input file #
    mov ST_ARGV_1 (%rbp), %rbx # input filename into %ebx
    mov $OPEN_READ_ONLY, %rcx # read only flag
    mov $0666, %rdx # Set file permission, doesnt matter for reading
    mov $OPEN, %rax # open syscall
    int $LINUX_SYSCALL

store_fd_in:
    mov %rax, ST_FD_IN(%rbp) # save the given file descriptor

open_fd_out:
    # Open output file #
    mov ST_ARGV_2 (%rbp), %rbx # output file name into %rbx
    mov $OPEN_CREATE_WRITE_ONLY_TRUNC, %rcx # flags for writing to the file
    mov $0666, %rdx # permissions for new file created
    mov $OPEN, %rax # Open the file
    int $LINUX_SYSCALL

store_fd_out:
    mov %rax, ST_FD_OUT(%rbp) # store the file descriptor here

# Begin main loop #
read_loop_begin:
    
    # Read in a block from the input file #
    mov ST_FD_IN(%rbp), %rbx # Get the input file descriptor
    mov $BUFFER_DATA, %rcx    # the location to read into
    mov $BUFFER_SIZE, %rdx    # the size of the buffer
    mov $READ, %rax           
    int $LINUX_SYSCALL        # size of the buffer read is returned into %eax

    # Exit if we have reached the end #
    cmp $END_OF_FILE, %rax        # check for end of file marker
    jle end_loop                  # if found go to the end

continue_read_loop:
    # convert the block to upper case #
    push $BUFFER_DATA          # Location of the buffer
    push %rax                  # size of the buffer
    call convert_to_upper     
    pop %rax
    pop %rbx

    # write the block to the output file #
    mov ST_FD_OUT(%rbp), %rbp  # file to use
    mov $BUFFER_DATA, %rcx     # location of the buffer
    mov %rax, %rdx
    int $LINUX_SYSCALL

    # contninue the loop #
    jmp read_loop_begin

end_loop:
    # Close the file #
    mov ST_FD_OUT(%rbp), %rbx
    mov $CLOSE, %rax
    int $LINUX_SYSCALL

    mov ST_FD_IN(%rbp), %rbx
    mov $CLOSE, %rax
    int $LINUX_SYSCALL

    # exit #
    mov $0, %rbx
    mov $EXIT, %rax
    int $LINUX_SYSCALL

# FUNCTION: Convert to upper #
#
#
# Purpose: Converts a lower case letter to its upper case
#
#
# Input: The first location is the block of memory to convert
#        The second parameter is the length of the buffer
#
# Output: The function overwrites the buffer with the upper case version
#
# Variables: 
#           %eax - beginning of the buffer
#           %ebx - the length of the buffer
#           %edi - current buffer offset
#           %cl  - current byte being examines (%cl is the first byte of %ecx)
#

# Constants #
.equ LOWERCASE_A, 'a'  # The lower boundary of our search
.equ LOWERCASE_Z, 'z'  # The upper boundary of our search
.equ UPPER_CONVERSION, 'A' - 'a' # Conversion between upper and lower case

# Stack Positions #
.equ ST_BUFFER_LEN, 8     # Length of Buffer
.equ ST_BUFFER, 12        # actual buffer

convert_to_upper:
    push %rbp
    mov %rsp, %rbp

    # Set up variables #
    mov ST_BUFFER(%rbp), %rax
    mov ST_BUFFER_LEN(%rbp), %rbx
    mov $0, %rdi 

    # buffer with a zero length -> leave
    cmp $0, %rbx
    je end_convert_loop

    convert_loop:
        # get the current byte
        movb (%rax, %rdi, 1), %cl

        # Go to the next byte unless it is between 'a' and 'z'
        cmpb $LOWERCASE_A, %cl
        jl next_byte
        cmpb $LOWERCASE_Z, %cl
        jg next_byte

        # Otherwise convert the byte to uppercase
        addb $UPPER_CONVERSION, %cl
        # and store it back
        movb %cl, (%rax, %rdi, 1)
    next_byte:
        inc %rdi       # next byte
        cmp %rdi, %rbx # continue unless weve reached the end
        jne convert_loop

    end_convert_loop:
        # no return value, just leave
        mov %rbp, %rsp
        pop %rbp
        ret






