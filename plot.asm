
; set graphic mode
mov al, 12h
mov ah, 0
int 10h

; INT 10h / AH = 0Ch - change color for a single pixel. 
mov ah, 0ch
mov al, 04h
mov cx, 14h
mov dx, 14h
int 10h

times 510-($-$$) db 0 ; $ is current mem addr & $$ is section start mem addr
dw 0xAA55		; The standard PC boot signature


