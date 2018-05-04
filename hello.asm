SECTION .DATA
	hello:      db 'Hello world!', 10 ; 10 is newline char
	hello_Len:  equ $-hello ; $ is address of 'here' - address of starting string 'hello'


SECTION .TEXT
	GLOBAL _start

_start:
	mov eax, 4             ; 4 is the 'write' system call
	mov ebx, 1             ; 1 file descriptor 1 is STDOUT
	mov ecx, hello         
	mov edx, hello_Len     ; string length
	int 80h                ; call an interrupt

	; Exit program
	mov eax,1            ; 1 is the system call for 'exit'
	mov ebx,0            ; exit with error code 0
	int 80h              ; call an interrupt