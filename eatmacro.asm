; Jeff Duntemann - Assembly Language Step by Step
;
; Description: A simple program in assembly for linux, demonstrating
;              the use of escape sequences to do simple "full screen" 
;              text output through macros rather than procedures
;
; Build using these commands
;   nasm -f elf64 -g -F syabs eatmacro.asm
;   ld -o eatmacro eatmacro.o

SECTION .bss    ; Section for uninitiliazed data 

SECTION .data   ; Section for initialized data

SCRWIDTH: equ 80            ; By default we assume 80 chars wide
PosTerm: db 27, "[01;01h"   ; <ESC>[<Y>;<X>H
POSLEN: equ $-PosTerm       ; Length of term position string
ClearTerm: db 27, "[2j"     ; <ESC>[2j; clears display
CLEARLEN: equ $-ClearTerm   ; Length of term clear string
Admsg: db "Eat at Joe's"    ; Ad message
ADLEN: equ $-Admsg          ; Length of ad message
Prompt: db "Press Enter: "  ; User Prompt
PROMPTLEN: equ $-Prompt     ; Length of user prompt

; This table gives us pairs of ASCII digits from 0-80. Rather than 
; calculate ASCII digits to insert in the terminal control string, 
; we look them up in the table and read back two digits at once to 
; a 16-bit register like DX, which we then poke into the terminal 
; control string PosTerm at the appropriate place. See GotoXY.
; If you intend to work on a larger console than 80 X 80, you must
; add additional ASCII digit encoding to the end of Digits. Keep in
; mind that the code shown here will only work up to 99 X 99.
	Digits:	db "0001020304050607080910111213141516171819"
		    db "2021222324252627282930313233343536373839"
		    db "4041424344454647484950515253545556575859"
		    db "606162636465666768697071727374757677787980"


SECTION .text   ; Section containing code

;-------------------------------------------------------------------------
; ExitProg: 	Terminate program and return to Linux
; IN: 		Nothing
; RETURNS:	Nothing
; MODIFIES: Nothing
; CALLS:	Kernel sys_exit
; DESCRIPTION:	Calls sys_edit to terminate the program and return
;		        control to Linux

%macro ExitProg 0   ; Macro takes 0 parameters
    mov eax, 1      ; Code for exit sys call 
    mov ebx, 0      ; Return a code of zero
    int 80h         ; Make Kernel call
%endmacro

;-------------------------------------------------------------------------
; WaitEnter: 	Wait for the user to press Enter at the console
; IN: 		Nothing
; RETURNS:	Nothing
; MODIFIES: Nothing
; CALLS:	Kernel sys_read
; DESCRIPTION:	Calls sys_read to wait for the user to type a newline at
;		        the console

%macro WaitEnter 0
    mov eax, 3      ; Code for sys read
    mov ebx, 0      ; Specify File descriptor 0: stdin
    int 80h         ; Make Kernel call
%endmacro

;-------------------------------------------------------------------------
; WriteStr: 	Send a string to the Linux console
; IN: 		String address in %1, string length in %2
; RETURNS:	Nothing
; MODIFIES: Nothing
; CALLS:	Kernel sys_write
; DESCRIPTION:	Displays a string to the Linux console through a 
;		        sys_write kernel call

%macro WriteStr 2   ; %1 = String address; %2 = string length
    pushfq     
    mov ecx, %1     ; Put string address into ECX
    mov edx, %2     ; Put string length into EDX
    mov eax, 4      ; Specify sys_write call
    mov ebx, 1      ; Specify File descriptor 1: stdout
    int 80h         ; Make kernel call
    popfq
%endmacro

;-------------------------------------------------------------------------
; ClrScr: 	Clear the Linux console
; IN: 		Nothing
; RETURNS:	Nothing
; MODIFIES: Nothing
; CALLS:	Kernel sys_write
; DESCRIPTION:	Sends the predefined control string <ESC>[2J to the
;		        console, which clears the full display

%macro ClrScr 0
    pushfq
; use WriteStr macro to write control strings to console
    WriteStr ClearTerm,CLEARLEN
    popfq
%endmacro

;-------------------------------------------------------------------------
; GotoXY: 	Position the Linux Console cursor to an X,Y position
; IN: 		X in %1, Y in %2
; RETURNS:	Nothing
; MODIFIES: PosTerm terminal control sequence string
; CALLS:	Kernel sys_write
; DESCRIPTION:	Prepares a terminal control string for the X,Y coordinates
;		        passed in AL and AH and calls sys_write to position the
;		        console cursor to that X,Y position. Writing text to the
;		        console after calling GotoXY will begin display of text
;		        at that X,Y position.

%macro GotoXY 2     ; %1 is X value; %2 is Y value
    pushfq          ; Save callers registers
    xor edx, edx    ; Zero Edx
    xor ecx, ecx    ; Zero ECX
; Poke the Y digits
    mov dl, %2      ; Put Y value into offset term EDX
    mov cx, word [Digits + edx * 2] ; Fetch decimal digits to CX
    mov word [PosTerm + 2], cx      ; Poke digits into control string
; Poke the x digits
    mov dl, %1                      ; Put X value into offset term edx
    mov cx, word [Digits + edx * 2] ; Fetch decimal digits to into control string
    mov word [PosTerm + 5], cx      ; Poke digits into control string
; Send control sequence to stdout
    WriteStr PosTerm, POSLEN
    popfq                           ; Restore callers registers
%endmacro
    
;-------------------------------------------------------------------------
; WriteCtr: 	Send a string centered to an 80-char wide Linux console
; IN: 		Y value in %1, String address in %2, string length in %3
; RETURNS:	Nothing
; MODIFIES: PosTerm terminal control sequence string
; CALLS:	GotoXY, WriteStr
; DESCRIPTION:	Displays a string to the Linux console centered in an
;		        80-column display. Calculates the X for the passed-in 
;		        string length, then calls GotoXY and WriteStr to send 
;		        the string to the console

%macro WriteCtr 3	; %1 = row; %2 = String addr; %3 = String length
	pushfq
	mov edx,%3	    ; Load string length into EDX
	xor ebx,ebx	    ; Zero EBX
	mov bl,SCRWIDTH	; Load the screen width value to BL
	sub bl,dl	    ; Calc diff. of screen width and string length
	shr bl,1	    ; Divide difference by two for X value
	GotoXY bl,%1	; Position the cursor for display
	WriteStr %2,%3	; Write the string to the console
	popfq
%endmacro

global _start

_start:
    nop
    nop

; First we clear the terminal display
    ClrScr
; Then we post the ad message centered on the 80 wide console
    WriteCtr 12, Admsg, ADLEN
; Position the cursor for the "Press Enter" prompt
    GotoXY 1,23
; Display the "Press Enter" Prompt
    WriteStr Prompt, PROMPTLEN
; Wait for the user ot press enter
    WaitEnter
; Exit
    ExitProg

