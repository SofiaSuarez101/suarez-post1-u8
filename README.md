# Post-contenido Unidad 8 — Operaciones con Cadenas y Aritmética en NASM sobre DOSBox

**Asignatura:** Arquitectura de Computadores
**Herramientas:** NASM, DOSBox 0.74 (programas `.com`, modo real de 16 bits)

Este repositorio reúne las dos partes del laboratorio: la Parte 1 trabaja las instrucciones de cadena y la Parte 2 la aritmética de precisión múltiple y BCD. Todos los programas se ensamblan con `nasm -f bin archivo.asm -o archivo.com` y se ejecutan en DOSBox.

## Estructura del repositorio

| Archivo      | Parte | Contenido                                                  |
| ------------ | ----- | ---------------------------------------------------------- |
| `post1.asm`  | 1     | Copia con `REP MOVSB` y versión optimizada con `REP MOVSW` |
| `post1c.asm` | 1     | Búsqueda de un carácter con `REPNE SCASB`                  |
| `post1d.asm` | 1     | Comparación de cadenas con `REPE CMPSB`                    |
| `post1e.asm` | 1     | Copia con transformación a mayúsculas (`LODSB` + `STOSB`)  |
| `post2.asm`  | 2     | Suma y resta de 32 bits con `ADC` y `SBB`                  |
| `post2b.asm` | 2     | Suma y resta BCD empaquetada con `DAA` y `DAS`             |
| `post2c.asm` | 2     | Mini calculadora con `MUL`, `DIV` y `AAM`                  |
| `post2d.asm` | 2     | Suma y resta BCD desempaquetada con `AAA` y `AAS`          |

Cada `.asm` incluye su `.com` generado y las capturas de DOSBox (carpeta `capturas/`).

---
