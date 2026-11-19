; =============================================================
; post1.asm - REP MOVSB y REP MOVSW: copia de cadenas
; Compilar: nasm -f bin post1.asm -o post1.com
; Ejecutar: post1.com   (DOSBox)
; =============================================================
ORG 100h

section .data
; INT 21h / AH=09h imprime hasta encontrar '$', por eso la cadena
; termina en '$' (13 bytes en total: 12 caracteres + '$').
origen   db "HOLA, MUNDO!$"
LONGITUD     equ $ - origen              ; 13 bytes a copiar
destino1 times LONGITUD db 0             ; destino de la copia con MOVSB
destino2 times LONGITUD db 0             ; destino de la copia con MOVSW
msgMovsb db "Copiado (MOVSB): $"
msgMovsw db "Copiado (MOVSW): $"
msgIgual db "Ambas copias coinciden.$"
msgDifer db "Las copias NO coinciden.$"
crlf     db 0Dh,0Ah,"$"

section .text
start:
    ; ES = DS (en un .com ambos apuntan al mismo segmento).
    ; No existe "mov es, ds": se pasa por AX.
    mov ax, ds
    mov es, ax

    ; ---------- Paso 1: copia con REP MOVSB (1 byte por iteracion) ----------
    mov si, origen
    mov di, destino1
    mov cx, LONGITUD
    cld                         ; DF=0: de direcciones bajas a altas
    rep movsb                   ; copia CX bytes de DS:SI a ES:DI

    mov ah, 09h
    mov dx, msgMovsb
    int 21h
    mov dx, destino1
    int 21h
    mov dx, crlf
    int 21h

    ; ---------- Paso 2: copia con REP MOVSW + MOVSB para el byte impar ----------
    mov si, origen
    mov di, destino2
    mov cx, LONGITUD                ; longitud total (13)
    cld
    mov ax, cx                  ; guardar la longitud para revisar si es impar
    shr cx, 1                   ; CX = 13 / 2 = 6 words
    rep movsw                   ; copia 6 words (12 bytes)
    and ax, 1                   ; 13 AND 1 = 1 -> hay byte sobrante
    jz .sinImpar
    movsb                       ; copia el byte sobrante (el 13)
.sinImpar:
    mov ah, 09h
    mov dx, msgMovsw
    int 21h
    mov dx, destino2
    int 21h
    mov dx, crlf
    int 21h

    ; ---------- Verificacion: destino1 y destino2 deben ser identicos ----------
    mov si, destino1
    mov di, destino2
    mov cx, LONGITUD
    cld
    repe cmpsb                  ; ZF=1 al terminar si todo fue igual
    jne .distintas
    mov dx, msgIgual
    jmp .mostrar
.distintas:
    mov dx, msgDifer
.mostrar:
    mov ah, 09h
    int 21h
    mov dx, crlf
    int 21h

    mov ah, 4Ch
    xor al, al
    int 21h