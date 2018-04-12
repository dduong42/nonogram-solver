default rel
extern _calloc
extern _printf
extern _putchar
global _main

%include "variables.inc"

section .text
%include "set_current_count.inc"

; rdi: array
; rsi: length
zero_count:
    xor rax, rax

.loop:
    mov cl, [rdi]
    test cl, cl
    jne .dont_inc

    inc rax

.dont_inc:
    inc rdi
    dec rsi
    jne .loop

    ret


check_lines:
    mov qword [i], 0

.loop_i:
    mov qword [state], 0
    mov qword [j], 0

    call set_current_count_lines
    mov rcx, [current_count]
    mov cl, [rcx]
    mov [count], cl

.loop_j:
    ; c = matrix[i*width+j]
    mov rax, [i]
    mul qword [width]
    add rax, [j]
    add rax, [matrix]

    mov al, [rax]
    mov [c], al

    ; if c == 0, go to the next line
    test al, al
    je .next_line

    cmp qword [state], 1
    je .state_1

    ; state == 0
    cmp byte [c], -1
    je .end_loop_j

    ; c == 1
    mov qword [state], 1
    jmp .decrease_count

.state_1:
    cmp byte [c], 1
    je .decrease_count

    ; c == -1
    cmp byte [count], 0
    jne .return_0

    mov qword [state], 0
    inc qword [current_count]
    mov rcx, [current_count]
    mov cl, [rcx]
    mov [count], cl 
    jmp .end_loop_j

.decrease_count:
    cmp byte [count], 0
    je .return_0
    dec byte [count]

.end_loop_j:
    inc qword [j]
    mov rcx, [j]
    cmp rcx, [width]
    jne .loop_j

    ; End of column check
    cmp byte [count], 0
    jne .return_0

    ; check if *current_count == 0
    mov rcx, [current_count]
    mov cl, [rcx]
    test cl, cl
    je .next_line

    ; check if *(current_count + 1) == 0
    mov rcx, [current_count]
    inc rcx
    mov cl, [rcx]
    test cl, cl
    jne .return_0

.next_line:
    inc qword [i]
    mov rcx, [i]
    cmp rcx, [height]
    jne .loop_i

.return_1:
    mov rax, 1
    ret
.return_0:
    xor rax, rax
    ret

check_columns:
    mov qword [j], 0

.loop_j:
    mov qword [i], 0
    mov qword [state], 0

    call set_current_count_columns
    mov rcx, [current_count]
    mov cl, [rcx]
    mov [count], cl

.loop_i:
    mov rax, [i]
    mul qword [width]
    add rax, [j]
    add rax, [matrix]

    mov al, [rax]
    mov [c], al

    test al, al
    je .next_column

    cmp qword [state], 1
    je .state_1

    ; state == 0
    cmp byte [c], -1
    je .end_loop_i

    ; c == 1
    mov qword [state], 1
    jmp .decrease_count

.state_1:
    cmp byte [c], 1
    je .decrease_count

    ; c == -1
    cmp byte [count], 0
    jne .return_0

    mov qword [state], 0
    inc qword [current_count]
    mov rcx, [current_count]
    mov cl, [rcx]
    mov [count], cl
    jmp .end_loop_i

.decrease_count:
    cmp byte [count], 0
    je .return_0
    dec byte [count]

.end_loop_i:
    inc qword [i]
    mov rcx, [i]
    cmp rcx, [height]
    jne .loop_i

    ; End of line check
    cmp byte [count], 0
    jne .return_0

    mov rcx, [current_count]
    mov cl, [rcx]
    test cl, cl
    je .next_column

    ; *current_count != 0
    mov rcx, [current_count]
    inc rcx
    mov cl, [rcx]
    test cl, cl
    ; *(current_count + 1) != 0
    jne .return_0

.next_column:
    inc qword [j]
    mov rcx, [j]
    cmp rcx, [width]
    jne .loop_j

.return_1:
    mov rax, 1
    ret
.return_0:
    xor rax, rax
    ret


; rdi: i
; rsi: j
solve:
    %push context
    %stacksize flat64
    %assign %$localsize 0
    %local next_i:qword, next_j:qword, matrix_ptr:qword
    enter 32, 0

    ; if i == height: return 1
    cmp rdi, [height]
    je .return_one

    mov [next_i], rdi

    ; if j == width - 1
    mov rcx, [width]
    dec rcx
    cmp rcx, rsi
    je .inc_i

    ; next_j = j + 1
    mov qword [next_j], rsi
    inc qword [next_j]
    jmp .try_pos

.inc_i:
    inc qword [next_i]
    mov qword [next_j], 0

.try_pos:
    mov rax, rdi
    mul qword [width]
    add rax, rsi
    ; rax = i * width + j

    ; rcx = matrix
    mov rcx, [matrix]
    mov [matrix_ptr], rcx
    ; matrix_ptr = matrix + i * width + j
    add qword [matrix_ptr], rax

    ; *matrix_ptr = 1
    mov rcx, [matrix_ptr]
    mov [rcx], byte 1

    call check_lines
    test rax, rax
    je .try_neg

    call check_columns
    test rax, rax
    je .try_neg

    mov rdi, [next_i]
    mov rsi, [next_j]
    call solve
    test rax, rax
    jne .return_one

.try_neg:
    mov rcx, [matrix_ptr]

    ; *matrix_ptr = -1
    mov [rcx], byte -1

    call check_lines
    test rax, rax
    je .return_zero

    call check_columns
    test rax, rax
    je .return_zero

    mov rdi, [next_i]
    mov rsi, [next_j]
    call solve
    test rax, rax
    je .return_zero

.return_one:
    mov rax, 1
    jmp .return

.return_zero:
    ; Clean
    mov rcx, [matrix_ptr]

    ; *matrix_ptr = 0
    mov [rcx], byte 0
    xor rax, rax

.return:
    leave
    ret
    %pop


print_matrix:
    push rbp
    mov rbp, rsp

    mov qword [i], 0

.loop:
    mov rcx, [matrix]
    add rcx, [i]
    mov cl, [rcx]
    and rcx, 0xff

    lea rdi, [format]
    mov rsi, rcx
    call _printf
    jmp .end_loop


.end_loop:
    inc qword [i]

    xor rdx, rdx
    mov rax, [i]
    div qword [width]
    test rdx, rdx
    jne .no_nl

    mov rdi, 0x0a
    call _putchar

.no_nl:
    mov rcx, [total_size]
    cmp rcx, [i]
    jne .loop

    mov rsp, rbp
    pop rbp
    ret


_main:
    push rbp
    mov rbp, rsp

    lea rdi, [lines]
    mov rsi, len_lines
    call zero_count
    mov [height], rax

    lea rdi, [columns]
    mov rsi, len_columns
    call zero_count
    mov [width], rax

    mul qword [height]
    mov [total_size], rax

    mov rdi, [total_size]
    mov rsi, 1
    call _calloc
    test rax, rax
    je .quit

    mov [matrix], rax

    xor rdi, rdi
    xor rsi, rsi
    call solve

    call print_matrix

    mov rsp, rbp
    pop rbp
.quit:
    xor rax, rax
    ret
