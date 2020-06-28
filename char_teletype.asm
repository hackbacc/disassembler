org 0x8000
bits 16
push cs
pop ds
mov si, msg

xor dx, dx
mov cx, 400
loop_:
CLD
lodsb
;sub al, 'b'
; mov al, [si]
mov ah, 0x0E
int 0x10
inc dx

cmp dx, 20
JNE aah
xor dx, dx
mov al, ' '
int 0x10

aah:
loop loop_

times 200 db 1
;x times 500 db 1
;msg: incbin "ship.bina"
;msg: dd 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ; 400 A(s)
msg: db 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ; 100 A(s)
;msg dw "ship.bina"
len EQU $-msg
times 512*8 - ($-$$) db 0
