; "Assembly Language Step by Step" - Jeff Duntemann
;
; Run it this way
;   hexdump1 < (input file)
;
; Build using these commands
;   nasm -f elf64 -g -F stabs hexdump1.asm
;   ld -o hexdump1 hexdump1.o
;


SECTION .bss            ; Section containing uninitialized data

    BUFFLEN equ 16      ; We read the file 16 bytes at a time
    Buff: resb BUFFLEN  ; Text buffer itself

SECTION .data           ; Section containing initialized data

    HexStr: db "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00", 10
    HEXLEN equ $-HexStr

    Digits: db "0123456789ABCDEF"

SECTION .Text           ; Section containing code

    global _start       ; Linker needs to find this for entry point

    _start:
        nop             ; This keeps GDB happy

    ; Read a buffer full of text from stdin
    Read:

        mov eax, 3      ; Specify sys_read call
        mov ebx, 0      ; Specify File Decsriptor 0: Standard input
        mov ecx, Buff   ; Pass offset of buffer to read too
        mov edx, BUFFLEN ; Pass number of bytes to read at one pass
        int 80h         ; Call sys_read to fill the buffer
        mov ebp, eax    ; Save # of bytes read from file for later
        cmp eax, 0      ; if eax=0, sys read reached EOF on stdin
        je Exit         ; Jump if equal to 0

    ; Set up registers for process buffer step
        mov esi, Buff   ; Place Address of buffer into esi
        mov edi, HexStr ; Place address of line string into edi
        xor ecx, ecx    ; Clear line string pointer to 0

    ; Go through the buffer and convert binary values to hex digits
    Scan:
        xor eax, eax    ; Clear eax to 0

    ; Calculate the offset into HexStr, which is the value in ecx x 3
        mov edx, ecx    ; Copy the character counter into edx
        shl edx, 1      ; Multiply pointer by 2 using shift left
        add edx, ecx    ; Complete the multiplication X3

    ; Get a character from the buffer and put it in both eax and ebx
        mov al, byte[esi + ecx] ; put a byte into the input buffer into al
        mov ebx, eax    ; Duplicate the byte in bl for second nybble

    ; Look up a low nybble character and insert it into a the string
        and al, 0fh                     ; Mask out all but the low nybble
        mov al, byte[Digits + eax]      ; Look up char equivalent of nybble
        mov byte [HexStr + edx + 1], al ; Write LSB char digit to line string
        

    ; Look up high nybble character and insert it into the string
        shr bl, 4       ; Shift high 4 bits of char into low 4 bits
        mov bl, byte[Digits + ebx]  ; Look up the char equivalent of nybble
        mov byte [HexStr + edx], bl ; Write MSB char digit to line string

    ; Bump the buffer pointer to the next character and see if we're done
        inc ecx ; Increment line string pointer
        cmp ecx, ebp    ; Compare to the number of chars in the buffer
        jna Scan        ; Loop back if ecx is <= number of chars in buffer

    ; Write out the line of hexadecimal values to stdout
        mov eax, 4      ; Specify sys_write call
        mov ebx, 1      ; Specify file descriptor 1 std output
        mov ecx, HexStr ; Pass offset of line string
        mov edx, HEXLEN ; Pass size of the line string
        int 80h
        jmp Read        ; Loop back and load file buffer again

    Exit:
        mov eax, 1  ; Code for exit sys call
        mov ebx, 0  ; Return a code of zero
        int 80h

