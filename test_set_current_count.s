default rel
global _main
extern _printf

%include "variables.inc"

section .data
debug_format: db "%x", 0x0a, 0

section .text
%include "set_current_count.inc"

_main:
    push rbp
    mov rbp, rsp
; Check line 0
%if 0
    mov qword[i], 0
    call set_current_count_lines
    mov rcx, [current_count]
    mov cl, [rcx]
    and rcx, 0xff ; Only care about the bottom of rcx
    lea rdi, [debug_format]
    mov rsi, rcx
    call _printf
%endif
; Check line 3
%if 0
    mov qword[i], 3
    call set_current_count_lines
    mov rcx, [current_count]
    mov cl, [rcx]
    and rcx, 0xff ; Only care about the bottom of rcx
    lea rdi, [debug_format]
    mov rsi, rcx
    call _printf
%endif
; Check column 0
%if 0
    mov qword[j], 0
    call set_current_count_columns
    mov rcx, [current_count]
    mov cl, [rcx]
    and rcx, 0xff ; Only care about the bottom of rcx
    lea rdi, [debug_format]
    mov rsi, rcx
    call _printf
%endif
; Check column 4
%if 1
    mov qword[j], 4
    call set_current_count_columns
    mov rcx, [current_count]
    mov cl, [rcx]
    and rcx, 0xff ; Only care about the bottom of rcx
    lea rdi, [debug_format]
    mov rsi, rcx
    call _printf
%endif
    mov rsp, rbp
    pop rbp
    xor rax, rax
    ret
