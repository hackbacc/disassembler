org 0x7C00

mov ah, 0
mov al, 12h
int 10h

; mov ah,00			;again subfunc 0
; mov al,03			;text mode 3
; int 10h

;mov es, 0x0000
;
mov al, 1
mov bh, 0
mov bl, 0011_1011b
mov cx, len ; calculate message size.
mov dl, 10
mov dh, 7
push cs
pop es
mov bp, msg1
mov ah, 13h
int 10h 


msg1: db " hello, world! 123213123"
len equ $-msg1

times 510-($-$$) db 0 ; $ is current mem addr & $$ is section start mem addr
dw 0xAA55		; The standard PC boot signature
