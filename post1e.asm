; =============================================================
; post1e.asm - LODSB + STOSB: copia con transformacion a mayusculas
; Compilar: nasm -f bin post1e.asm -o post1e.com
; Ejecutar: post1e.com   (DOSBox)
; =============================================================
ORG 100h

section .data
; Termina en '$' para poder imprimirla con INT 21h / AH=09h.
origen   db "hola, mundo!$"
LONGITUD     equ $ - origen              ; 13 bytes
destino  times LONGITUD db 0
msgCop   db "Transformado: $"
crlf     db 0Dh,0Ah,"$"

section .text
start:
    mov ax, ds
    mov es, ax                  ; ES = DS

    mov si, origen
    mov di, destino
    mov cx, LONGITUD
    cld                         ; DF=0: SI y DI avanzan hacia adelante
.bucle:
    lodsb                       ; AL = [DS:SI], SI avanza automaticamente
    cmp al, 'a'
    jb .escribir                ; AL < 'a': no es minuscula, no se transforma
    cmp al, 'z'
    ja .escribir                ; AL > 'z': no es minuscula, no se transforma
    sub al, 20h                 ; 'a'-'z' -> 'A'-'Z' (resta 20h)
.escribir:
    stosb                       ; [ES:DI] = AL, DI avanza automaticamente
    loop .bucle                 ; CX = CX - 1; repetir mientras CX != 0

    mov ah, 09h
    mov dx, msgCop
    int 21h
    mov dx, destino
    int 21h
    mov dx, crlf
    int 21h

    mov ah, 4Ch
    xor al, al
    int 21h