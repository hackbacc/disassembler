org 0x8000

; Global Initialisations
%define WIDTH 320
%define HEIGHT 200
%define CUSTOM_IMAGE_SIZE 20 ; 20x20 images only
%define BG_COLOR 0x00
%define BULLET_LENGTH 0x05
%define FRAME_DELAY 5240H

GRAPHIC_MEM_A dw 0xA000 ; wont work as macro

pusha

xor ax, ax
mov ds, ax
mov es, ax
mov di, enemy
mov si, player
mov cx, Player_size
rep movsb
mov word [enemy+Player.ship_x], CUSTOM_IMAGE_SIZE
mov word [enemy+Player.ship_y], CUSTOM_IMAGE_SIZE

popa


; init strucs
;mov word [object_strucs+Player_size], enemy

; init 320x200 with 256 colors video mode
mov ah, 0x00
mov al, 0x13
int 0x10

mov es, word [GRAPHIC_MEM_A]

call fill_screen
;make non movable objects

;JMP $
mega_loop:
    pusha

; delay
    MOV     CX,  0 ;0FH
    MOV     DX, FRAME_DELAY 
    ; MOV     AH, 86H
    ; INT     15H
    ; mov cx, 0 ;2000;FRAME_DELAY
    ; mov dx, 0
    ;shr cx, 6
    ;shl dx, 10
    ; cx:dx == (2^4)*CX + DX == (2^10)*CX + (2*10)*DX  ~~ 2*CX ms
    mov ax, 0x8600
    int 0x15

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
mov bx, player ;[object_strucs]
call draw_bullets

mov al, BG_COLOR
mov bx, enemy ;[object_strucs + 256]
call draw_bullets

; remove player ship

mov di, BG_COLOR
mov bx, enemy
mov dx, enemy_ship_image
call draw_ship

mov di, BG_COLOR
;mov word [object_strucs], player
;mov bx, player ; [object_strucs]
mov bx, player ;[object_strucs]
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
    cmp al, 'r' ; stop moving
    JZ reset
    cmp al, 'w' ; stop moving
    JZ move_up
    cmp al, 'a' ; stop moving
    JZ move_left
    cmp al, 's' ; stop moving
    JZ move_down
    cmp al, 'd' ; stop moving
    JZ move_right
    JMP ks_na
    reset:
        ;call init_objects
    move_down:
        cmp word [player+Player.ship_y], HEIGHT - CUSTOM_IMAGE_SIZE
        JE ks_na
        inc word [player+Player.ship_y]
        JMP ks_na
    move_left:
        cmp word [player+Player.ship_x], 0
        JE ks_na
        dec word [player+Player.ship_x]
        JMP ks_na
    move_up:
        cmp word [player+Player.ship_y], 0
        JE ks_na
        dec word [player+Player.ship_y]
        JMP ks_na
    move_right:
        cmp word [player+Player.ship_x], WIDTH - CUSTOM_IMAGE_SIZE
        JE ks_na
        inc word [player+Player.ship_x]
        JMP ks_na
ks_na:

mov si, 0
mov bx, enemy ;[object_strucs + Player_size]
mov dx, 0xFFFF  ; bullets downward
call move_bullets

mov si, 0
mov bx, player ;[object_strucs]
mov dx, 0  ; bullets upward
call move_bullets

mov si, player
mov bx, enemy ;[object_strucs + Player_size]
call bullet_collison
push di

; DRAWING STUFF
mov al, 0x04
mov bx, player ;[object_strucs]
call draw_bullets

mov al, 0x04
mov bx, enemy ;[object_strucs + Player_size]
call draw_bullets

; mov ah, 0
; int 0x1A
; mov ax, dx
; xor dx, dx
; mov word cx, WIDTH
; div cx
; mov word [enemy + Player.ship_x], dx

mov bx, enemy ;[object_strucs + Player_size]
mov dx, enemy_ship_image
pop di
call draw_ship

;mov di, 0xFFFF
pop di
mov bx, player ;[object_strucs]
mov dx, player_ship_image
call draw_ship

popa
JMP mega_loop
;reti

move_bullets: ; move in their direction
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
    add [bx + Player.bullet_xy + si], word WIDTH * BULLET_LENGTH* 1 ; check word bounds
    JMP add_
    sub_:
    sub [bx + Player.bullet_xy + si], word WIDTH * BULLET_LENGTH* 1 ; check word bounds
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
    ; param di makes color  == BG_COLOR if it is BG COLOR
    push di
    cmp byte [bx + Player.draw], 0
    JNE yes_draw
    pop di
    ret
yes_draw:
    xor di, di
    add di, [bx + Player.ship_x]
    mov ax, [bx + Player.ship_y]
    imul ax, WIDTH
    add di, ax
    push di
    
    ; add fire!!
    add di, CUSTOM_IMAGE_SIZE/2 + WIDTH *CUSTOM_IMAGE_SIZE/2

    mov si, 0 ;[bx + Player.bullet_index]
    fire_check_loop: ; dont add bullet to array if already present
        cmp [bx + Player.bullet_xy + si], di
        JE draw_ship_no_fire
        add si, 2
        cmp si, [bx + Player.bullet_index]
        JLE fire_check_loop

    ; add fire at
    mov si, [bx + Player.bullet_index]
    add word [bx + Player.bullet_index], 2
    
    draw_ship_no_fire:
    mov word [bx + Player.bullet_xy + si], di
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
        cmp al, BG_COLOR
        JMP .stos
        inc di
        loop loop_
;        stosb ; save byte from al to [di], inc di
.stos:
        stosb
;        inc dl
;        JMP
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

;JMP exit
bullet_collison:
    ; si param stores, player struc of attacker
    ; bx param stores, player struc of victim
    ; returns di, 0 == no hit, 1 == hit
;    mov byte [bx + Player.draw], 0
    push bp
    mov bp, si

    ; check if no bullets
    mov si, 0 ;[ax + Player.bullet_index]
    cmp si, [di + Player.bullet_index]
    JNE do
    pop bp
    mov di, 0xFFFF
    ret ; no_collison

    do:
        mov ax, [bp + Player.bullet_xy + si] ;, WIDTH ; ax Y dx X
;        push cx
        mov cx, WIDTH
        div cx
        ;ax has y, dx has x

        mov cx, [bx + Player.ship_x]
        cmp dx, cx
        JL nope
        add cx, CUSTOM_IMAGE_SIZE

        cmp dx, cx
        JG nope

        mov cx, [bx + Player.ship_y]
        cmp ax, cx
        JL nope
        add cx, CUSTOM_IMAGE_SIZE

        cmp ax, cx
        JG nope

        pop bp
        mov di, BG_COLOR
        mov byte [bx + Player.draw], 0
        ret ; collison

nope:
        add si, 2
        cmp si, [di + Player.bullet_index]
        JL do

        pop bp
        mov di, 0xFFFF
        ret ; no collison

; no code execution after this
; bss and data segments
exit:
player_ship_image: incbin "play_ship.bin" 
enemy_ship_image: incbin "enem_ship.bin" 

struc Player
    .ship_x: resw 1
    .ship_y: resw 1
    ; .fire_rate: resb 1
    .bullet_xy: times 100 resw 1
    .bullet_index: resw 1 ;resb wont work
    .draw: resb 1
    ; .ship_image: resb CUSTOM_IMAGE_SIZE*CUSTOM_IMAGE_SIZE + CUSTOM_IMAGE_SIZE
endstruc

object_strucs: times 100 dw Player_size ; TODO make this dynamic
object_strucs_index: db 0

    player:
    istruc Player
        at Player.ship_x, dw WIDTH/2 - CUSTOM_IMAGE_SIZE/2
        at Player.ship_y, dw ( HEIGHT/2 - CUSTOM_IMAGE_SIZE/2 )
        ; at Player.fire_rate, db 1
        at Player.bullet_xy, times 100 dw 0
        at Player.bullet_index, dw 0  ; b wont work
        at Player.draw, db 1
        ; at Player.ship_image, incbin "enemy_ship.bin"
    iend

    enemy: dw Player_size *2
    ; istruc Player
    ;     at Player.ship_x, dw CUSTOM_IMAGE_SIZE ; WIDTH-CUSTOM_IMAGE_SIZE*2 ; /2 - CUSTOM_IMAGE_SIZE/2
    ;     at Player.ship_y, dw 2 ;2 * CUSTOM_IMAGE_SIZE 
    ;     ; at Player.fire_rate, db 1
    ;     at Player.bullet_xy, times 100 dw 0
    ;     at Player.bullet_index, dw 0  ; b wont work
    ;     at Player.draw, db 1
    ; iend
    ;
    ; ret

times 512*16 - ($-$$) db 0
