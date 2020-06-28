org 0x8000

; Global Initialisations
%define WIDTH 320
%define HEIGHT 200
%define CUSTOM_IMAGE_SIZE 20 ; 20x20 images only
%define BG_COLOR 0x00
%define BULLET_LENGTH 0x05

GRAPHIC_MEM_A dw 0xA000 ; wont work as macro

mov ah, 0x00
mov al, 0x13
int 0x10

mov es, word [GRAPHIC_MEM_A]



mega_loop:
    pusha

; delay
    MOV     CX, 0 ;0FH
    MOV     DX, 4240H
    MOV     AH, 86H
    INT     15H

; change entire screen color
; clears the entire VGA memory space
    ; xor di, di
    ; mov cx, WIDTH*HEIGHT
    ; mov al, 0x0
    ; rep stosb

; draw boundries
xor di,di
mov cx, HEIGHT-1
loopyp:
    add di, WIDTH
    mov [es:di], al
    loop loopyp

mov cx, WIDTH-1
mov al, 0x01
CLD
rep stosb

mov cx, HEIGHT-1
loopyn:
    sub di, WIDTH
    mov [es:di], al
    loop loopyn

mov cx, WIDTH-1
mov al, 0x01
STD
rep stosb

; remove ship
mov di, 0x0000
call draw_ship

; check ks
mov ah, 0x01
int 16h
JNZ ks_avail
JMP ks_na
ks_avail:
    mov ah, 0x00
    int 16h
    cmp al, 'w' ; stop moving
    JZ move_up
    cmp al, 'a' ; stop moving
    JZ move_left
    cmp al, 's' ; stop moving
    JZ move_down
    cmp al, 'd' ; stop moving
    JZ move_right
    JMP ks_na
    move_down:
        inc byte [player+Player.ship_y]
        JMP ks_na
    move_left:
        dec byte [player+Player.ship_x]
        JMP ks_na
    move_up:
        dec byte [player+Player.ship_y]
        JMP ks_na
    move_right:
        inc byte [player+Player.ship_x]
        JMP ks_na
ks_na:
mov di, 0xFFFF
call draw_ship
popa
JMP mega_loop

draw_ship:
    push di
    xor di, di
    add di, [player + Player.ship_x]
    mov ax, [player + Player.ship_y]
    imul ax, WIDTH
    add di, ax
    push di

    ; add fire!!
;     mov cx, len
;     shr cx, 1
;
;     add di, cx
;     mov cx, BULLET_LENGTH
;
; loop__:
;     sub di, WIDTH
;     mov [es:di],byte 0x04
;     loop loop__

    pop di

    mov cx, len
    mov si, test_image
    mov dx, 0
        ;lodsb ; load byte from [si] to al, inc si
        ;lodsb ; load byte from [si] to al, inc si
    CLD
    loop_:
        pop ax
        push ax
        CMP ax, 0x00
        JZ dont_load
        lodsb ; load byte from [si] to al, inc si
        dont_load:

cmp dx, CUSTOM_IMAGE_SIZE ; works for 20x20 images
        JNZ here
        add di, WIDTH
        sub di, dx
        xor dx, dx
    here:
        CLD
        inc dx
        stosb ; save byte from al to [di], inc di

        ;mov [es:di], byte 0x04 ; works the same as above
        ;inc di ; --do--
        loop loop_
    pop di
    ret

; no code execution after this
; bss and data segments
exit:

struc Player
    .ship_x: resw 1
    .ship_y: resw 1
    .fire_rate: resb 1
endstruc

player:
istruc Player
    at Player.ship_x, dw WIDTH/2 - CUSTOM_IMAGE_SIZE/2
    at Player.ship_y, dw ( HEIGHT/2 - CUSTOM_IMAGE_SIZE/2 )
    at Player.fire_rate, db 1
iend

test_image incbin "ship.bin"
len EQU $-test_image
times 512*3 - ($-$$) db 0
