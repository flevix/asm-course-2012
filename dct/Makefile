all: main.c dct
	gcc -g main.c -c -o main.o -m32
	gcc main.o dct.o -o pr -m32 -lm
	rm -f *.o
dct: dct.asm
	yasm -g dwarf2 dct.asm -o dct.o -f elf32
clean:
	rm -f pr
