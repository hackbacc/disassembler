org 0x8000

; Global Initialisations
%define WIDTH 320
%define HEIGHT 200
%define CUSTOM_IMAGE_SIZE 20 ; 20x20 images only
%define BG_COLOR 0x00
%define BULLET_LENGTH 0x05
%define FRAME_DELAY 0 ;xf240
%define N_ENEMIES 4
%define QUANTA_PLAYER_SIZE 0x100

GRAPHIC_MEM_A dw 0xA000 ; wont work as macro

pusha

xor ax, ax
mov ds, ax
mov es, ax

mov di, enemies
mov si, player
mov cx, Player_size
rep movsb

mov si, enemies
mov word [si+Player.ship_x], CUSTOM_IMAGE_SIZE * 4
mov word [si+Player.ship_y], CUSTOM_IMAGE_SIZE

mov di, enemies
add di, QUANTA_PLAYER_SIZE
mov si, player
mov cx, Player_size
rep movsb

mov si, enemies
add si, QUANTA_PLAYER_SIZE
mov word [si+Player.ship_x], WIDTH - CUSTOM_IMAGE_SIZE*5
mov word [si+Player.ship_y], CUSTOM_IMAGE_SIZE

mov di, enemies
add di, QUANTA_PLAYER_SIZE*2
mov si, player
mov cx, Player_size
rep movsb

mov si, enemies
add si, QUANTA_PLAYER_SIZE*2
mov word [si+Player.ship_x], CUSTOM_IMAGE_SIZE*6
mov word [si+Player.ship_y], CUSTOM_IMAGE_SIZE

mov di, enemies
add di, QUANTA_PLAYER_SIZE*3
mov si, player
mov cx, Player_size
rep movsb

mov si, enemies
add si, QUANTA_PLAYER_SIZE*3
mov word [si+Player.ship_x], WIDTH - CUSTOM_IMAGE_SIZE*7
mov word [si+Player.ship_y], CUSTOM_IMAGE_SIZE
;
popa

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


; remove player ship

; mov cx, N_ENEMIES
; mov bx, enemies
; .remove_enemy_ships:
;     mov di, BG_COLOR
;     mov dx, enemy_ship_image
;     pusha
;     call draw_ship
;     popa
;     add bx, QUANTA_PLAYER_SIZE
;     loop .remove_enemy_ships
;
; mov di, BG_COLOR
; mov bx, player
; mov dx, player_ship_image
; call draw_ship
;

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
call fill_screen

; remove bullets
; mov al, BG_COLOR
; mov bx, player
; call draw_bullets
;
; mov cx, N_ENEMIES
; mov bx, enemies
; .remove_enemy_bullets:
;     mov al,BG_COLOR
;     pusha
;     call draw_bullets
;     popa
;     add bx, QUANTA_PLAYER_SIZE
;     loop .remove_enemy_bullets

mov cx, N_ENEMIES
mov bx, enemies
.move_enemy_bullets:
    mov si, 0
    mov dx, 0xFFFF
    pusha
    call move_bullets
    popa
    add bx, QUANTA_PLAYER_SIZE
    loop .move_enemy_bullets

;
mov si, 0
mov bx, player
mov dx, 0
call move_bullets

; DRAWING STUFF

; draw bullets 
mov al, 0x03
mov bx, player
call draw_bullets

xor cx, N_ENEMIES
mov bx, enemies
.draw_enemy_bullets:
    mov al, 0x02
    pusha
    call draw_bullets
    popa
    add bx, QUANTA_PLAYER_SIZE
    loop .draw_enemy_bullets

mov cx, N_ENEMIES
mov bx, enemies
.check_bullet_collison:
    mov si, player
    pusha
    call bullet_collison ; updated di == collision
    popa
    add bx, QUANTA_PLAYER_SIZE
    loop .check_bullet_collison

mov di, 0xFFFF
mov bx, player
mov dx, player_ship_image
mov di, 0xFFFF
call draw_ship

mov cx, N_ENEMIES
mov bx, enemies
.draw_enemy_ship:
    mov di, 0xFFFF
;    mov bx, enemies
    ;add bx, 0
    mov dx, enemy_ship_image
    pusha
    call draw_ship
    popa
    add bx, QUANTA_PLAYER_SIZE
    loop .draw_enemy_ship

popa
JMP mega_loop
;reti

move_bullets: ; move in their direction
    ; pushad
    ; param bx has struct player
    ; param dx has bullet direction
    mov di, 0
    cmp di, [bx + Player.bullet_index] ; nothing in array
    JE .ret
    cmp si, [bx + Player.bullet_index] ; iterated over entire array
    JGE .ret
    
    cmp dx, 0
    JE .sub_
    add [bx + Player.bullet_xy + si], word WIDTH * BULLET_LENGTH* 2 ; check word bounds
    JMP .add_
    .sub_:
    sub [bx + Player.bullet_xy + si], word WIDTH * BULLET_LENGTH* 2 ; check word bounds
    .add_:
    JC .remove_from_array  ; either of add/sub ops is oob

    mov ax, word WIDTH * HEIGHT ; check vga bounds
    cmp ax, [bx + Player.bullet_xy + si]
    JNC .dont_remove_from_array 

    .remove_from_array:
    ; remove current si from array if it is OOB
    mov di, [bx + Player.bullet_index]
    mov di, [bx + Player.bullet_xy + di - 2]
    mov [bx + Player.bullet_xy +si], di
    sub word [bx + Player.bullet_index], 2
    ;

    .dont_remove_from_array:
    add word si, 2
    JMP move_bullets
    ;
    .ret:
    ret
;

draw_ship:
    ; pusha
    ; param bx stores structure
    ; param dx stores image
    ; param di makes color  == BG_COLOR if it is BG COLOR

    ; fill with BG color if not draw
    cmp byte [bx + Player.draw], 0
    JNE .draw
    mov word di, BG_COLOR

    .draw:
    mov cx, di
    xor di, di
    add di, [bx + Player.ship_x]
    mov ax, [bx + Player.ship_y]
    call draw_image
    ; add fire!!
    cmp byte [bx + Player.draw], 0
    JE .draw_ship_WO_fire

    add di, CUSTOM_IMAGE_SIZE/2 + WIDTH *CUSTOM_IMAGE_SIZE/2
    mov si, 0

    .redundant_bullet_check_loop: ; dont add bullet to array if already present
        cmp [bx + Player.bullet_xy + si], di
        JE .draw_ship_WO_fire
        add si, 2
        cmp si, [bx + Player.bullet_index]
        JLE .redundant_bullet_check_loop

    ; add fire at
    mov si, [bx + Player.bullet_index]
    add word [bx + Player.bullet_index], 2

    .draw_ship_WO_fire:
    mov word [bx + Player.bullet_xy + si], di
    ;pop di
    ret

draw_image:
    ; param di has x
    ; param ax has y
    ; param cx is BG color then dont draw
    ; param dx has image struc
    imul ax, WIDTH
    add di, ax
    push di
    ;

    push cx
    cmp cx, BG_COLOR
    mov cx, 400
    mov si, dx
    mov dx, 0
    JE .ret
    CLD
    .loop:
        pop ax
        push ax
;        CMP ax, BG_COLOR
;        JZ .dont_load
        lodsb ; load byte from [si] to al, inc si
;        .dont_load:

        cmp dx, CUSTOM_IMAGE_SIZE ; works for 20x20 images
        JL .same_row
        
        add di, WIDTH
        sub di, dx
        xor dx, dx
        
        .same_row:
        CLD
        inc dx
        cmp al, BG_COLOR
        JNE .stos
        mov al, [es:di]
        .stos:
        stosb
        loop .loop
    .ret:
    pop di
    pop di
    ret


; Draw bullets
draw_bullets:
    ; param bx contain player struc
    ; param ax contain color
    mov si, 0
    cmp si, [bx + Player.bullet_index]
    JZ .ret

    .loop:
        mov di, [bx + Player.bullet_xy + si]

        mov dx, BULLET_LENGTH
        .make_bullet:
            cmp di, 0
            JE .dont_make_bullet
            mov [es:di], byte al
            .dont_make_bullet:

            sub di, WIDTH

            dec dx
            cmp dx, 0
            JNZ .make_bullet

        add si, 2
        cmp si, [bx + Player.bullet_index]
        JL .loop

.ret:
    ret

fill_screen:
    ; xor di, di
    ; mov cx, WIDTH*HEIGHT
    ; mov al, BG_COLOR
    ; rep stosb
    ; mov si, stone_image
    ; ret
    
   ; draw_image:
    ; param di has x
    ; param ax has y
    ; param cx is BG color then dont draw
    ; param dx has image struc

    mov ax, 0
    .draw_stones_y:
        mov di, 0 ;CUSTOM_IMAGE_SIZE
        mov si, 0
        .draw_stones_x:
            mov dx, stone_image
            mov cx, 0xFFFF
            pusha
            call draw_image
            popa
            add di, CUSTOM_IMAGE_SIZE
            CMP di, WIDTH-CUSTOM_IMAGE_SIZE
            JLE .draw_stones_x
        add ax, CUSTOM_IMAGE_SIZE
        cmp ax, HEIGHT-CUSTOM_IMAGE_SIZE
        JLE .draw_stones_y

    ret


bullet_collison:
    ; si param stores, player struc of attacker
    ; bx param stores, player struc of victim
    ; returns di, 0 == no hit, 1 == hit
    pusha
    push bp

    ; check if no bullets
    mov bp, 0
    cmp bp, [si + Player.bullet_index]
    JNE .bullet_loop
    pop bp
    mov di, 0xFFFF
    popa
    ret ; no_collison

    .bullet_loop:
        mov ax, [si + Player.bullet_xy + bp] ;, WIDTH ; ax Y dx X
        mov cx, WIDTH
        div cx
        ;ax has y, dx has x

        mov cx, [bx + Player.ship_x]
        cmp dx, cx
        JL .try_next_bullet
        add cx, CUSTOM_IMAGE_SIZE

        cmp dx, cx
        JG .try_next_bullet

        mov cx, [bx + Player.ship_y]
        cmp ax, cx
        JL .try_next_bullet
        add cx, CUSTOM_IMAGE_SIZE

        cmp ax, cx
        JG .try_next_bullet

        pop bp
        mov di, BG_COLOR
        mov byte [bx + Player.draw], 0
        popa
        ret ; collison

    .try_next_bullet:
        add bp, 2
        cmp bp, [si + Player.bullet_index]
        JL .bullet_loop

        pop bp
        mov di, 0xFFFF
        popa
        ret ; no collison

; no code execution after this
; bss and data segments
exit:
player_ship_image: incbin "play_ship.bin" 
enemy_ship_image: incbin "enem_ship.bin" 
stone_image: incbin "stone2.bin" 

struc Player
    .ship_x: resw 1
    .ship_y: resw 1
    ; .fire_rate: resb 1
    .bullet_xy: times 100 resw 1
    .bullet_index: resw 1 ;resb wont work
    .draw: resb 1
    ; .ship_image: resb CUSTOM_IMAGE_SIZE*CUSTOM_IMAGE_SIZE + CUSTOM_IMAGE_SIZE
endstruc

;enemies: times 2 dw Player_size ; TODO make this dynamic
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

    enemies: times N_ENEMIES  dw 256
%assign sizeOfProgram $ - $$
%warning Size of the program: sizeOfProgram bytes

times 512*16 - ($-$$) db 0
