# ASM.Fibonacci
Fibonacci em assembly

Para compilar
nasm -f elf64 fibonacci.asm ; ld fibonacci.o -o fibonacci.x

Eu estava tendo um problema onde todos meus códigos em asm onde caso o código não seja compilado com -g, as váriaveis e registradores não podem ser lidas
nasm -f elf64 fibonacci.asm -g ; ld fibonacci.o -o fibonacci.x -g

Para verificar o resultado do fibonacci digite p/d $r15
