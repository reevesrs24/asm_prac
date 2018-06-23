; Jeff Dunteman - Assembly Language Step by Step
;
; Description: A simple hex dump utility demonstrating the use of seperately assembled code libraries via EXTERN
;
; Build using these commands
;   nasm -f elf -g -F stabs hexdump3.asm
;   ld -o hexdump3 hexdump3.o <path>/texlib.o

SECTION .bss    ; Section containing uninitialized data
    BUFFLEN EQU 10
    Buff resb BUFFLEN

SECTION .data   ; Section containing initialized data

SECTION .text

EXTERN ClearLine, DumpChar, PrintLine

GLOBAL _start

_start:
    nop         ; Keeps GDB happy
    nop
    xor esi, esi    ; Clear total chars counter to 0

; Read a buffer full of text from stdin
Read:
    mov eax, 3      ; Specify sys_read call
    mov ebx, 0      ; Specify file descriptor 0: Standard input
    mov ecx, Buff   ; Pass offset of the buffer to read to
    mov edx, BUFFLEN ; Pass number of bytes to read at one pass
    int 80h         ; make kernel call
    mov ebp, eax    ; Save number of bytes read from file for later
    cmp eax, 0      ; If eax=0, sys_read reached EOF on stdin 
    je Exit         ; Jump if equal (to 0, from compare)

; Set up the registers for the process buffer step
    xor ecx, ecx    ; clear buffer pointer to 0

; Go through the buffer and convert binary values to hex digits
Scan:
    xor eax, eax    ; Clear EAX to 0
    mov al, byte[Buff + ecx] ; Get a char from the buffer into AL
    mov edx, esi    ; Copy total counter into EDX
    and edx, 000000fh ; Mask out lower 4 bits of char counter
    call DumpChar   ; call the char poke procedure

; Bump the buffer pointer to the next character and see if buffer's done
    inc ecx     ; increment buffer pointer
    inc esi     ; increment total chars processed counter
    cmp ecx, ebp ; Compare with # of chars in buffer
    jae Read    ; If we've done the buffer, go get more

; See if we're at the end of a block of 16 and need to display a line
    test esi, 0000000fh ; Test 4 lowest bits in counter for 0
    jnz Scan            ; If counter is not modulo 16, loop back
    call PrintLine      ; otherwise print the line
    call ClearLine      ; clear hex dump line to 0's
    jmp Scan            ; Continue Scanning the buffer

; Exit
Exit:
    call PrintLine      ; Print the leftover line
    mov eax, 1          ; Code for exit sys call
    mov ebx, 0          ; Return a code of zero
    int 80h             ; Make kernel call