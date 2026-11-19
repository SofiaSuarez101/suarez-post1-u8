; =============================================================
; post1c.asm - REPNE SCASB: buscar un caracter en una cadena
; Arquitectura de Computadores - Unidad 8 - Parte 1 (Paso 3)
; Compilar: nasm -f bin post1c.asm -o post1c.com
; Ejecutar: post1c.com   (DOSBox)
;
; REPNE SCASB compara AL con [ES:DI], avanza DI y decrementa CX
; mientras NO haya coincidencia (ZF=0) y CX > 0.
;   - Al terminar con ZF=1: hallado, DI apunta UN byte despues.
;   - Al terminar con ZF=0: no existe en los CX bytes revisados.
; =============================================================
ORG 100h

section .data
cadena   db "Arquitectura de Computadores",0
longCad  equ $ - cadena - 1          ; 28 caracteres, sin el nulo
msgHall  db "Hallado en posicion: $"
msgNoH   db "No encontrado.$"
crlf     db 0Dh,0Ah,"$"

section .text
start:
    mov ax, ds
    mov es, ax                  ; ES = DS

    mov al, 'd'                 ; busqueda 1: existe -> posicion 13
    call buscarCaracter

    mov ah, 4Ch
    xor al, al
    int 21h

; -------------------------------------------------------------
; buscarCaracter: busca AL en "cadena" e imprime el resultado.
; Entrada: AL = caracter a buscar
; -------------------------------------------------------------
buscarCaracter:
    mov di, cadena
    mov cx, longCad
    cld                         ; DF=0: DI avanza hacia adelante
    repne scasb
    jne .noHallado              ; ZF=0 al terminar -> no encontrado

    ; Posicion base-0 = DI actual - inicio - 1
    mov bx, di
    sub bx, cadena
    dec bx

    mov ah, 09h
    mov dx, msgHall
    int 21h
    mov ax, bx
    call imprimirAX             ; la posicion puede tener 2 digitos
    jmp .nuevaLinea

.noHallado:
    mov ah, 09h
    mov dx, msgNoH
    int 21h

.nuevaLinea:
    mov ah, 09h
    mov dx, crlf
    int 21h
    ret

; -------------------------------------------------------------
; imprimirAX: imprime AX como numero decimal (division repetida
; entre 10; los restos se apilan y se imprimen en orden inverso).
; Modifica AX, BX, CX y DX.
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
    add dl, 30h                 ; a ASCII
    mov ah, 02h
    int 21h
    loop .popDigit
    ret