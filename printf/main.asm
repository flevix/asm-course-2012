extern _printf

section .text
global _main

_main:
	mov edx, [esp + 8]
	mov ebx, [edx + 8]
	cmp ebx, 0
	je _one_arg

		push edx	;портится при умножении
	mov ebx, [edx + 4]
	push ebx
	call _parse_format
	add esp, 4
		pop edx
	mov ebx, [edx + 8]
	jmp _two_arg
	
	;если флагов нет, то число в esp+4
_one_arg	
	mov ebx, [edx + 4] ;-> надо как-то сохранить edx
	xor ecx, ecx
	mov [fl], ecx
	mov [f_size], ecx
_two_arg
	push ebx
	call _str2arr	;результат в tbuffer
	add esp, 4
	
	call _normalize	;in: tbuffer. out: hbuffer
	call _invert
	call _convert
	call _arr2str	;in: dbuffer. out: sbuffer
	call _build_ans
	ret
	

_build_ans
	mov esi, dbuffer 
	;mov al, [esi]		; длина числа без знака
	;mov cl, [f_minus]	; если ' ' || '
	cmp [f_minus], byte 1
	je _add_one_minus
	mov ecx, [fl] ; '+'
	and ecx, 00000100b
	cmp ecx, 00000100b
	je _add_one_plus
	mov ecx, [fl] ;' '
	and ecx, 00001000b
	cmp ecx, 00001000b
	je _add_one_space
	jmp _add_null
_add_back
	xor eax, eax
	xor ebx, ebx
	mov al, [esi]
	mov ebx, [f_size]	; длина формата
	sub ebx, eax
	cmp ebx, 0
	jg _build_padding
	jmp _null_term
_build_padding	
	mov ecx, [fl]
	mov dl, 0x20
	and ecx, 00000001b
	cmp ecx, 1b
	je _go_build
	mov ecx, [fl]
	and ecx, 00000010b
	cmp ecx, 10b
	jne _go_build
	mov dl, 0x30
_go_build	
	mov edi, pbuffer
	_go_build_loop
	mov [edi], dl
	inc di
	dec ebx
	cmp ebx, 0
	je _null_term
	jmp _go_build_loop
_null_term
	mov [edi], byte 0
	jmp _combine_str
	
_add_one_minus
	mov edi, sign
	mov [edi], byte 0x2d
	inc di
	mov [edi], byte 0
	jmp _add_one
_add_one_plus
	mov edi, sign
	mov [edi], byte 0x2b
	inc di
	mov [edi], byte 0
	jmp _add_one
_add_one_space
	mov edi, sign
	mov [edi], byte 0x20
	inc di
	mov [edi], byte 0
	jmp _add_one
_add_null
	mov edi, sign
	mov [edi], byte 0
	jmp _add_back
_add_one
	mov al, [esi]
	inc eax
	mov [esi], al
	jmp _add_back
	
_combine_str
	mov ecx, [fl]
	and ecx, 1b
	cmp ecx, 1b
	je _flag_minus
	mov ecx, [fl]
	and ecx, 10b
	cmp ecx, 10b
	je _flag_zero
	;нет флагов
	call _printf_padding
	call _printf_sign
	call _printf_number
	jmp _build_ex
_flag_zero
	call _printf_sign
	call _printf_padding
	call _printf_number
	jmp _build_ex
_flag_minus
	call _printf_sign
	call _printf_number
	call _printf_padding
_build_ex
	ret

_printf_sign
	push sign 
	call _printf
	add esp, 4
	ret
_printf_padding
	push pbuffer
	call _printf
	add esp, 4
	ret
_printf_number
	push sbuffer
	call _printf
	add esp, 4
	ret
	
_arr2str
	mov esi, dbuffer
	mov edi, sbuffer
	mov al, [esi] ;если длина 1 и значение 0 значит минуса нет
	cmp al, 0x1
	jne _ex_add_minus
	mov al, [esi + 1]
	cmp al, 0x0
	jne _ex_add_minus
_del_minus
	mov al, [f_minus]
	xor eax, eax
	mov [f_minus], al
	;mov al, [f_minus] 
	;cmp al, 0x1
	;jne _ex_add_minus
	;mov al, 0x2D
	;mov [edi], al ; '-'
	;inc di
_ex_add_minus
	xor eax, eax
	mov al, [esi]
	add esi, eax
_arr2str_loop
	mov bl, [esi]
	add ebx, 0x30
	mov [edi], bl
	dec si
	inc di
	dec eax
	jnz _arr2str_loop
	mov [edi], byte 0
	ret

_convert
	mov esi, hbuffer
	mov ecx, 0x20	;Длина hex числа
	mov edi, dbuffer
	mov al, 1	;Длина dex числа
	mov [edi], al	
_conv_loop ;идём по всем цифрам hbuffer high -> low
	mov edi, dbuffer
	push ecx
	;умножение на 16
		;dbuffer * 16 + hbuffer[i]
		mov cl, [edi]
		inc di
		xor ebx, ebx
		mov bl, [esi]
	_conv_mult_loop ;dbuffer[0..tsize] * 16
		xor eax, eax
		xor edx, edx
		mov al, [edi]
		mov edx, 0x10
		mul dx
		add ax, bx
		
		xor ebx, ebx ;reduntand line
		xor edx, edx ;reduntand line
			push ebx ;reduntand line
		mov ebx, 10
		cmp al, 0x9
		jae _jmp_div
		mov edx, eax
		xor eax, eax
		jmp _jmp_div2
		_jmp_div
		div ebx
		_jmp_div2
		mov [edi], dl
			pop ebx ;reduntand line
		mov ebx, eax
		
		inc di
		dec ecx
		cmp ecx, 0x00
		jne _conv_mult_loop
		cmp ebx, 0x00
		je _conv_mult_ex
		
		xor ecx, ecx		
		_carry_loop
		
		mov eax, ebx
		mov ebx, 10
		xor edx, edx
		div ebx

		mov [edi], dl
		inc di
		inc ecx
		mov ebx, eax
		cmp ebx, 0x00
		jne _carry_loop
		mov edi, dbuffer
		xor eax, eax
		mov al, [edi]
		add ecx, eax
		mov [edi], cl
	;
	_conv_mult_ex
		;add [si]
	inc si
	pop ecx
	dec ecx
	jnz _conv_loop
	ret
	
_parse_format
	mov esi, [esp + 4]
	xor eax, eax ;size == 0
	xor ecx, ecx ;flags
	dec si
_parse_flags_loop	
	inc si
	mov bl, [esi]
	cmp bl, 0x0 ;
	je _pre_parse_ex
	cmp bl, 0x31 ;'1'
	jae _pre_parse_length
	cmp bl, 0x20 ;' '
	je .space
	cmp bl, 0x2b ;'+'
	je .plus
	cmp bl, 0x2d ;'-'
	je .minus
	cmp bl, 0x30 ;'0'
	je .zero
	; [_, +, 0, -]
.space
	or ecx, 1000b
	jmp _parse_flags_loop
	
.plus
	or ecx, 100b
	jmp _parse_flags_loop

.minus
	or ecx, 1b
	jmp _parse_flags_loop
	
.zero
	or ecx, 10b
	jmp _parse_flags_loop

_pre_parse_ex
	mov [fl], ecx
	jmp _parse_ex
	
_pre_parse_length
	mov [fl], ecx
	xor ecx, ecx
	mov ecx, 10
_parse_length
	sub ebx, 0x30
	add al, bl
	inc si
	mov bl, [esi]
	cmp bl, 0x0
	je _parse_ex
	mul cx
	jmp _parse_length
	
_parse_ex	
	mov [f_size], eax
	ret
	
_invert
	mov esi, hbuffer
	mov eax, 0x20
	mov bl, [esi]
	cmp ebx, 0x8
	jb _inv_ex ;плохой случай 00..00, но его мы не будем инвертировать
	mov ecx, [f_minus] ;меняем знак
	xor ecx, 1
	mov [f_minus], cl	;-----------
_inv_loop	;инвертируем
	mov bl, [esi]
	not ebx
	and ebx, 1111b	;ok!
	mov [esi], bl
	inc si
	dec eax
	jnz _inv_loop
	;xor ebx, ebx
_inv_loop_add	;прибавляем 1
	dec si
	mov bl, [esi]
	cmp bl, 0xF
	jne _inv_l
	mov bl, 0x0
	mov [esi], bl
	jmp _inv_loop_add
	_inv_l
	inc bl
	mov [esi], bl	;ok
_inv_ex	
	ret
	
_normalize
	mov esi, tbuffer
	mov edi, hbuffer
	xor eax, eax
	mov eax, 0x20
	sub eax, [tsize]
	xor ebx, ebx ;zero
	cmp eax, 0
	je _fill_zero_ex
_fill_zero
	mov [edi], bl
	inc di
	dec eax
	cmp eax, 0
	jne _fill_zero
_fill_zero_ex	
	mov eax, [tsize]
_fill_last
	mov bl, [esi]
	mov [edi], bl
	inc di
	inc si
	dec eax
	jnz _fill_last
	ret
		
_str2arr
	xor ebx, ebx
	mov esi, [esp + 4]
	mov edi, tbuffer
	mov al, [esi]
	cmp al, 0x2d
	jne _in	;если не минус
	mov ecx, 1
	mov [f_minus], cl
	inc si
_in	
	mov al, [esi]
	cmp al, 0
	je _ex
	
	or eax, 0x20	; A -> a .. F -> f; 0 -> 0 .. 9 -> 9
	sub eax, 48
	cmp al, 10
	jb _is_digit	; 0..9
	sub eax, 39   ; a..f
_is_digit
	mov [edi], al
	inc ebx
	inc si
	inc di
	jmp _in
_ex	
	mov [tsize], ebx
	ret
section .data ;=(
	f_minus: db 0x00	
	tbuffer resb 32	;array of 32 byte // digits 0 <= d_i < 16
	dbuffer resb 64 ;array of 50 byte - 
	sbuffer resb 64
	hbuffer resb 32 ;// normalise tbuffer.
	pbuffer resb 64
	sign dw ""	;sign
	tsize: dw 0x00	;buff
	dsize: dw 0x01
	fl:	dw 0x00
	f_size: dw 0x00
	s: db "%s",0

