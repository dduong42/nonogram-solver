set_current_count_lines:
    mov rcx, [i]
    lea r8, [lines]
.loop:
    test rcx, rcx
    je .return
    mov dl, [r8]
    test dl, dl
    jne .end_loop
    dec rcx
.end_loop:
    inc r8
    jmp .loop
.return:
    mov [current_count], r8
    ret


set_current_count_columns:
    mov rcx, [j]
    lea r8, [columns]
.loop:
    test rcx, rcx
    je .return
    mov dl, [r8]
    test dl, dl
    jne .end_loop
    dec rcx
.end_loop:
    inc r8
    jmp .loop
.return:
    mov [current_count], r8
    ret
