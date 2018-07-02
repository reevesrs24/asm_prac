fizzBuzz: fizz_buzz.o
	ld -o fizzBuzz fizz_buzz.o

fizz_buzz.o: fizz_buzz.asm
	     nasm -f elf64 -g -F stabs fizz_buzz.asm

clean: 
	rm *.o fizzBuzz
