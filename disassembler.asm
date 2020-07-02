org 0x8000

; Global Initialisations
%define WIDTH 320
%define HEIGHT 200
%define CUSTOM_IMAGE_SIZE 20 ; 20x20 images only
%define BG_COLOR 0x00
%define BULLET_LENGTH 0x05
%define FRAME_DELAY 5240H

GRAPHIC_MEM_A dw 0xA000 ; wont work as macro

; init 320x200 with 256 colors video mode
mov ah, 0x00
mov al, 0x13
int 0x10

mov es, word [GRAPHIC_MEM_A]

call fill_screen
mega_loop:
    pusha

; delay
    MOV     CX, 0x0 ;0FH
    MOV     DX, FRAME_DELAY 
    MOV     AH, 86H
    INT     15H

; change entire screen color
; clears the entire VGA memory space
    ; xor di, di
    ; mov cx, WIDTH*HEIGHT
    ; mov al, 0x0
    ; rep stosb

; draw boundries
; left
xor di,di
add di, 2
mov cx, HEIGHT-1
loopyp:
    add di, WIDTH
    mov [es:di], al
    loop loopyp

;right
mov cx, WIDTH-1
mov al, 0x01
CLD
rep stosb

; up
sub di, 2
mov cx, HEIGHT-1
loopyn:
    sub di, WIDTH
    mov [es:di], al
    loop loopyn

;left
mov cx, WIDTH
mov al, 0x01
STD
rep stosb
;

; remove bullets
mov al, BG_COLOR
mov bx, player
call draw_bullets

mov al, BG_COLOR
mov bx, enemy
call draw_bullets

; remove player ship

mov di, BG_COLOR
mov bx, enemy; 
mov dx, enemy_ship_image
call draw_ship

mov di, BG_COLOR
mov bx, player; 
mov dx, player_ship_image
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

mov si, 0
mov bx, enemy
mov dx, 0xFFFF  ; bullets downward
call move_bullets

mov si, 0
mov bx, player
mov dx, 0  ; bullets upward
call move_bullets

mov al, 0x04
mov bx, player
call draw_bullets

mov al, 0x04
mov bx, enemy
call draw_bullets

mov di, 0xFFFF
mov bx, enemy 
mov dx, enemy_ship_image
call draw_ship

mov di, 0xFFFF
mov bx, player; 
mov dx, player_ship_image
call draw_ship

popa
JMP mega_loop

move_bullets: 
    ; pushad
    ; param bx has struct player
    ; param dx has bullet direction
    mov di, 0
    cmp di, [bx + Player.bullet_index] ; nothing in array
    JE move_bullets_nop
    cmp si, [bx + Player.bullet_index] ; iterated over entire array
    JGE move_bullets_nop
    
    cmp dx, 0
    JE sub_
    add [bx + Player.bullet_xy + si], word WIDTH * BULLET_LENGTH* 2 ; check word bounds
    JMP add_
    sub_:
    sub [bx + Player.bullet_xy + si], word WIDTH * BULLET_LENGTH* 2 ; check word bounds
    add_:
    JC remove_from_array  ; either of add/sub ops is oob

    mov ax, word WIDTH * HEIGHT ; check vga bounds
    cmp ax, [bx + Player.bullet_xy + si]
    JNC dont_remove_from_array 

remove_from_array:
    ; remove current si from array if it is OOB
    mov di, [bx + Player.bullet_index]
    mov di, [bx + Player.bullet_xy + di - 2]
    mov [bx + Player.bullet_xy +si], di
    sub word [bx + Player.bullet_index], 2
    ;

dont_remove_from_array:
    add word si, 2
    JMP move_bullets
    ;
move_bullets_nop:
    ; popad
    ret
;

draw_ship:
    ; pusha
    ; param bx stores structure
    ; param dx stores image
    push di
    xor di, di
    add di, [bx + Player.ship_x]
    mov ax, [bx + Player.ship_y]
    imul ax, WIDTH
    add di, ax
    push di
    
    ; add fire!!
    add di, CUSTOM_IMAGE_SIZE/2 + WIDTH *CUSTOM_IMAGE_SIZE/2
    mov si, [bx + Player.bullet_index]
    cmp [bx + Player.bullet_xy + si], di
    JE draw_ship_no_fire

    mov word [bx + Player.bullet_xy + si], di
    add word [bx + Player.bullet_index], 2
    
    draw_ship_no_fire:
    pop di

    mov cx, 400
    mov si, dx
    mov dx, 0
    CLD
    loop_:
        pop ax
        push ax
        CMP ax, BG_COLOR
        JZ dont_load
        lodsb ; load byte from [si] to al, inc si
        dont_load:

cmp dx, CUSTOM_IMAGE_SIZE ; works for 20x20 images
        JL same_row
        add di, WIDTH
        sub di, dx
        xor dx, dx
    same_row:
        CLD
        inc dx
        stosb ; save byte from al to [di], inc di

        ;mov [es:di], byte 0x04 ; works the same as above
        ;inc di ; --do--
        loop loop_
    pop di
    ; popa
    ret

; Draw bullets
draw_bullets:
    ; param bx contain player struc
    mov si, 0
    cmp si, [bx + Player.bullet_index]
    JZ draw_bullets_ret

draw_bullets_loop:
    mov di, [bx + Player.bullet_xy + si]

    mov dx, BULLET_LENGTH
make_bullet:
    ; cmp di, 0
    ; JL dont_make_bullet
    cmp di, 0
    JE dont_make_bullet
    mov [es:di], byte al
    dont_make_bullet:

sub di, WIDTH

    dec dx
    cmp dx, 0
    JNZ make_bullet

    add si, 2
    cmp si, [bx + Player.bullet_index]
    JL draw_bullets_loop

draw_bullets_ret:
    ; popa
    ret

fill_screen:
    ; pusha
    xor di, di
    mov cx, WIDTH*HEIGHT
    mov al, BG_COLOR
    rep stosb
    ; popa
    ret

; bullet_collison:
;     ; cx param stores, player struc of attacker
;     ; bx param stores, player struc of victim
;     ; returns cx, 0 == no hit, 1 == hit
;     mov di, player
;     mov bx, enemy
;
;     mov si, 0 ;[ax + Player.bullet_index]
;     cmp si, [di + Player.bullet_index]
;     JNE do
;     ret ; no_collison
;
;     do:
;         div [ax + Player.bullet_xy + si], WIDTH ; ax Y dx X
;         cmp dx, [bx + Player.ship_x]
;         JG nope
;         add dx, CUSTOM_IMAGE_SIZE
;         cmp dx, [bx + Player.ship_x]
;         JL nope
;         cmp ax, [bx + Player.ship_y]
;         JL nope
;         add ax, CUSTOM_IMAGE_SIZE
;         cmp ax, [bx + Player.ship_y]
;         JG nope
;         
;         ret ; collison
;         nope:
;         add si, 2
;         cmp si, [di + Player.bullet_index]
;         JL do
;         ret ; no collison

; no code execution after this
; bss and data segments
exit:
player_ship_image: incbin "ship.bin" 
enemy_ship_image: incbin "enemy_ship.bin" 

struc Player
    .ship_x: resw 1
    .ship_y: resw 1
    ; .fire_rate: resb 1
    .bullet_xy: times 100 resw 1
    .bullet_index: resw 1 ;resb wont work
    ; .ship_image: resb CUSTOM_IMAGE_SIZE*CUSTOM_IMAGE_SIZE + CUSTOM_IMAGE_SIZE
endstruc

player:
istruc Player
    at Player.ship_x, dw WIDTH/2 - CUSTOM_IMAGE_SIZE/2
    at Player.ship_y, dw ( HEIGHT/2 - CUSTOM_IMAGE_SIZE/2 )
    ; at Player.fire_rate, db 1
    at Player.bullet_xy, times 100 dw 0
    at Player.bullet_index, dw 0  ; b wont work
    ; at Player.ship_image, incbin "enemy_ship.bin"
iend

enemy:
istruc Player
    at Player.ship_x, dw WIDTH/2 - CUSTOM_IMAGE_SIZE/2
    at Player.ship_y, dw 2 * CUSTOM_IMAGE_SIZE 
    ; at Player.fire_rate, db 1
    at Player.bullet_xy, times 100 dw 0
    at Player.bullet_index, dw 0  ; b wont work
iend



times 512*8 - ($-$$) db 0
