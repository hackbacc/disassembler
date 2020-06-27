org 0x7C00
; player ship attributes
struct Ship
    .fire_locy: resw 1
    .x: resw 1
    .y: resw 1
endstruc

istruc Ship
    at Ship.fire_locy, dw 100
    at Ship.x, dw 100
    at Ship.y, dw 100
endstruc

; draw canvas
mov ah, 0
mov al, 12h
int 10h

%macro draw_fire 2
mov cx, %1
mov dx, %2
add dx, bx

mov si, dx
add si, 0x08

%%loop_dy:
call draw
INC dx

CMP dx, si
JLE %%loop_dy


%endmacro

xor bx, bx
;mov si, bx
loop:
    ;add si, 0x02 + 0x08
    draw_fire 10,10
    draw_fire 20,20
    add bx, 0xf
    JMP loop



draw:
    mov al, 0x04 ; color
    mov ah, 0x0c ; change color
    int 10h
    ret

times 510-($-$$) db 0 ; $ is current mem addr & $$ is section start mem addr
dw 0xAA55		; The standard PC boot signature
