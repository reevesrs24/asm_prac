
SECTION .data
    Fizz: db "Fizz",10
    FIZZLEN: equ $-Fizz
    Buzz: db "Buzz",10
    BUZZLEN: equ $-Buzz
    FizzBuzz: db "FizzBuzz",10
    FIZZBUZZLEN: equ $-FizzBuzz
    Count: equ 111
    Nums: db "0123456789"
    NL: db 10
    Space: db 32
    
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

Print_Num_Stack:
    xor rdx, rdx
    xor rcx, rcx
    pop rdx
    mov rax, 4
    mov rbx, 1
    lea rcx, [Nums + rdx]
    mov rdx, 1
    int 80h
    dec rsi
    cmp rsi, 0
    jne Print_Num_Stack
    jmp End

Print_Num:
    mov rdi, rcx
    push rcx
    mov rax, rcx ; Move remaining count into dividend
.Loop:
    xor rcx, rcx
    xor rdx, rdx
    mov rcx, 10  ; Move 10 into the divisor
    div rcx      ; divide rdx = remainder
    push rdx
    inc rsi
    cmp rax, 0
    jne .Loop
    jmp Print_Num_Stack
End:    
    pop rcx
    ret



Print_New_Line:
    push rcx
    mov rax, 4
    mov rbx, 1
    mov rcx, NL
    mov dl, 1
    int 80h
    pop rcx
    ret

Print_Space:
    push rcx
    mov rax, 4
    mov rbx, 1
    mov rcx, Space
    mov dl, 1
    int 80h
    pop rcx
    ret

global _start

_start:
    nop
    nop
    mov rcx, Count
Loop:
    cmp rcx, 0
    je Exit
    dec rcx
    call Print_Num
    call Print_Space
    

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

    call Print_New_Line

    jmp Loop







