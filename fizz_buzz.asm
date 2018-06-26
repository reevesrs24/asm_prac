
SECTION .data
    Fizz: db "Fizz",10
    FIZZLEN: equ $-Fizz
    Buzz: db "Buzz",10
    BUZZLEN: equ $-Buzz
    FizzBuzz: db "FizzBuzz",10
    FIZZBUZZLEN: equ $-FizzBuzz
    Count: equ 101

SECTION .bss
    

SECTION .text

Print_Div_3:
    push rcx
    mov rax, 4  ; Specify sys write call
    mov rbx, 1  ; Specify file descriptor 1: standard out
    mov rcx, Fizz
    mov rdx, FIZZLEN
    int 80h
    pop rcx
    jmp Loop

Print_Div_5:
    push rcx
    mov rax, 4  ; Specify sys write call
    mov rbx, 1  ; Specify file descriptor 1: standard out
    mov rcx, Buzz
    mov rdx, BUZZLEN
    int 80h
    pop rcx
    jmp Loop

Print_Div_3_and_5:
    push rcx
    mov rax, 4  ; Specify sys write call
    mov rbx, 1  ; Specify file descriptor 1: standard out
    mov rcx, FizzBuzz
    mov rdx, FIZZBUZZLEN
    int 80h
    pop rcx
    jmp Loop

Exit:
    mov rax, 1            ; 1 is the system call for 'exit'
	mov rbx, 0            ; exit with error code 0
	int 80h               ; call an interrupt


global _start

_start:
    nop
    nop
    mov rcx, Count
Loop:
    dec rcx
    cmp rcx, 1
    jz Exit

    xor rdx, rdx
    mov rax, rcx
    mov rbx, 15
    div rbx
    cmp rdx, 0
    jz Print_Div_3_and_5
    
    xor rdx, rdx
    mov rax, rcx
    mov rbx, 3
    div rbx
    cmp rdx, 0
    jz Print_Div_3

    xor rdx, rdx
    mov rax, rcx
    mov rbx, 5
    div rbx
    cmp rdx, 0
    jz Print_Div_5

    jmp Loop







