org 0x7C00

%macro print 4
    mov al, 1
    mov bh, 0
    mov bl, 0x04
    mov cx, %2 ; calculate message size.
    mov dl, %3
    mov dh, %4
    push cs
    pop es
    mov bp, %1
    mov ah, 13h
    int 10h 
%endmacro

mov ah, 0
mov al, 12h
int 10h

; check ks
wait_:
mov ah, 0x01
int 16h
;
; print msg2, len2, 10, 10
JZ wait_

cmp al, 'a'
JNZ skip
; mov ah, 0x00
; int 16h

; mov al, 'a'
; mov ah, 0x0e
; int 0x10


print msg1, len1, 10, 10
;print msg2, len2, 10, 10

msg1: db "a pressed"
len1 equ $-msg1
skipm: db "skipping"
lenskip equ $-skipm

skip:
print skipm, lenskip, 0, 0 
times 510-($-$$) db 0 ; $ is current mem addr & $$ is section start mem addr
dw 0xAA55		; The standard PC boot signature
