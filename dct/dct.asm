section .text
global _fdct

_fdct: ;fdct(*in, *out, n)
    mov eax, [esp+4]    ;in
    mov ebx, [esp+8]    ;out
    mov ecx, [esp+12]   ;n
     
    push ecx
    push temp
    push coef 
    push eax
    call mul1 ;A*CT=(A*C)T
    add esp, 16
    
    mov ecx, [esp+12]
    mov ebx, [esp+8]
   
    push mn1
    push ecx
    push ebx
    push temp
    push coef
    call mul3 ;C*(A*CT)T
    add esp, 20
    ret

global _idct

_idct:
    mov eax, [esp+4]    ;in
    mov ebx, [esp+8]    ;out
    mov ecx, [esp+12]   ;n
     
    push ecx
    push temp ;TODO:temp->stack
    push coeft
    push eax
    call mul1 ;A*CT=(A*C)T
    add esp, 16
    
    mov ecx, [esp+12]
    mov ebx, [esp+8]
    
    push mn0
    push ecx
    push ebx
    push temp
    push coeft
    call mul3 ;C*(A*CT)T
    add esp, 20
    ret

mul1: ;mult(m1, m2, out, n)
    mov esi, [esp+4] ;m1
    mov edi, [esp+8] ;m2 C
    mov edx, [esp+12] ;out
    mov ecx, [esp+16] ;n
    loop1_n:
        mov eax, 8
        mov edi, [esp+8]
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
                cmp ebx, 0
                ja loop1_i
            sub esi, 256
            add edi, 32
            dec eax
            cmp eax, 0
            ja loop1_j
        add esi, 256
        dec ecx
        cmp ecx, 0
        ja loop1_n
    ret
mul3: ;mult(m1, m2, out, n)
    mov edi, [esp+4] ;m1 C
    mov esi, [esp+8] ;m2 (A*C)^T
    mov edx, [esp+12] ;out
    mov ecx, [esp+16] ;n
    mov eax, [esp+20]
    movaps xmm5, [eax]
    loop3_n:
        mov eax, 8
        mov edi, [esp+4]
        ;mov esi, [esp+8]
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
        add esi, 256
        dec ecx
        cmp ecx, 0
        ja loop3_n
    ret ;edi - c
    
section .data
    align 16
    mn0: times 4 dd 8.0
    mn1: times 4 dd 0.125
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
    temp: times 64 dd 74 ;<- это очень плохо
