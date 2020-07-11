org 0x8000

; Global Initialisations
%define WIDTH 320
%define HEIGHT 200
%define CUSTOM_IMAGE_SIZE 20 ; 20x20 images only
%define BG_COLOR 0x00
%define BULLET_LENGTH 0x05
%define FRAME_DELAY 0xF240
%define N_ENEMIES 10
%define QUANTA_PLAYER_SIZE 0x100
%define KEYBOARD_IVT 0x0024
%define RTC_IVT 0x0070 ; 0x1c interrupt * 4


pusha

xor ax, ax
mov ds, ax
mov es, ax

mov dx, 0
mov bx, 0
.init_enemies:
    mov di, enemies
    add di, dx
    mov si, player
    mov cx, Player_size
    rep movsb
    mov si, enemies
    add si, dx
    add dx, QUANTA_PLAYER_SIZE
    inc bx
    cmp bx, N_ENEMIES
    JL .init_enemies

;
popa

; init 320x200 with 256 colors video mode
mov ah, 0x00
mov al, 0x13
int 0x10

xor ax, ax
mov ds, ax
mov es, ax
; keyboard isr
cli
xor ax, ax
mov word [KEYBOARD_IVT], keyboard_isr
mov word [KEYBOARD_IVT+2], ax
sti

;RTC isr
 cli
 xor ax, ax
;  mov dword [RTC_IVT], mega_loop
;mov word [RTC_IVT+2], ax
sti
;
;cli
;

xor ax, ax
mov ds, ax
mov es, ax
mov es, word [GRAPHIC_MEM_A]

; create level
mov ax, 0
call check_level_n_upgrade


; some_loop:
;  hlt
   ; JMP some_loop
; JMP $

mega_loop:
     pusha
xor ax, ax
mov ds, ax
mov es, ax
mov es, word [GRAPHIC_MEM_A]
     ; hlt
     ; call fill_screen
 ;JMP mega_loop


; delay
    MOV     CX,  0 ;0FH
    MOV     DX,  FRAME_DELAY 
    ; MOV     AH, 86H
    ; INT     15H
    ; mov cx, 0 ;2000;FRAME_DELAY
    ; mov dx, 0
    ;shr cx, 6
    ;shl dx, 10
    ; cx:dx == (2^4)*CX + DX == (2^10)*CX + (2*10)*DX  ~~ 2*CX ms
    mov ax, 0x8600
    int 0x15

    ; check ks
    call fill_screen
    mov ax, 0xFFFF
    call check_level_n_upgrade

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

    ; si param stores, player struc of attacker
    ; bx param stores, player struc of victim
    ; returns di, 0 == no hit, 1 == hit
    mov cx, N_ENEMIES
    mov bx, enemies
    .check_bullet_hit_on_enemy:
        mov si, player
        pusha
        call bullet_hit
        popa
        add bx, QUANTA_PLAYER_SIZE
        loop .check_bullet_hit_on_enemy
    ;
    ; mov cx, N_ENEMIES
    ; mov si, enemies
    ; .check_bullet_hit_on_player:
    ;     mov bx, player
    ;     pusha
    ;     call bullet_hit
    ;     popa
    ;     add si, QUANTA_PLAYER_SIZE
    ;     loop .check_bullet_hit_on_player

    mov di, 0xFFFF
    mov bx, player
    mov dx, [player_ship_image]
    mov di, 0xFFFF
    call draw_ship

    mov cx, N_ENEMIES
    mov bx, enemies
    .draw_enemy_ship:
        mov di, 0xFFFF
        mov dx, [enemy_ship_image]
        pusha
        call draw_ship
        popa
        add bx, QUANTA_PLAYER_SIZE
        loop .draw_enemy_ship
    popa
    ;sti
    ;iret
    ;call reked
    JMP mega_loop
    ;JMP exit

check_level_n_upgrade:
    ;param ax if 0 means dont test
    test ax, ax ; 
    JE .level1

    mov ax, 0
    mov bx, enemies
    mov cx, N_ENEMIES
    .check_all_enemy_dead:
        or ax, [bx + Player.draw]
        add bx, QUANTA_PLAYER_SIZE
        loop .check_all_enemy_dead
    test ax, ax
    JNE .ret

    
    inc byte [level] ; level up

    cmp byte [level], 2
    JE .level2
    cmp byte [level], 3
    JE .level3

    .level1:
    mov byte [level], 1

    mov byte [player + Player.fire_rate], 2
    mov byte [player + Player.bullet_index], 0
    mov byte [player + Player.move_speed], 1
    mov byte [player + Player.bullet_color], 0x03

    mov cx, N_ENEMIES
    mov bx, enemies
    .draw_enemy_ship1:
        mov byte [bx + Player.fire_rate], 2
        mov byte [bx + Player.bullet_index], 0
        mov byte [bx + Player.bullet_color], 0x02
        add bx, QUANTA_PLAYER_SIZE
        loop .draw_enemy_ship1

    
    ; load map
    LEA bx, [map0]
    mov [map], bx
    call draw_map

    ; load enemy ship
    LEA bx, [enemy_ship_image0]
    mov [enemy_ship_image], bx

    ; load player ship
    LEA bx, [player_ship_image0]
    mov [player_ship_image], bx

    JMP .ret


    .level2:
    mov byte [player + Player.fire_rate], 2
    mov byte [player + Player.bullet_index], 0
    mov byte [player + Player.move_speed], 2
    mov byte [player + Player.bullet_color], 0x03

mov cx, N_ENEMIES
    mov bx, enemies
    .draw_enemy_ship2:
        mov byte [bx + Player.fire_rate], 5
        mov byte [bx + Player.bullet_index], 0
        mov byte [bx + Player.bullet_color], 0x04
        add bx, QUANTA_PLAYER_SIZE
        loop .draw_enemy_ship2

    LEA bx, [map1]
    mov [map], bx
    call draw_map

    LEA bx, [enemy_ship_image1]
    mov [enemy_ship_image], bx

    LEA bx, [player_ship_image1]
    mov [player_ship_image], bx

    JMP .ret

    .level3:
    mov byte [player + Player.fire_rate], 2
    mov byte [player + Player.bullet_index], 0
    mov byte [player + Player.move_speed], 3

    mov cx, N_ENEMIES
    mov bx, enemies
    .draw_enemy_ship3:
        mov byte [bx + Player.fire_rate], 7
        mov byte [bx + Player.bullet_index], 0
        mov byte [bx + Player.bullet_color], 0x04
        add bx, QUANTA_PLAYER_SIZE
        loop .draw_enemy_ship3

    LEA bx, [map2]
    mov [map], bx
    call draw_map

    LEA bx, [enemy_ship_image2]
    mov [enemy_ship_image], bx

    LEA bx, [player_ship_image2]
    mov [player_ship_image], bx
    mov byte [level], 0
    JMP .ret


.ret:
    ret
; FUNCTIONS
keyboard_isr:
    pusha

    in al, 0x60
    test al, 0x80
    JNE .ret
    test al, al
    JE .ret

    xor cx, cx
    mov cl, [player + Player.move_speed]

    cmp al, 0x13 ; stop moving
    JZ .reset
    cmp al, 0x21 ; stop moving
    JZ .pause
    cmp al, 0x11 ; stop moving
    JZ .move_up
    cmp al, 0x1E ; stop moving
    JZ .move_left
    cmp al, 0x1F ; stop moving
    JZ .move_down
    cmp al, 0x20 ; stop moving
    JZ .move_right
    JMP .ret
    .reset:
        JMP 0x8000 ; call kernel again
        JMP .ret
    .pause:
        hlt
        JMP .ret
    .move_down:
        cmp word [player+Player.ship_y], HEIGHT - CUSTOM_IMAGE_SIZE
        JE .ret
        inc word [player+Player.ship_y]
        loop .move_down
        JMP .ret
    .move_left:
        cmp word [player+Player.ship_x], 0
        JE .ret
        dec word [player+Player.ship_x]
        loop .move_left
        JMP .ret
    .move_up:
        cmp word [player+Player.ship_y], 0
        JE .ret
        dec word [player+Player.ship_y]
        loop .move_up
        JMP .ret
    .move_right:
        cmp word [player+Player.ship_x], WIDTH - CUSTOM_IMAGE_SIZE
        JE .ret
        inc word [player+Player.ship_x]
        loop .move_right
        JMP .ret

    .ret:
    mov al, 0x20
    out 0x20, al

    popa
    iret

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
    add [bx + Player.bullet_xy + si], word WIDTH * BULLET_LENGTH*2 ; check word bounds
    JMP .add_
    .sub_:
    sub [bx + Player.bullet_xy + si], word WIDTH * BULLET_LENGTH *2 ; check word bounds
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
    
    mov ax, [bx + Player.fire_rate]
    cmp word [bx + Player.bullet_index], ax ;[bx + Player.fire_rate]
    JGE .draw_ship_WO_fire

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
            mov al, [bx + Player.bullet_color]
            mov [es:di], al
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
    xor di, di
    mov cx, WIDTH*HEIGHT
    mov al, 20 ;0x01 ;BG_COLOR
    rep stosb
    mov si, stone_image
    JMP .ret
    
   ; draw_image:
    ; param di has x
    ; param ax has y
    ; param cx is BG color then dont draw
    ; param dx has image struc

    mov ax, 0
    .draw_stones_y:
        mov di, 0 ;CUSTOM_IMAGE_SIZE
        ;mov si, 0
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

    .ret:
;    sti
    ret


bullet_hit:
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
    ret ; no_hit

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
        ret ; hit

    .try_next_bullet:
        add bp, 2
        cmp bp, [si + Player.bullet_index]
        JL .bullet_loop

        pop bp
        mov di, 0xFFFF
        popa
        ret ; no hit

draw_map:
    push bp
    ; find player
    mov si, [map] ; will store player location in map
    mov cx, WIDTH * HEIGHT / 64
    .find_player_loop:
        lodsb 
        cmp al, 'P'
        JE .break_player_loop
        loop .find_player_loop
    .break_player_loop:
    ; need to make player as center of the frame
    ; screen mid = HEIGHT/2 * WIDTH + WIDTH/2 = (HEIGHT + 1) * WIDTH/2 this should be equal to bx, making offset as A - B this is the starting point for map.
;    inc si
;    inc si
    sub si, ((HEIGHT/8)+1) * (WIDTH/8) / 2
    
    mov dx, 0 ; x counter
    mov bx, 0 ; y counter
    mov di, 0 ; enemy ship counter
    mov si, [map]

    mov cx, WIDTH*HEIGHT / 64 ; map size 
    .loop:
        cmp dx, WIDTH/8 ; + 1
        JNE .continue
        mov dx, 0
        inc bx
        .continue:
        lodsb
        shl bx, 3
        shl dx, 3
        cmp al, 'E'
        JNE .check_player

        ; dec si
        ; mov byte [si], ' '
        ; inc si
        mov [di + enemies + Player.ship_x], dx
        mov [di + enemies + Player.ship_y], bx
        mov byte [di + enemies + Player.draw], 1
        add di, QUANTA_PLAYER_SIZE
        inc bp

        .check_player:
        cmp al, 'P'
        JNE .loop_
        mov [player + Player.ship_x], dx
        mov [player + Player.ship_y], bx
        mov byte [player + Player.draw], 1

        .loop_:
        shr bx, 3
        shr dx, 3
        inc dx
        loop .loop
        
    .ret:
    pop bp
    ret

reked:
;cli
    mov ah, 0
    mov al, 0x03
    int 0x10
    mov word bp, rekd_msg

    mov bx, 0x0004
    mov cx, rekd_msg_len

    mov dh, 10
    mov dl, 10


    xor ax, ax
    mov es, ax
    ;push cs
    ;pop es
    mov ah, 0x13
    mov al, 1

    int 10h
    ;JMP exit
    ret


; no code execution after this
; bss and data segments
exit:
GRAPHIC_MEM_A dw 0xA000 ; wont work as macro

bins:

level: db 1

player_ship_image: dw 0
player_ship_image0: incbin "play_ship.bin" 
player_ship_image1: incbin "play_ship.bin" 
player_ship_image2: incbin "play_ship.bin" 

enemy_ship_image: dw 0
enemy_ship_image0: incbin "enem_ship.bin" 
enemy_ship_image1: incbin "enem_ship1.bin" 
enemy_ship_image2: incbin "enem_ship2.bin" 

stone_image: incbin "stone3.bin" 

map: dw 0
map0: incbin "map.bin"
map1: incbin "map1.bin"
map2: incbin "map2.bin"


struc Player
    .move_speed: resb 1
    .bullet_color: resb 1
    .ship_x: resw 1
    .ship_y: resw 1
    .fire_rate: resw 1
    .bullet_xy: times 100 resw 1
    .bullet_index: resw 1 ;resb wont work
    .draw: resb 1
    ; .ship_image: resb CUSTOM_IMAGE_SIZE*CUSTOM_IMAGE_SIZE + CUSTOM_IMAGE_SIZE
endstruc

player:
istruc Player
    at Player.move_speed, db 2
    at Player.bullet_color, db 0
    at Player.ship_x, dw WIDTH/2 - CUSTOM_IMAGE_SIZE/2
    at Player.ship_y, dw ( HEIGHT/2 - CUSTOM_IMAGE_SIZE/2 )
    at Player.fire_rate, dw 30
    at Player.bullet_xy, times 100 dw 0
    at Player.bullet_index, dw 0  ; b wont work
    at Player.draw, db 0
    ; at Player.ship_image, incbin "enemy_ship.bin"
iend

enemies: times N_ENEMIES  dw 256

rekd_msg: db "1234 1234"
rekd_msg_len equ $-rekd_msg

times 512*20 - ($-$$) db 0
