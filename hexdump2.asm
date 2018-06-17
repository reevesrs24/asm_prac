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
    ; Remember that if dumplin is used seperately, you must append an 
    ; ROL before sending it to the linux console.  

    Dumplin: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
    Dumplen EQU $-dumplin
    ASCLin: db "|.................|", 10
    ASCLEN EQU $-ASCLin
    FULLEN EQU $-Dumplin

    ; The HexDigits table is used to convert numeric values to their hex
    ; equivalents. Index by nybble without a scale: [HexDigits + eax]
    HexDigits: "0123456789ABCDEF"

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

            Pushad          ; Save all the caller's GP registers
            mov edx, 16     ; We're goind to do 16 pokes, coutning from 0
    .poke:  mov eax, 0      ; Tell Dumpchar to poke a '0'
            call Dumpchar   ; Insert the '0' into the hex dump string
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
            mov byte [Dumplin + edi + 2], al  ; Write the character equivalent to line string
    
    ; Look up high nybble character and insert it into the string
            and ebx, 000000f0h  ; Mask out all but the second lowest nybble
            shr ebx, 4          ; Shift high 4 bits of byte into low 4 bits 
            mov bl, byte [HexDigits + ebx] ; Look up char equiv of nybble
            mov byte [DumpLin + edi + 1] ; Write the char equiv to line string

            pop edi ; restore callers edi
            pop ebx ; restore callers ebx
            ret     ; return to caller  
