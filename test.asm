SECTION .data
 
    EatMsg: db "Eat at Joes", 10
    EatLen: equ $-EatMsg

SECTION .bss

SECTION .text

global _start


_start:
    nop
    mov eax, 4 ; Specify system write syscall
    mov ebx, 1 ; Specify File Descriptor 1: Standard Output
    call print
    

 exit:   
    ; Exit program
	mov eax,1            ; 1 is the system call for 'exit'
	mov ebx,0            ; exit with error code 0
	int 80h              ; call an interrupt

 print:
    push 2
    mov ecx, EatMsg
    mov edx, EatLen
    int 80h



