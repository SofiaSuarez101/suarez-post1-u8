; =============================================================
; post2b.asm - DAA y DAS: suma y resta BCD empaquetada
; Compilar: nasm -f bin post2b.asm -o post2b.com
; Ejecutar: post2b.com   (DOSBox)
; =============================================================
ORG 100h

; ---- Constantes BCD (cada valor es el numero decimal en hexa) ----
BCD_A      equ 47h              ; "47"
BCD_B      equ 38h              ; "38"
ESP_SUMA   equ 85h              ; 47 + 38 = "85"
BCD_C      equ 73h              ; "73"
BCD_D      equ 28h              ; "28"
ESP_RESTA1 equ 45h              ; 73 - 28 = "45"
BCD_E      equ 20h              ; "20"
BCD_F      equ 01h              ; "01"
ESP_RESTA2 equ 19h              ; 20 - 01 = "19"
BCD_G      equ 99h              ; "99"
BCD_H      equ 01h              ; "01"

section .data
bcd1      db BCD_A
bcd2      db BCD_B
resultado db 0
msgSinDaa db "Sin DAA : $"
msgSuma   db "BCD suma: $"
msgAcarr  db "BCD 99+01: $"
msgCF     db "  CF=$"
msgDasOk  db "DAS OK: $"
msgDasErr db "DAS ERROR$"
crlf      db 0Dh,0Ah,"$"

section .text
start:
    ; ---------- Paso 3: suma BCD con DAA ----------
    ; Primero se muestra el resultado SIN ajustar (7Fh, no es BCD valido)
    mov ah, 09h
    mov dx, msgSinDaa
    int 21h
    mov al, [bcd1]
    add al, [bcd2]              ; 47h + 38h = 7Fh
    call imprimirHex
    call nuevaLinea

    ; Ahora con DAA
    mov al, [bcd1]
    add al, [bcd2]              ; AL = 7Fh
    daa                         ; AL = 85h (BCD correcto)
    mov [resultado], al
    mov ah, 09h
    mov dx, msgSuma
    int 21h
    mov al, [resultado]
    call imprimirHex            ; imprime "85"
    call nuevaLinea

    ; Caso con acarreo: 99h + 01h = 00h con CF=1
    mov al, BCD_G
    add al, BCD_H               ; 99h + 01h = 9Ah
    daa                         ; AL = 00h, CF=1
    mov bl, 0                   ; MOV no altera flags
    adc bl, 0                   ; BL = CF (capturado antes de usar INT 21h)
    mov [resultado], al
    mov ah, 09h
    mov dx, msgAcarr
    int 21h
    mov al, [resultado]
    call imprimirHex            ; imprime "00"
    mov ah, 09h
    mov dx, msgCF
    int 21h
    mov dl, bl
    add dl, 30h
    mov ah, 02h
    int 21h                     ; imprime el valor de CF
    call nuevaLinea

    ; ---------- Paso 4: resta BCD con DAS ----------
    mov al, BCD_C
    sub al, BCD_D               ; 73h - 28h = 4Bh (no es BCD valido)
    das                         ; AL = 45h
    cmp al, ESP_RESTA1
    jne .errorDas
    mov [resultado], al
    mov ah, 09h
    mov dx, msgDasOk
    int 21h
    mov al, [resultado]
    call imprimirHex            ; imprime "45"
    call nuevaLinea

    ; Caso con ajuste del nibble bajo: 20h - 01h = 1Fh -> 19h
    mov al, BCD_E
    sub al, BCD_F               ; AL = 1Fh (nibble bajo Fh > 9)
    das                         ; AL = 19h, CF=0
    cmp al, ESP_RESTA2
    jne .errorDas
    mov [resultado], al
    mov ah, 09h
    mov dx, msgDasOk
    int 21h
    mov al, [resultado]
    call imprimirHex            ; imprime "19"
    call nuevaLinea
    jmp .fin

.errorDas:
    mov ah, 09h
    mov dx, msgDasErr
    int 21h
    call nuevaLinea

.fin:
    mov ah, 4Ch
    xor al, al
    int 21h

; -------------------------------------------------------------
; imprimirHex: imprime AL como dos digitos (nibble alto y bajo).
; Con BCD valido todos los digitos son 0-9; con un valor sin
; ajustar (como 7Fh) los nibbles > 9 salen como letras A-F.
; Entrada: AL. Conserva todos los registros.
; -------------------------------------------------------------
imprimirHex:
    push ax
    push dx
    mov dh, al                  ; copia del byte
    shr al, 4                   ; nibble alto (decenas)
    call .nibble
    mov al, dh
    and al, 0Fh                 ; nibble bajo (unidades)
    call .nibble
    pop dx
    pop ax
    ret
.nibble:
    add al, 30h                 ; a ASCII
    cmp al, '9'
    jbe .imprimir
    add al, 7                   ; 3Ah.. -> 'A'..'F'
.imprimir:
    mov dl, al
    mov ah, 02h
    int 21h
    ret

; -------------------------------------------------------------
; nuevaLinea: imprime CR+LF (modifica AH y DX).
; -------------------------------------------------------------
nuevaLinea:
    mov ah, 09h
    mov dx, crlf
    int 21h
    ret