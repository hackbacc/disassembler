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

; draw canvas
mov ah, 0
mov al, 12h
int 10h

; draw stuff
%macro draw_enemy_ship 2
mov cx, %1
mov dx, %2

%%loop_dx?:
INC cx
call draw
CMP cx, 0x40 + %1
JLE %%loop_dx?

%%loop_mdxdy:
DEC cx
INC dx
call draw
CMP cx, 0x20 + %1
JGE %%loop_mdxdy
;
%%loop_mdxmdy:
DEC cx
DEC dx
call draw
CMP cx, 0x0 + %1
JGE %%loop_mdxmdy


%endmacro

mov ax, 0x00

loop:
push ax
;add ax, 100
draw_enemy_ship 100, 100
draw_enemy_ship 10, 10
pop ax
INC ax
cmp ax, 0x05
;JL loop


print msg1, len1, 10, 10

; data segment
draw:
    mov al, 0x01 ; color
    mov ah, 0x0c ; change color
    int 10h
    ret
msg1: db "a pressed"
len1 equ $-msg1
skipm: db "skipping"
lenskip equ $-skipm

skip:
print skipm, lenskip, 0, 0 
times 510-($-$$) db 0 ; $ is current mem addr & $$ is section start mem addr
dw 0xAA55		; The standard PC boot signature
