# Factorial
#
#

.section .data

# No Gloabl Data

.section .text

.globl _start
.globl _factorial # This is uneeded unless we want to share this function among other programs

_start:
    push $5        # The factorial takes one argument - the number we want the factorial of

    call factorial # run the factorial function
    pop %rbx       # pop anything that you have pushed
    mov %rax, %rbx # factorial returns the answer in %eax, but we want it in %ebx
    mov $1, %rax   # call kernel exit function
    int $0x80

.type factorial, @function

factorial:
    push %rbp
    mov  %rsp, %rbp
    mov  16(%rbp), %rax # This moves the first argument into %eax
                        # 4(%ebp) holds the return address
                        # 8(%ebp) holds the the address of the first parameter

    cmp  $1, %rax       # if the number is 1, that is our base case and we simply
                        # 1 is already in %eax as the return value

    je  end_factorial

    dec  %rax
    push %rax # push it for our next call to factorial
    call factorial
    pop  %rbx # this is the number we called factorial with
              # we have to pop it off, but we also need it to find the
              # number we were called with
    inc  %rbx # which is one more than we pushed with

    imul %rbx, %rax

end_factorial:
    mov  %rbp, %rsp
    pop  %rbp
    ret

