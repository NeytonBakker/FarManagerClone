.code
;-------------------------------------------------------------------------------------------------------------
Make_Sum proc
; int Make_Sum(int one_value, int another_value)
; Параметры:
; RCX - one_value
; RDX - another_value
; Возврат: RAX

	mov eax, ecx
	add eax, edx

	ret

Make_Sum endp
;-------------------------------------------------------------------------------------------------------------
Get_Pos_Address proc
; Параметры:
; RCX - screen_buffer
; RDX - pos
; Возврат: RDI

	mov rax, rdx
	shr rax, 16
	movzx rax, ax

	mov rbx, rdx
	shr rbx, 32
	movzx rbx, bx

	imul rax, rbx

	movzx rbx, dx
	add rax, rbx

	shl rax, 2

	mov rdi, rcx
	add rdi, rax

	ret

Get_Pos_Address endp
;-------------------------------------------------------------------------------------------------------------
Draw_Start_Symbol proc
; Выводим стартовый символ
; Параметры:
; RDI - текущий адрес в буфере окна
; R8 - symbol
; Возврат: нет

	push rax
	push rbx

	mov eax, r8d
	mov rbx, r8
	shr rbx, 32
	mov ax, bx

	stosd

	pop rbx
	pop rax

	ret

Draw_Start_Symbol endp
;-------------------------------------------------------------------------------------------------------------
Draw_End_Symbol proc
; Выводим конечный символ
; Параметры:
; EAX - { symbol.Attributes, symbol.Main_Symbol }
; RDI - текущий адрес в буфере окна
; R8 - symbol
; Возврат: нет

	mov rbx, r8
	shr rbx, 48
	mov ax, bx

	stosd

	ret

Draw_End_Symbol endp
;-------------------------------------------------------------------------------------------------------------
Draw_Line_Horizontal proc
; extern "C" void Draw_Line_Horizontal(CHAR_INFO *screen_buffer, SPos pos, ASymbol symbol);
; Параметры:
; RCX - screen_buffer
; RDX - pos
; R8 - symbol
; Возврат: нет

	push rax
	push rbx
	push rcx
	push rdi

	call Get_Pos_Address

	call Draw_Start_Symbol

	mov eax, r8d
	mov rcx, rdx
	shr rcx, 48

	rep stosd

	call Draw_End_Symbol

	pop rdi
	pop rcx
	pop rbx
	pop rax

	ret

Draw_Line_Horizontal endp
;-------------------------------------------------------------------------------------------------------------
Draw_Line_Vertical proc
; extern "C" void Draw_Line_Vertical(CHAR_INFO *screen_buffer, SPos pos, ASymbol symbol);
; Параметры:
; RCX - screen_buffer
; RDX - pos
; R8 - symbol
; Возврат: нет

	push rax
	push rcx
	push rdi
	push r11

	call Get_Pos_Address

	call Get_Screen_Width_Size
	sub r11, 4

	call Draw_Start_Symbol

	add rdi, r11

	mov rcx, rdx
	shr rcx, 48

	mov eax, r8d

_1:
	stosd
	add rdi, r11

	loop _1

	call Draw_End_Symbol

	pop r11
	pop rdi
	pop rcx
	pop rax

	ret

Draw_Line_Vertical endp
;-------------------------------------------------------------------------------------------------------------
Show_Colors proc
; extern "C" void Show_Colors(CHAR_INFO *screen_buffer, SPos pos, CHAR_INFO symbol);
; Параметры:
; RCX - screen_buffer
; RDX - pos
; R8 - symbol
; Возврат: нет

	push rax
	push rbx
	push rcx
	push rdi
	push r10
	push r11

	call Get_Pos_Address

	mov r10, rdi

	call Get_Screen_Width_Size

	mov rax, r8
	and rax, 0ffffh
	mov rbx, 16

	xor rcx, rcx

_0:
	mov cl, 16

_1:
	stosd
	add rax, 010000h

	loop _1

	add r10, r11
	mov rdi, r10

	dec rbx
	jnz _0

	pop r11
	pop r10
	pop rdi
	pop rcx
	pop rbx
	pop rax

	ret

Show_Colors endp
;-------------------------------------------------------------------------------------------------------------
Get_Screen_Width_Size proc
; Вычисляет ширину экрана в байтах
; RDX - SPos pos или SArea_Pos pos
; Возврат: R11 = pos.Screen_Width * 4

	mov r11, rdx
	shr r11, 32
	movzx r11, r11w
	shl r11, 2

	ret

Get_Screen_Width_Size endp
;-------------------------------------------------------------------------------------------------------------
Clear_Area proc
; extern "C" void Clear_Area(CHAR_INFO *screen_buffer, SArea_Pos area_pos, ASymbol symbol);
; Параметры:
; RCX - screen_buffer
; RDX - area_pos
; R8 - symbol
; Возврат: нет

	push rax
	push rbx
	push rcx
	push rdi
	push r10
	push r11

	call Get_Pos_Address

	mov r10, rdi

	call Get_Screen_Width_Size

	mov rax, r8

	mov rbx, rdx
	shr rbx, 48

	xor rcx, rcx

_0:
	mov cl, bl
	rep stosd

	add r10, r11
	mov rdi, r10

	dec bh
	jnz _0

	pop r11
	pop r10
	pop rdi
	pop rcx
	pop rbx
	pop rax

	ret

Clear_Area endp
;-------------------------------------------------------------------------------------------------------------
Draw_Text proc
; extern "C" int Draw_Text(CHAR_INFO *screen_buffer, SText_Pos pos, const wchar_t *str);
; Параметры:
; RCX - screen_buffer
; RDX - pos
; R8 - str
; Возврат: RAX - длина строки str

	push rbx
	push rdi
	push r8

	call Get_Pos_Address

	mov rax, rdx
	shr rax, 32

	xor rbx, rbx

_1:
	mov ax, [ r8 ]
	cmp ax, 0
	je _exit

	add r8, 2
	stosd
	inc rbx
	jmp _1

_exit:
	mov rax, rbx

	pop r8
	pop rdi
	pop rbx

	ret

Draw_Text endp
;-------------------------------------------------------------------------------------------------------------
Draw_Limited_Text proc
; extern "C" void Draw_Limited_Text(CHAR_INFO *screen_buffer, SText_Pos pos, const wchar_t *str, unsigned short limit);
; Параметры:
; RCX - screen_buffer
; RDX - pos
; R8 - str
; R9 - limit
; Возврат: RAX - длина строки str

	push rax
	push rcx
	push rdi
	push r8
	push r9

	call Get_Pos_Address

	mov rax, rdx
	shr rax, 32

_1:
	mov ax, [ r8 ]
	cmp ax, 0
	je _fill_spaces

	add r8, 2
	stosd

	dec r9
	cmp r9, 0
	je _exit

	jmp _1

_fill_spaces:
	mov ax, 020h
	mov rcx, r9
	rep stosd

_exit:
	pop r9
	pop r8
	pop rdi
	pop rcx
	pop rax

	ret

Draw_Limited_Text endp
;-------------------------------------------------------------------------------------------------------------


end