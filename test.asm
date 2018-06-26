SECTION .data
    Test: db 8
   

SECTION .bss
     c: resb 1

SECTION .text

global _start


_start:
    nop
    
    call print
    

 exit:   
    ; Exit program
	mov eax,1            ; 1 is the system call for 'exit'
	mov ebx,0            ; exit with error code 0
	int 80h              ; call an interrupt

 print:
    mov eax, [Test]
    add eax, '0'  ; get digit's ascii code
    mov [c], eax  ; store it at c
    dec eax
    mov eax, 4 ; sys_write
    mov ebx, 1    ; stdout
    mov ecx, c    ; pass the address of c to ecx
    mov edx, 1    ; one character
    int 0x80      ; syscall
    dec BYTE ptr [Test]
    cmp  BYTE ptr [Test], 0
    jmp print
    ret



