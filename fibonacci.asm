; AV2020QUNICA - Trabalho Fibonnaci
; arquivo: fibonacci.asm
; Nome: Matheus Rogerio Pesarini
; nasm -f elf64 fibonacci.asm ; ld fibonacci.o -o fibonacci.x

; Eu estava tendo um problema onde todos meus códigos em asm onde caso o código não seja compilado com -g, as váriaveis e registradores não podem ser lidas
; nasm -f elf64 fibonacci.asm -g ; ld fibonacci.o -o fibonacci.x -g
section .data
    fibo : dq 0
    pergunta db 'Digite um numero: ', 0
    erro db 'Entrada invalida. O numero deve ter 1 ou 2 digitos.', 0
    excedido db 'Valores de fibonacci maiores que 94 não são suportados.', 0
    aberturaArq: db "fib(", 0
    fechamentoArq: db ").bin", 0

section .bss
    stringNumero: resb 3
    buffer: resb 3
    fib_arq : resq 1
    escritaArq: resb 30

section .text
    global _start

_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, pergunta
    mov rdx, 18
    syscall

    mov rax, 0 ; inserindo a string do numero na variavel
    mov rdi, 0
    lea rsi, [stringNumero]
    mov edx, 3
    syscall

    cmp byte[stringNumero + 1], 10 ; Verificando se foi lido um digito
    je umNumero

    cmp byte[stringNumero + 2], 10 ; Verificando se foi lido dois digitos
    je doisNumero

    sub al, '0'
    mov [buffer], al
    jne exibirErro ; Verifica se foram lidos três números ou mais

    umNumero:
        mov al, [stringNumero]
        mov rbx, [aberturaArq]
        mov [escritaArq], rbx
        mov [escritaArq + 4], al
        mov rbx, [fechamentoArq]
        mov [escritaArq + 5], rbx
        mov bl, [fechamentoArq + 4]
        mov [escritaArq + 9], bl  ; esses passos anteriores estão arrumando o nome do arquivo
        sub al, '0'
        mov [buffer], al
        mov [fib_arq], al

        cmp al, 0
        je arquivo
        cmp al, 1 ; caso especial para lidar com a inserção do numero 1
        je fib_1
        mov r15, 1
        mov r14, 0
        jmp fibonacci

    doisNumero:
        mov cl, [stringNumero + 1]
        mov al, [stringNumero]
        mov rbx, [aberturaArq]
        mov [escritaArq], rbx
        mov [escritaArq + 4], al 
        mov [escritaArq + 5], cl 
        mov rbx, [fechamentoArq] 
        mov [escritaArq + 6], rbx
        mov bl, [fechamentoArq + 4]
        mov [escritaArq + 10], bl ; esses passos anteriores estão arrumando o nome do arquivo
        sub al, '0'
        sub cl, '0'
        imul ax, 10
        add al, cl ; al + cl
        mov [buffer], al ; a limpeza do buffer para um numero entre 94 e 99 está com problemas e explico abaixo
        cmp al, 94
        jge excedeu
        mov [fib_arq], al ; fib_arq = al
        mov r15, 1
        mov r14, 0

    fibonacci: ; ** Para verificar qual o resultado do fibonacci, p/d $r15
        mov r13, r15
        add r15, r14
        mov [fibo], r15 ; fibo sera o ponteiro para o resultado do fibonacci
        mov r14, r13
        dec qword[fib_arq]
        cmp qword[fib_arq], 1 ; verificando se fib_arq == 1
        jne fibonacci ; retornar para o começo da função fibonacci caso não seja 1
        jmp arquivo

fib_1:
    mov qword[fibo], 1

arquivo:
    mov rax, 2
    lea rdi, [escritaArq]
    mov edx, 664o ; modo do arquivo
    mov esi, 102o ; flags 
    syscall

    mov r9, rax
    mov rax, 1
    mov rdi, r9
    mov rsi, fibo
    mov rdx, 8
    syscall

    mov rax, 3
    mov rdi, r9
    syscall ; fechando o arquivo

    jmp fim

exibirErro:
    limpar_buffer1:
        mov rax, 0 ; syscall para read
        mov rdi, 0 ; file descriptor para stdin
        lea rsi, [buffer]
        mov rdx, 1 
        syscall
        cmp byte [buffer], 10 ; verificando se o caractere é uma nova linha
        jne limpar_buffer1
        
    mov rax, 1
    mov rdi, 1
    mov rsi, erro
    mov rdx, 52
    syscall
    jmp fim

excedeu:
    limpar_buffer2: ; quando é inserido um numero entre 94 e 99, é preciso apertar enter no terminal para que o programa chegue aqui, isso acontece por causa da limpeza do buffer
        mov rax, 0 ; syscall para read
        mov rdi, 0 ; file descriptor para stdin
        lea rsi, [buffer]
        mov rdx, 1
        syscall
        cmp byte [buffer], 10 ; verificando se o caractere é uma nova linha
        jne limpar_buffer2
        
    mov rax, 1
    mov rdi, 1
    mov rsi, excedido
    mov rdx, 56
    syscall

fim:
    mov rax, 60
    mov rdi, 0
    syscall