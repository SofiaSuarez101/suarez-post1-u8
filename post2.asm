; =============================================================
; post2.asm - ADC y SBB: suma y resta de 32 bits
; Compilar: nasm -f bin post2.asm -o post2.com
; Ejecutar: post2.com   (DOSBox)
; =============================================================
ORG 100h

; ---- Constantes de los operandos ----
; Suma:  A = 0001FFFFh (131071), B = 00010001h (65537)
    A_LO     equ 0FFFFh
    A_HI     equ 0001h
    B_LO     equ 0001h
    B_HI     equ 0001h
    ; Resta: C = 00030000h, D = 00010001h -> esperado 0001FFFFh
    C_LO     equ 0000h
    C_HI     equ 0003h
    D_LO     equ 0001h
    D_HI     equ 0001h

section .data
    aLo      dw A_LO
    aHi      dw A_HI
    bLo      dw B_LO
    bHi      dw B_HI
    resLo    dw 0
    resHi    dw 0
    msgSuma  db "Suma OK: 0003:0000",0Dh,0Ah,"$"
    msgErrS  db "Error en suma.",0Dh,0Ah,"$"
    msgResta db "Resta OK: 0001:FFFF",0Dh,0Ah,"$"
    msgErrR  db "Error en resta.",0Dh,0Ah,"$"

section .text
start:
    ; ---------- Paso 1: suma de 32 bits ----------
    mov ax, [aLo]
    mov dx, [aHi]
    mov bx, [bLo]
    mov cx, [bHi]
    add ax, bx                  ; FFFFh + 0001h = 0000h, CF=1
    adc dx, cx                  ; 0001h + 0001h + CF(1) = 0003h
    mov [resLo], ax
    mov [resHi], dx

    cmp ax, 0000h
    jne .errorSuma
    cmp dx, 0003h
    jne .errorSuma
    mov ah, 09h
    mov dx, msgSuma
    int 21h
    jmp .resta
.errorSuma:
    mov ah, 09h
    mov dx, msgErrS
    int 21h

    ; ---------- Paso 2: resta de 32 bits ----------
.resta:
    mov ax, C_LO
    mov dx, C_HI
    mov bx, D_LO
    mov cx, D_HI
    sub ax, bx                  ; 0000h - 0001h = FFFFh, CF=1 (prestamo)
    sbb dx, cx                  ; 0003h - 0001h - CF(1) = 0001h
    ; Resultado: DX:AX = 0001:FFFFh = 0001FFFFh
    cmp ax, 0FFFFh
    jne .errorResta
    cmp dx, 0001h
    jne .errorResta
    mov ah, 09h
    mov dx, msgResta
    int 21h
    jmp .fin
.errorResta:
    mov ah, 09h
    mov dx, msgErrR
    int 21h

.fin:
    mov ah, 4Ch
    xor al, al
    int 21h