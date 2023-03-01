Purpose:
Read from user a string. Print the string while replacing every number in it with the corresponding uppercase letter: 0->A, 1->B...
And print the sum of the numbers in the original string. 

Compilation & execution:
    nasm -f elf -F stabs main.asm ; ld -m elf_i386 -o main.elf main.o ; ./main.elf