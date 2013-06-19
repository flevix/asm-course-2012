section .text
global dbl2str

dbl2str:
    ;rbx, rbp, r12-r15
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    ;-----------------
    ;+inf, -inf, nan
    ;de-norm
    ;rdi - double *in
    ;rsi - char *out_buf


    call grisu


    ;rbx, rbp, r12-r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ;------------------
    ret

grisu: ;rdi - *in, rsi - *out
    mov [rdi], 0
    ret
