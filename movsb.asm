SECTION .data
    EditBuff: db "abc ",10
    ENDPOS equ 4


SECTION .text
    global _start

    Print:
        mov eax, 4  ; Specify sys_write call
        mov ebx, 1  ; Specify file descriptor 1: Standard output
        mov ecx, EditBuff ; Pass offset of line string
        mov edx, 5   ; PAss size of line string
        int 80h     ; Make Kernel call
        ret

    _start:
        nop
        call Print
        std                 ; down memory trandfer
        mov rbx, EditBuff   ;  Save address at insert point
        mov rsi, EditBuff + ENDPOS   ; Start at end of text
        mov rdi, EditBuff + ENDPOS + 1 ; Bump text right by 1
        mov rcx, ENDPOS - 1 ; # number of characters to bump
        rep movsq                    ; move them
       
        mov byte [rbx], ' '          ; Write a space at insert point
        call Print

        mov rax, 1            ; 1 is the system call for 'exit'
	    mov rbx, 0            ; exit with error code 0
	    int 80h               ; call an interrupt

