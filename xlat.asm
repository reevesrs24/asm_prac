; Jeff Duntemann - Assembly language Step by Step
;
; Build using these commands
;   nasm -f elf64 -g -F stabs xlat.asm
;   ld -o xlat xlat.o
;
;
;

SECTION .data ; Section containing initialized data

    StatMsg: db "Processing...", 10
    StatLen: equ $-StatMsg
    DoneMsg: db "...Done!", 10
    DoneLen: equ $-DoneMsg

    ; The following translation table translates all lowercase characters to
    ; uppercase. It also translates all non printable characters to spaces,
    ; except for LF and HT

    UpCase: 
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,09h,0Ah,20h,20h,20h,20h,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
	db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
	db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
	db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
	db 60h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
	db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,7Bh,7Ch,7Dh,7Eh,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h

    ; The following translation table is "stock" in that it translates
    ; printable characters as themselves, and converts all non printable
    ; characters to spaces except for LF and HT.  You can modify this 
    ; to translate anything you want to any character you want.  

    Custom: 
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,09h,0Ah,20h,20h,20h,20h,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
	db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
	db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
	db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
	db 60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh
	db 70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,7Ch,7Dh,7Eh,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h


    SECTION .bss ; Section containing initialized data

        READLEN equ 1024            ; Length of buffer
        ReadBuffer: resb READLEN    ; Text Buffer itself

    SECTION .Text           ; Section containing code

    global _start       ; Linker needs to find this for entry point

    _start:

        nop ; This no-op keeps gdb happy

        ;  Display the "Processing..." message via stderr
        mov eax, 4  ; Specify sys_write call
        mov ebx, 2  ; Specify file descriptor 2: Standard Error
        mov ecx, StatMsg    ; Pass offset of the msg
        mov edx, StatLen    ; PAss the length of the message
        int 80h ; Make kernel call

    ; Read a buffer fulle of text from stdin
    read:
        mov eax, 3  ; Specify a sys_read call
        mov ebx, 0  ; Specify file descriptor 0: standard input
        mov ecx, ReadBuffer ; Pass offset of the buffer to read to
        mov edx, READLEN    ; Pass number of bytes to read at one pass
        int 80h             ; Make kernel call
        mov ebp, eax        ; Copy sys read return value for safekeeping
        cmp eax, 0          ; if eax=0 sys_read reached end of file
        je Exit             ; jump is equal (to 0 from compare)

    ; Set up registers for the translate step
        mov ebx, UpCase     ; Place the offset of the table into ebx
        mov edx, ReadBuffer ; Place the offset of the buffer into edx
        mov ecx, ebp        ; Place the number of bytes in the buffer into ecx
        
    ; Use the xlat instruction to translate the data in the buffer
    ; Note the commented out instruction do the same work as xlat
    
    translate:
        ; xor eax, eax ; Clear high 24 bits of eax
        mov al, byte [edx + ecx] ; Load character into AL for translation
        ; mov al, byte[Upcase + eax]    ; Translate character in AL via table
        xlat                    ; Translate character in AL via table
        mov byte [edx + ecx], al    ; Put the translated char back in the buffer
        dec ecx                 ; Decrement character count
        jnz translate           ; If there are more chars in the buffer repeat

    ; Write the buffer full of translated text to stdout
    write:
        mov eax, 4          ; Specify sys write call
        mov ebx, 1          ; Specify File descriptor 1: Standard output
        mov ecx, ReadBuffer ; Pass offset of the buffer
        mov edx, READLEN    ; Pass the number of bytes of data in the buffer
        int 80h             ; make kernel call
        jmp read            ; loop back and load another buffer full

    ; Display the "Im done" message via standard error
    Exit:
        mov eax, 4  ; Specify sys write call
        mov ebx, 2  ; Specify File descriptor 2: standard error
        mov ecx, DoneMsg ; Pass the offset of the message
        mov edx, DoneLen ; Pass the length of the message
        int 80h     ; Make kernel call

        mov eax, 1  ; Code for exit sys call
        mov ebx, 0  ; Return a code of zero
        int 80h     ; Make kernel call



