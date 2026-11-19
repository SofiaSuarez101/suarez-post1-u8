; =============================================================
; post2d.asm - AAA y AAS: ajuste de BCD desempaquetado
; Compilar: nasm -f bin post2d.asm -o post2d.com
; Ejecutar: post2d.com   (DOSBox)
; =============================================================
ORG 100h

ASCII_0   equ 30h
DIG_7     equ 07h               ; digito "7"
DIG_8     equ 08h               ; digito "8"
DIG_3     equ 03h               ; unidades de "13"
DECENA_1  equ 01h               ; decena de "13"

section .data
    msgSuma   db "AAA: 7 + 8 = $"
    msgResta  db 0Dh,0Ah,"AAS: 13 - 8 = $"
    crlf      db 0Dh,0Ah,"$"

section .text
start:
    ; ---------- Suma desempaquetada con AAA: 7 + 8 = 15 ----------
    mov ah, 09h
    mov dx, msgSuma
    int 21h

    mov ax, DIG_7               ; AH = 0 (decenas), AL = 07h
    add al, DIG_8               ; AL = 07h + 08h = 0Fh (no es BCD valido)
    aaa                         ; AL = 05h (unidades), AH = 01h (decenas), CF=1
    mov bx, ax                  ; BH = decenas, BL = unidades

    mov dl, bh
    add dl, ASCII_0
    mov ah, 02h
    int 21h                     ; imprime la decena ("1")
    mov dl, bl
    add dl, ASCII_0
    mov ah, 02h
    int 21h                     ; imprime la unidad ("5")

    ; ---------- Resta desempaquetada con AAS: 13 - 8 = 5 ----------
    mov ah, 09h
    mov dx, msgResta
    int 21h

    mov ax, (DECENA_1 << 8) | DIG_3   ; AH = 01h (decena de "13"), AL = 03h
    sub al, DIG_8               ; AL = 03h - 08h = FBh (hubo prestamo)
    aas                         ; AL = 05h, AH = 00h (le quito 1 a la decena), CF=1
    mov bx, ax                  ; BH = decenas, BL = unidades

    cmp bh, 0
    je .soloUnidades            ; la decena quedo en 0: no se imprime
    mov dl, bh
    add dl, ASCII_0
    mov ah, 02h
    int 21h
.soloUnidades:
    mov dl, bl
    add dl, ASCII_0
    mov ah, 02h
    int 21h                     ; imprime la unidad del resultado ("5")

    mov ah, 09h
    mov dx, crlf
    int 21h

    mov ah, 4Ch
    xor al, al
    int 21h