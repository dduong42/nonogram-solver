section .data
lines:
    db 3, 0
    db 1, 1, 0
    db 1, 2, 0
    db 2, 1, 0
    db 1, 3, 0
    db 1, 2, 0
    db 1, 1, 1, 0
len_lines: equ $ - lines
columns:
    db 1, 1, 1, 0
    db 1, 0
    db 1, 2, 0
    db 1, 1, 3, 0
    db 5, 0
    db 1, 2, 0
    db 1, 0
len_columns: equ $ - columns
format: db "%02x ", 0


section .bss
height: resq 1
width: resq 1
total_size: resq 1
matrix: resq 1
current_count: resq 1
state: resq 1
i: resq 1
j: resq 1
c: resb 1
count: resb 1
