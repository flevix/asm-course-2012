section .text
global _fdct

_fdct ;fdct(*in, *out, n)
    push ebx
    push ebp
    push esi
    push edi
    ;4, 8, 12 -> 20, 24, 28
    mov eax, [esp+20] ;in
    mov ebx, [esp+24] ;out
    mov ecx, [esp+28] ;n
    f_loop:
        push ebx

        push coef
        push eax

        call mul1
        pop eax
        add esp, 4

        pop ebx
        push eax

        push mn1
        push coef
        push ebx

        call mul3
        pop ebx
        add esp, 8
        
        pop eax

        add eax, 256
        add ebx, 256
        dec ecx
        jnz f_loop 

    pop edi
    pop esi
    pop ebp
    pop ebx
    ret

global _idct

_idct:
    push ebx
    push ebp
    push esi
    push edi
    ;4, 8, 12 -> 20, 24, 28
    mov eax, [esp+20] ;in
    mov ebx, [esp+24] ;out
    mov ecx, [esp+28] ;n

    i_loop:
        push ebx

        push coeft
        push eax
 
        call mul1 ;A*CT=(A*C)T
        pop eax
        add esp, 4
   
        pop ebx
        push eax

        push mn0
        push coeft
        push ebx

        call mul3 ;C*(A*CT)T
        pop ebx
        add esp, 8

        pop eax

        add eax, 256
        add ebx, 256
        dec ecx
        jnz i_loop

    pop edi
    pop esi
    pop ebp
    pop ebx
    ret

mul1: ;mult(m1, m2, out, n)
    mov esi, [esp+4] ;m1
    mov edi, [esp+8] ;m2 C
    mov edx, temp
    mov eax, 8
    loop1_j:
        mov ebx, 2 
        movaps xmm1, [edi]
        movaps xmm2, [edi+16*1]
        loop1_i:
            pxor xmm4, xmm4
            
            pxor xmm3, xmm3
            movaps xmm0, [esi+16*6]
            mulps xmm0, xmm1
            addps xmm3, xmm0
            movaps xmm0, [esi+16*7]
            mulps xmm0, xmm2
            addps xmm3, xmm0
            haddps xmm3, xmm3
            haddps xmm3, xmm3
            addss xmm4, xmm3 
            pslldq xmm4, 4
            ;store xmm4
            pxor xmm3, xmm3
            movaps xmm0, [esi+16*4]
            mulps xmm0, xmm1
            addps xmm3, xmm0
            movaps xmm0, [esi+16*5]
            mulps xmm0, xmm2
            addps xmm3, xmm0
            haddps xmm3, xmm3
            haddps xmm3, xmm3
            addss xmm4, xmm3 
            pslldq xmm4, 4
            ;store xmm4
            pxor xmm3, xmm3
            movaps xmm0, [esi+16*2]
            mulps xmm0, xmm1
            addps xmm3, xmm0
            movaps xmm0, [esi+16*3]
            mulps xmm0, xmm2
            addps xmm3, xmm0
            haddps xmm3, xmm3
            haddps xmm3, xmm3
            addss xmm4, xmm3 
            pslldq xmm4, 4
            ;store xmm4
            pxor xmm3, xmm3
            movaps xmm0, [esi]
            mulps xmm0, xmm1
            addps xmm3, xmm0
            movaps xmm0, [esi+16*1]
            mulps xmm0, xmm2
            addps xmm3, xmm0
            haddps xmm3, xmm3
            haddps xmm3, xmm3
            addss xmm4, xmm3 
            ;store xmm4
            movaps [edx], xmm4
            add edx, 16
            add esi, 128
            dec ebx
            jnz loop1_i
        sub esi, 256
        add edi, 32
        dec eax
        jnz loop1_j
    ret        

mul3: ;mult(m1, m2, out, n)
    mov edi, [esp+8] ;m1 C
    mov esi, temp
    mov edx, [esp+4] ;out
    mov eax, [esp+12]
    movaps xmm5, [eax]
    mov eax, 8
    loop3_j:
        mov ebx, 2 
        movaps xmm1, [edi]
        movaps xmm2, [edi+16*1]
        loop3_i:
            pxor xmm4, xmm4

            pxor xmm3, xmm3
            movaps xmm0, [esi+16*6]
            mulps xmm0, xmm1
            addps xmm3, xmm0
            movaps xmm0, [esi+16*7]
            mulps xmm0, xmm2
            addps xmm3, xmm0
            haddps xmm3, xmm3
            haddps xmm3, xmm3
            addss xmm4, xmm3 
            pslldq xmm4, 4
            ;store xmm4
            pxor xmm3, xmm3
            movaps xmm0, [esi+16*4]
            mulps xmm0, xmm1
            addps xmm3, xmm0
            movaps xmm0, [esi+16*5]
            mulps xmm0, xmm2
            addps xmm3, xmm0
            haddps xmm3, xmm3
            haddps xmm3, xmm3
            addss xmm4, xmm3 
            pslldq xmm4, 4
            ;store xmm4
            pxor xmm3, xmm3
            movaps xmm0, [esi+16*2]
            mulps xmm0, xmm1
            addps xmm3, xmm0
            movaps xmm0, [esi+16*3]
            mulps xmm0, xmm2
            addps xmm3, xmm0
            haddps xmm3, xmm3
            haddps xmm3, xmm3
            addss xmm4, xmm3 
            pslldq xmm4, 4
            ;store xmm4
            pxor xmm3, xmm3
            movaps xmm0, [esi]
            mulps xmm0, xmm1
            addps xmm3, xmm0
            movaps xmm0, [esi+16*1]
            mulps xmm0, xmm2
            addps xmm3, xmm0
            haddps xmm3, xmm3
            haddps xmm3, xmm3
            addss xmm4, xmm3 
            ;store xmm4
            mulps xmm4, xmm5
            movaps [edx], xmm4
            add edx, 16
            add esi, 128
            dec ebx
            cmp ebx, 0
            ja loop3_i
        sub esi, 256
        add edi, 32
        dec eax
        cmp eax, 0
        ja loop3_j
    ret ;edi - c

section .data
    align 16
    mn0: times 4 dd 8.0
    mn1: times 4 dd 0.125
    temp: times 64 dd 74
    coef: 
dd   0.353553,  0.353553,  0.353553,  0.353553,  0.353553,  0.353553,  0.353553,  0.353553,
dd   0.490393,  0.415735,  0.277785,  0.097545, -0.097545, -0.277785, -0.415735, -0.490393,
dd   0.461940,  0.191342, -0.191342, -0.461940, -0.461940, -0.191342,  0.191342,  0.461940,
dd   0.415735, -0.097545, -0.490393, -0.277785,  0.277785,  0.490393,  0.097545, -0.415735,
dd   0.353553, -0.353553, -0.353553,  0.353553,  0.353553, -0.353553, -0.353553,  0.353553,
dd   0.277785, -0.490393,  0.097545,  0.415735, -0.415735, -0.097545,  0.490393, -0.277785,
dd   0.191342, -0.461940,  0.461940, -0.191342, -0.191342,  0.461940, -0.461940,  0.191342,
dd   0.097545, -0.277785,  0.415735, -0.490393,  0.490393, -0.415735,  0.277785, -0.097545

    coeft:
dd   0.353553,  0.490393,  0.461940,  0.415735,  0.353553,  0.277785,  0.191342,  0.097545,
dd   0.353553,  0.415735,  0.191342, -0.097545, -0.353553, -0.490393, -0.461940, -0.277785,
dd   0.353553,  0.277785, -0.191342, -0.490393, -0.353553,  0.097545,  0.461940,  0.415735,
dd   0.353553,  0.097545, -0.461940, -0.277785,  0.353553,  0.415735, -0.191342, -0.490393,
dd   0.353553, -0.097545, -0.461940,  0.277785,  0.353553, -0.415735, -0.191342,  0.490393,
dd   0.353553, -0.277785, -0.191342,  0.490393, -0.353553, -0.097545,  0.461940, -0.415735,
dd   0.353553, -0.415735,  0.191342,  0.097545, -0.353553,  0.490393, -0.461940,  0.277785,
dd   0.353553, -0.490393,  0.461940, -0.415735,  0.353553, -0.277785,  0.191342, -0.097545
