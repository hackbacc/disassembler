org 0x7C00
;--------------------- 0x0
;| Interrupts vectors
;--------------------- 0x400
;| BIOS data area
;--------------------- 0x5??
;| OS load area
;--------------------- 0x7C00
;| Boot sector
;--------------------- 0x7E00
;| Boot data/stack
;--------------------- 0x7FFF
;| (not used)
;--------------------- (...)

mov al, 12h
mov ah, 0
int 10h

mov cx, 10h
mov dx, 18h
mov al, 04h
; INT 10h / AH = 0Ch - change color for a single pixel. 

mov si, 0x80
mov al, 02h
; mov cx, 40h
; mov dx, 40h
push 20h
push 10h
call draw_player_ship

; mov al, 02h
; mov cx, 10h
; mov dx, 20h
;call draw_player_ship
JMP after_func

draw_player_ship:
    push ebp
    mov ebp, esp
    mov edx, [ebp+8]
    mov ecx, [ebp+6]

    push ecx
    push edx

	mov ah, 0ch
	;add cx, 1h
	;mov dx, 0h
	loop1:
	int 10h

	INC cx
	INC dx
	CMP cx, si
	JLE loop1
    
    push ax
    push bx
    push dx
    mov ax, si
    mov bx, 2
    mul bx
    mov si, ax
    pop dx
    pop bx
    pop ax

    mov al, 03h
    ; mov cx, 12h
    ; mov dx, 24h

loop2:
	int 10h

	INC cx
	DEC dx
    ; pop si
    ; pop si

	CMP cx, si
	JLE loop2

    mov al, 04h

loop3:
	int 10h

	DEC cx

    pop si
    pop si

	CMP cx, si
	JGE loop3

    mov esp, ebp
    pop ebp

    ret

after_func:

times 510-($-$$) db 0 ; $ is current mem addr & $$ is section start mem addr
dw 0xAA55		; The standard PC boot signature
