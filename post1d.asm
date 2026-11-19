; =============================================================
; post1d.asm - REPE CMPSB: comparar cadenas
; Compilar: nasm -f bin post1d.asm -o post1d.com
; Ejecutar: post1d.com   (DOSBox)
; =============================================================
ORG 100h

section .data
cad1     db "NASM x86",0
longCmp  equ $ - cad1 - 1            ; 8 caracteres, sin el nulo
cad2     db "NASM x86",0
cad3     db "NASM ARM",0             ; difiere en el indice 5 ('x' vs 'A')
msgIg    db "Iguales.$"
msgDif   db "Diferentes.$"
crlf     db 0Dh,0Ah,"$"

section .text
start:
    mov ax, ds
    mov es, ax                  ; ES = DS

    ; ---------- Caso 1: cad1 vs cad2 (deben ser iguales) ----------
    mov si, cad1
    mov di, cad2
    mov cx, longCmp
    cld                         ; DF=0: SI y DI avanzan hacia adelante
    repe cmpsb
    je .iguales1                ; ZF=1 -> las 8 posiciones coincidieron
    mov ah, 09h
    mov dx, msgDif
    int 21h
    jmp .caso2
.iguales1:
    mov ah, 09h
    mov dx, msgIg
    int 21h
.caso2:
    mov ah, 09h
    mov dx, crlf
    int 21h

    ; ---------- Caso 2: cad1 vs cad3 (deben ser diferentes) ----------
    ; REPE CMPSB se detiene tras comparar el indice 5 ('x' vs 'A'):
    ; ZF=0, CX=2 y SI = cad1 + 6.
    mov si, cad1
    mov di, cad3
    mov cx, longCmp
    cld
    repe cmpsb
    je .iguales2
    mov ah, 09h
    mov dx, msgDif
    int 21h
    jmp .fin
.iguales2:
    mov ah, 09h
    mov dx, msgIg
    int 21h
.fin:
    mov ah, 09h
    mov dx, crlf
    int 21h

    mov ah, 4Ch
    xor al, al
    int 21h