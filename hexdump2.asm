; Jeff Duntemann - Assembly language Step by Step
;
; Build using these commands
;   nasm -f elf64 -g -F stabs hexdump2.asm
;   ld -o hexdump hexdump.o
;
;
;

SECTION .bss    ; Section for uninitialized data

    BUFFLEN EQU 10
    Buff resb BUFFLEN

SECTION .data   ; Section containing initialized data

    ; Here we have a two parts of a single useful data stucture, implmenting
    ; the text line of a hex dump utility. The first displays 16 bytes in
    ; hex seperated by spaces.  Immediately following is a 16 character line
    ; delimited by vertical bar characters.  Because they are adajacent, the two
    ; parts can be referenced separately or as a single contiguous unit.  
    ; Remember that if DumpLin is used seperately, you must append an 
    ; ROL before sending it to the linux console.  

    DumpLin: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
    DUMPLEN EQU $-DumpLin
    ASCLin: db "|.................|", 10
    ASCLEN EQU $-ASCLin
    FULLEN EQU $-DumpLin

    ; The HexDigits table is used to convert numeric values to their hex
    ; equivalents. Index by nybble without a scale: [HexDigits + eax]
    HexDigits: db "0123456789ABCDEF"

    ; This table is used for ascii character translation, into the ascii
    ; portion of the hex dump line, via xlat or ordinary memory lookup.
    ; All printable characters "play through" as themselves. The high 128
    ; characters are translated to ascii period (2eh). The non printable 
    ; characters in the low 128 are also translated to ascii period, as is
    ; char 127

    DotXlat:
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
        db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
        db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
        db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
        db 60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh
        db 70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,7Ch,7Dh,7Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh

    SECTION .text ; Section containing code

    ;--------------------------------------
    ; ClearLine: Clear a hex dump line string to 16 0 values
    ; IN: Nothing
    ; Returns: Nothing
    ; Modifies: Nothing
    ; Calls: DumpChar
    ; Description: The hex dump line string is cleared to binary 0 bu
    ;              calling Dumpchar 16 times, passing it 0 each time

    ClearLine:

            pushad          ; Save all the caller's GP registers
            mov edx, 16     ; We're goind to do 16 pokes, coutning from 0
    .poke:  mov eax, 0      ; Tell Dumpchar to poke a '0'
            call DumpChar   ; Insert the '0' into the hex dump string
            sub edx, 1      ; DEC doesnt effect CF
            jae .poke       ; Loop back if EDX >= 0
            popad           ; Restore all the callers GP Register
            ret             ; Return   

    ;----------------------------------------
    ; Dumpchar: "Poke" a value into the hex dump line string
    ; In: Pass the 8-bit value to be poked in EAX
    ;     Pass the value's position in the line (0-15) in EDX
    ; Returns: Nothing
    ; Modifies: EAX, ASCLin, DumpLin
    ; Calls: Nothin
    ; Description: The value passed in EAX will be put in both the hex dump
    ;              portion and in the ASCII portion, at the position passed 
    ;              in EDX, represented by a space where it is not a printable
    ;              character

    DumpChar:

            push ebx    ; Save callers ebx
            push edi    ; Save callers edi

    ; First we insert the input char into the ASCII portion of the dump line
            mov bl, byte [DotXlat + eax]    ; Translate non printables to '.'
            mov byte [ASCLin + edx + 1], bl ; Write to ascii portion

    ; Next we insert the hex equivalent of the input char into the ascii portion of the hex dump line
            mov ebx, eax    ; Save a second copy of the input char
            lea edi, [edx * 2 + edx]    ; Calc offset into the line string (EDX x 3)

    ; Look up low nybble character and insert it into the string 
            and eax, 0000000fh  ; Mask out al but the low nybble
            mov al, byte [HexDigits + eax]    ; Look up the char equivalent of nybble
            mov byte [DumpLin + edi + 2], al  ; Write the character equivalent to line string
    
    ; Look up high nybble character and insert it into the string
            and ebx, 000000f0h  ; Mask out all but the second lowest nybble
            shr ebx, 4          ; Shift high 4 bits of byte into low 4 bits 
            mov bl, byte [HexDigits + ebx] ; Look up char equiv of nybble
            mov byte [DumpLin + edi + 1], bl ; Write the char equiv to line string

            pop edi ; restore callers edi
            pop ebx ; restore callers ebx
            ret     ; return to caller  

    ;--------------------------------------
    ; PrintLine: Displays DumpLin to stdout
    ; IN: Nothing
    ; Returns: Nothing
    ; Modifies: Nothing
    ; Calls: Kernel sys_write
    ; Description: The hex dump line string DumpLin is displayed to stdout
    ;              using int 80h sys_write. All GP registers are preserved

    PrintLine:

            pushad      ; Save al callers registers
            mov eax, 4  ; Specify sys_write call
            mov ebx, 1  ; Specify file descriptor 1: Standard output
            mov ecx, DumpLin ; Pass offset of line string
            mov edx, FULLEN    ; PAss size of line string
            int 80h     ; Make Kernel call
            popad       ; Restor callers registers
            ret

    ;--------------------------------------
    ; LoadBuff: Fills a buffer with data from stdin via int 80h sys_read
    ; IN: Nothing
    ; Returns: # of bytes read in EBP
    ; Modifies: ECX, EBP, Buff
    ; Calls: Kernel sys_write
    ; Description: Loads a buffer full of data (BUFFLEN bytes) from stdin
    ;              using int 80h sys_read and places it in Buff. Buffer 
    ;              offset counter ECX zeroed, because were starting in a new
    ;              buffer full of data. Caller must test value in EBP: If EBP
    ;              contains zero on return, we hit EOF on stdin.  LEss than 0 in
    ;              on return indicates some kind of error

    LoadBuff:
            push eax            ; Save callers eax
            push ebx            ; Save callers ebx
            push edx            ; Save callers edx
            mov eax, 3          ; Specify sys_read call
            mov ebx, 0          ; Specify file descriptor 0: Standard input
            mov ecx, Buff       ; Pass offset of the buffer to read to
            mov edx, BUFFLEN    ; Pass number of bytes to read at one pass
            int 80h             ; Make system call
            mov ebp, eax        ; Save # of bytes read from file for later
            xor ecx, ecx        ; Clear buffer pointer ECX to 0
            pop edx             ; Restore callers edx
            pop ebx             ; Restore callers ebx
            pop eax             ; Restore callers eax
            ret

    global _start

    ; MAIN PROGRAM ;

    _start:

        nop ; nop for GDB
        nop
;
    ; Whatever initialization needs doing before the loop scan starts is here
        xor esi, esi    ; Clear total byte count to 0
        call LoadBuff   ; Read first buffer of data from stdin
        cmp ebp, 0      ; if ebp=0, sys_read reached EOF on stdin
        jbe Exit        

    ; Go through the buffer and convert binary byte value to hex digits 
    Scan:
        xor eax, eax ; Clear EAX to 0
        mov al, byte [Buff + ecx] ; Get a byte from the buffer to AL
        mov edx, esi ; Copy a total counter into EDX
        and edx, 0000000fh ; Mask out lowest 4 bits of char counter
        call DumpChar ; Call the char poke procedure

    ; Bump the buffer pointer to the next character and see if buffers done
        inc esi ; increment total chars processed counter
        inc ecx ; increment buffer pointer
        cmp ecx, ebp ; Compare with # chars in Buffer
        jb .modTest ; if weve processed all chars in buffer
        call LoadBuff ; go fill the buffer again 
        cmp ebp, 0  ; if ebp=0, sys_Read reached EOF on stdin
        jbe Done    ; if we got EOF, were done

    ; See if were at the end of a block of 16 and need to display a line
    .modTest
        test esi, 0000000fh ; Test 4 lowest bits in counter for 0, (Test does not set AF flag)
        jnz Scan            ; If counter is not modulo 16, loop back
        call PrintLine      ; otherwise print the line
        call ClearLine      ; clear hex dump line to 0
        jmp Scan            ; Contiue scanning the buffer

    Done:
        call PrintLine      ; Print the Leftovers line
    
    Exit:                   
        mov eax, 1          ; Code for exit sys_call
        mov ebx, 0          ; Return a code of 0
        int 80h             ; MAke kernel call