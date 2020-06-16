; segment .data
; msg db 'd'
;
; debug:
;     mov ax, 4h
;     mov bx, 1h 
;     mov cx, msg
;     mov dx, 1
;     int 80h
;     ret

;
; struc player_ship
;     loc: resw 1
; endstruc

; set graphic mode
;call debug
mov al, 12h
mov ah, 0
int 10h

mov cx, 10h
mov dx, 18h
mov al, 04h
draw_player_ship:
	mov ah, 0ch
	;add cx, 1h
	;mov dx, 0h
	loop1:
	int 10h

	INC cx
	INC dx
	CMP cx, 80h
	JNE loop1
	ret
; INT 10h / AH = 0Ch - change color for a single pixel. 

mov al, 02h
mov cx, 08h
mov dx, 08h
call draw_player_ship


times 510-($-$$) db 0 ; $ is current mem addr & $$ is section start mem addr
dw 0xAA55		; The standard PC boot signature
