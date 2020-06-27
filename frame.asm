org 0x7C00

struc Ship
    .fire_locy: resw 1
    .x: resw 1
    .y: resw 1
endstruc


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

%macro draw_fire 1
;mov dx, 0x10
mov cx, %1
;pop dx
add dx, bx

mov si, dx
add si, 0x08

%%loop_dy:
call draw
INC dx

CMP dx, si
JLE %%loop_dy


%endmacro

mov dword [0x0070], loop

; display mode
mov ah, 0
mov al, 12h
int 10h

; mov dx, 0x10
;jmp last

mov bx, 0
loop:
    inc bx

    mov cx, bx
    inc bx
    mov dx, 10
;    add dx, bx

    mov si, dx
    add si, 0x08

 loop_dy:
    call draw
    INC dx

    CMP dx, si
    JLE loop_dy

    ; mov dx, 0x10
    ; inc dx
    ; push dx
    ; draw_fire 0x10
    iret

draw:
    mov al, 0x04 ; color
    mov ah, 0x0c ; change color
    int 10h
    ret

last:

msg1: db "a pressed"
len1 equ $-msg1
skipm: db "skipping"
lenskip equ $-skipm

istruc Ship
    at Ship.fire_locy, dw 100
    at Ship.x, dw 100
    at Ship.y, dw 100
iend


times 510-($-$$) db 0 ; $ is current mem addr & $$ is section start mem addr
dw 0xAA55		; The standard PC boot signature
