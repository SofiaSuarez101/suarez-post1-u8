; =============================================================
; post2c.asm - MUL, DIV y AAM: calculadora de un digito
; Compilar: nasm -f bin post2c.asm -o post2c.com
; Ejecutar: post2c.com   (DOSBox)
; =============================================================
ORG 100h

ASCII_0  equ 30h
OP_MUL   equ 2Ah                ; '*'
OP_DIV   equ 2Fh                ; '/'

section .data
    promptA       db "Primer operando (0-9): $"
    promptB       db 0Dh,0Ah,"Segundo operando (0-9): $"
    promptOp      db 0Dh,0Ah,"Operacion (* o /): $"
    msgR     db 0Dh,0Ah,"Resultado: $"
    msgErr   db 0Dh,0Ah,"Division por cero.$"
    msgOpInv db 0Dh,0Ah,"Operacion no valida.$"
    msgResto db " (resto $"
    msgCierra db ")$"
    crlf     db 0Dh,0Ah,"$"
    resto    db 0

section .text
start:
    ; ---- Leer operando A ----
    mov ah, 09h
    mov dx, promptA
    int 21h
    mov ah, 01h
    int 21h                     ; AL = ASCII del digito (con eco)
    sub al, ASCII_0             ; a binario
    mov bl, al                  ; BL = A

    ; ---- Leer operando B ----
    mov ah, 09h
    mov dx, promptB
    int 21h
    mov ah, 01h
    int 21h
    sub al, ASCII_0
    mov cl, al                  ; CL = B

    ; ---- Leer operador ----
    mov ah, 09h
    mov dx, promptOp
    int 21h
    mov ah, 01h
    int 21h                     ; AL = '*' o '/'
    mov bh, al                  ; BH = operador

    ; ---- Encabezado del resultado ----
    mov ah, 09h
    mov dx, msgR
    int 21h

    cmp bh, OP_MUL
    je .mul
    cmp bh, OP_DIV
    je .div
    mov ah, 09h
    mov dx, msgOpInv
    int 21h
    jmp .fin

.mul:
    mov al, bl                  ; AL = A
    mul cl                      ; AX = AL * CL (sin signo), maximo 81
    aam                         ; AH = decenas, AL = unidades
    mov bx, ax                  ; BH = decenas, BL = unidades
    cmp bh, 0
    je .soloUnidades            ; no imprimir un cero a la izquierda
    mov dl, bh
    add dl, ASCII_0
    mov ah, 02h
    int 21h
.soloUnidades:
    mov dl, bl
    add dl, ASCII_0
    mov ah, 02h
    int 21h
    jmp .fin

.div:
    cmp cl, 0
    je .divCero
    xor ah, ah                  ; AH = 0 (AX = dividendo de 8 bits)
    mov al, bl
    div cl                      ; AL = cociente, AH = resto
    mov [resto], ah             ; guardar el resto
    xor ah, ah                  ; AX = cociente
    call imprimirAX             ; imprimir cociente
    cmp byte [resto], 0
    je .fin                     ; resto 0: no se muestra
    mov ah, 09h
    mov dx, msgResto
    int 21h
    mov dl, [resto]
    add dl, ASCII_0
    mov ah, 02h
    int 21h
    mov ah, 09h
    mov dx, msgCierra
    int 21h
    jmp .fin

.divCero:
    mov ah, 09h
    mov dx, msgErr
    int 21h

.fin:
    mov ah, 09h
    mov dx, crlf
    int 21h
    mov ah, 4Ch
    xor al, al
    int 21h

; -------------------------------------------------------------
; imprimirAX: imprime AX como numero decimal.
; Divide repetidamente entre 10; cada resto (digito) se apila y
; luego se desapila en orden inverso. Modifica AX, BX, CX y DX.
; -------------------------------------------------------------
imprimirAX:
    mov bx, 10
    xor cx, cx
.divide:
    xor dx, dx
    div bx                      ; AX = cociente, DX = digito
    push dx
    inc cx
    test ax, ax
    jnz .divide
.popDigit:
    pop dx
    add dl, ASCII_0
    mov ah, 02h
    int 21h
    loop .popDigit
    ret