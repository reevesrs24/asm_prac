# Purpose: The program finds the maximum number given a set of data items
#
#

# Variables: The registers have the follwing uses:
#
# %edi - Holds the index of the data item being examined
# %ebx - largest data item found 
# %eax - Current data item
# 
# The following memory locations are used
# 
# data_items - contains the item data.  A 0 is used to terminate the data

.section .data
    data_items: 
        .long 1, 2, 3, 4, 5, 6, 7, 8, 9, 0

.section .text

.globl _start

_start: 
    mov $0, %edi # Move 0 into the index register
    mov data_items(, %edi, 4), %eax # Load the first byte of data
    mov %eax, %ebx # since this is the first time %eax is the biggest

    start_loop: # start loop
        cmp $0, %eax # check to see if we are at the end of data_items
        je loop_exit
        inc %edi # Load next value
        mov data_items(, %edi, 4), %eax
        cmp %ebx, %eax # compare values
        jle start_loop # jump to loop beginning if the new value is not larger

        mov %eax, %ebx # move the value as the largest
        jmp start_loop # jump to loop beginning

    loop_exit: # %ebx is the return value
        mov $1, %eax # $1 is the exit() syscall
        int $0x80 # call interrupt