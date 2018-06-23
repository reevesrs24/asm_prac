; Jeff Duntemann - Assembly Language Step by Step
; 
; Description: A Linkable library of text oriented procedures and tables
;
; Build using these commands
;   nasm -f elf -g -F stabs textlib.asm
;   
;

SECTION .bss    ; Section containing uninitialized data
    BUFFLEN EQU 10
    Buff resb BUFFLEN

SECTION .data   ; Section containing initialized data

GLOBAL ClearLine, DumpChar, NewLines, PrintLine ; Procedures
GLOBAL Dumplin, HexDigits, BinDigits            ; Data Items

; Here we have two parts of a single useful data structure, implementing the
; text line of hex dump utility. The first part displays 16 bytes in hex
; separated by spaces.  Immediately following is a 16-character line delimited
; by vertical bar characters.  Because they are adjacent, they can be 
; referenced seperately or as a single contiguous unit. Remember that if 
; DumpLin is to be used seperately, you must append an EOL before sending it 
; to the Linux console

DumpLin:	db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
DUMPLEN		EQU $-DumpLin
ASCLin:		db "|................|",10
ASCLEN		EQU $-ASCLin
FULLLEN		EQU $-DumpLin


; The HexDigits table is used to convert numeric values to their hex
; equivalents. Index by nybble without a scale: [HexDigits+eax]
HexDigits:	db "0123456789ABCDEF"

; This table allows us to generate text equivalents for binary numbers. 
; Index into the table by the nybble using a scale of 4: 
; [BinDigits + ecx*4]
BinDigits:	db "0000","0001","0010","0011"
		    db "0100","0101","0110","0111"
		    db "1000","1001","1010","1011"
		    db "1100","1101","1110","1111"

; This table is used for ASCII character translation, into the ASCII
; portion of the hex dump line, via XLAT or ordinary memory lookup. 
; All printable characters "play through" as themselves. The high 128 
; characters are translated to ASCII period (2Eh). The non-printable
; characters in the low 128 are also translated to ASCII period, as is
; char 127.
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

SECTION .text   ; Section containing code
    ; GLOBAL ClearLine, DumpChar, NewLines, PrintLine ; Procedures
    ; GLOBAL Dumplin, HexDigits, BinDigits            ; Data Items

;-------------------------------------------------------------------------
; ClearLine: Clear a hex dump line string to 16 0 values
; IN: 		Nothing
; RETURNS:	Nothing
; MODIFIES: Nothing
; CALLS:	DumpChar
; DESCRIPTION:	The hex dump line string is cleared to binary 0

ClearLine:
    pushfq    ; Save callers edx
    mov edx, 15 ; We're going to go 16 pokes, counting from 0
.Poke: 
    mov eax, 0  ; Tell dumpchar to poke a zero
    call DumpChar ; insert the '0' into the hex dump string
    sub edx, 1  ; DEC doesn't affect CF
    jae .Poke   ; Loop back if EDX >= 0
    popfq     ; Restore callers EDX
    ret         ; return

;-------------------------------------------------------------------------
; DumpChar: 	"Poke" a value into the hex dump line string.
; IN: 		Pass the 8-bit value to be poked in EAX.
;     		Pass the value's position in the line (0-15) in EDX 
; RETURNS:	Nothing
; MODIFIES: 	EAX
; CALLS:	Nothing
; DESCRIPTION:	The value passed in EAX will be placed in both the hex dump
;		portion and in the ASCII portion, at the position passed 
;		in ECX, represented by a space where it is not a printable 
;		character.

  DumpChar:

            pushfq

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

            popfq
            ret     ; return to caller  

;-------------------------------------------------------------------------
; Newlines: 	Sends between 1-15 newlines to the Linux console
; UPDATED:	4/13/2009
; IN: 		# of newlines to send, from 1 to 15
; RETURNS:	Nothing
; MODIFIES: 	Nothing
; CALLS:	Kernel sys_write
; DESCRIPTION:	The number of newline chareacters (0Ah) specified in EDX
;		is sent to stdout using using INT 80h sys_write. This
;		procedure demonstrates placing constant data in the 
;		procedure definition itself, rather than in the .data or
;		.bss sections.

Newlines:
    pushfq        ; save all callers registers
    cmp edx, 15   ; Make sure caller didnt ask for more than 15
    ja .exit      ; If so, exit without doing anything
    mov ecx, EOLs ; put address of EOLs table into ECX
    mov eax, 4    ; Specify sys_write
    mov ebx, 1    ; specify stdout
    int 80h       ; make kernel call
.exit:             
    popfq         ; Restore all callers registers
    ret           ; return
EOLs	db 10,10,10,10,10,10,10,10,10,10,10,10,10,10,10




;--------------------------------------
; PrintLine: Displays DumpLin to stdout
; IN: Nothing
; Returns: Nothing
; Modifies: Nothing
; Calls: Kernel sys_write
; Description: The hex dump line string DumpLin is displayed to stdout
;              using int 80h sys_write. All GP registers are preserved

PrintLine:

    pushfq      ; Save al callers registers
    mov eax, 4  ; Specify sys_write call
    mov ebx, 1  ; Specify file descriptor 1: Standard output
    mov ecx, DumpLin ; Pass offset of line string
    mov edx, FULLLEN    ; PAss size of line string
    int 80h     ; Make Kernel call
    popfq       ; Restor callers registers
    ret

