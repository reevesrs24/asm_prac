movsb: movsb.o
	ld -o movsb movsb.o

movsb.o: movsb.asm
	   nasm -f elf64 -g -F stabs movsb.asm

clean: 
	rm *.o movsb
