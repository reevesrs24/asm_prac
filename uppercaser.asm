
SECTION .bss
    BUFFLEN equ 1024        ; Length of Buffer
    Buff resb BUFFLEN       ; Text buffer itself

SECTION .data

SECTION .text
    global _start


_start:
    nop             ; This no-op keeps the debugger happy

; Read a buffer full of text from stdin
Read:
    mov eax, 3       ; Specify sys_read call
    mov ebx, 0       ; specify file descriptor 0: standard output
    mov ecx, Buff    ; Pass offset of the buffer to read to
    mov edx, BUFFLEN ; Pass number of bytes to read at one pass
    int 80h          ; Call sys_read to fill the buffer
    mov esi, eax     ; Store the return value for later use
    cmp eax, 0       ; if eax=0, sys_read reached EOF on stdin 
    je Exit          ; Jump is equal to zero

; Set up the registers for the process buffer step
    mov ecx, esi     ; Place the number of bytes read into ecx
    mov ebp, Buff    ; Place address of buffer into ebp
    dec ebp          ; adjust count to offset

; Go through the buffer and convert lowercase to uppercase characters

Scan: 
    cmp byte [ebp + ecx], 61h ; Test input character againt lowercase 'a'
    jb Next                   ; if below 'a' in ascii, not lowercase
    cmp byte [ebp + ecx], 7ah ; Test input character against lowercase 'z'
    ja Next                   ; if above 'z' in ascii, not lowercase

    sub byte [ebp + ecx], 20h ; Suntract 20h to convert to upppercase

Next:
    dec ecx                   ; Decrement counter
    jnz Scan                  ; If characters remain, loop back

; Write the buffer full of processed text to stdout

Write:
    mov eax, 4       ; Specify sys_write call
    mov ebx, 1       ; Specify file descriptor 1: Standard ouput
    mov ecx, Buff    ; Pass offset of the Buffer
    mov edx, esi     ; Pass the # of bytes of data to the buffer
    int 80h          ; make sys_write kernel call
    jmp Read         ; Loop back and load another buffer

Exit:
    mov eax, 1       ; Code for exit Syscall
    mov ebx, 0       ; Return a code of zero
    int 80h          ; Make sys_exit kernel call 
