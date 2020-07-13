
; FUNCTIONS
check_level_n_upgrade:
    ;param ax if == 0 means reset levels to level 1
    test ax, ax ; 
    JE .level1

    ; check if all the enemies are dead, if yes level up
    mov ax, 0
    mov bx, enemies
    mov cx, N_ENEMIES
    .check_all_enemy_dead:
        or ax, [bx + Player.draw]
        add bx, QUANTA_PLAYER_SIZE
        loop .check_all_enemy_dead
    test ax, ax
    JE .not_end
    ret

    .not_end:
    inc byte [level] ; level up

    cmp byte [level], 1
    JE .level1
    cmp byte [level], 2
    JE .level2
    cmp byte [level], 3
    JE .level3

    ; if level 3 is cleared, you won the game
    mov word bp, won_game
    mov cx, won_game_len
    call write_string
    
    JMP exit
    ;
    
    ; init each levels elements, and ship attributes
    .level1:
    mov byte [level], 1

    mov byte [player + Player.fire_rate], 2
    mov byte [player + Player.bullet_index], 0
    mov byte [player + Player.move_speed], 1
    mov byte [player + Player.bullet_color], 0x03

    ; get level background
    LEA ax, [stone_image0]
    mov [stone_image], ax

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

    ret


    .level2:
    mov byte [player + Player.fire_rate], 2
    mov byte [player + Player.bullet_index], 0
    mov byte [player + Player.move_speed], 2
    mov byte [player + Player.bullet_color], 0x03

    ; get level background
    LEA ax, [stone_image1]
    mov [stone_image], ax

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

    ; get level background
    LEA ax, [stone_image1]
    mov [stone_image], ax

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
    JMP .ret


.ret:

    ; show level up msg
    mov word bp, lvlup_msg
    mov cx, lvlup_msg_len
    cli
    call write_string

    MOV     CX,  20 ;0FH
    MOV     DX,  FRAME_DELAY 
    mov ax, 0x8600
    int 0x15
    sti

ret

; handle keystrokes
keyboard_isr:
    pusha

    in al, 0x60
    test al, 0x80
    JNE .ret
    test al, al
    JE .ret

    xor cx, cx
    mov cl, [player + Player.move_speed]

    cmp al, 0x13 ; 'r'
    JZ .reset
    ; cmp al, 0x21 ; 'f'
    ; JZ .pause
    cmp al, 0x11 ; 'w'
    JZ .move_up
    cmp al, 0x1E ; 'a'
    JZ .move_left
    cmp al, 0x1F ; 's'
    JZ .move_down
    cmp al, 0x20 ; 'd'
    JZ .move_right
    JMP .ret
    .reset:
        ; dont reset if player ship is alive
        mov bl, [player + Player.draw]
        test bl, bl
        JNZ .ret

        mov ax, 0
        call check_level_n_upgrade
        mov al, 0x20
        out 0x20, al

        popa
        JMP forever_loop
    ; .pause:
    ;     hlt
    mov word bp, lvlup_msg
    mov cx, lvlup_msg_len
    call write_string
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

; move bullets in their direction
move_bullets:
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
    JC .remove_from_array  ; either of add/sub ops is out of bounds

    mov ax, word WIDTH * HEIGHT ; check resolution bounds
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

    ; dont draw ship if ship is dead
    cmp byte [bx + Player.draw], 0
    JNE .draw
    ret

    .draw:
    mov cx, di
    xor di, di
    add di, [bx + Player.ship_x]
    mov ax, [bx + Player.ship_y]
    call draw_image

    ; add bullet!!
    cmp byte [bx + Player.draw], 0
    JE .draw_ship_WO_fire
   
    ; bullets in the airspace should be less that fire rate 
    mov ax, [bx + Player.fire_rate]
    cmp word [bx + Player.bullet_index], ax
    JGE .draw_ship_WO_fire

    add di, CUSTOM_IMAGE_SIZE/2 + WIDTH *CUSTOM_IMAGE_SIZE/2
    mov si, 0

    .redundant_bullet_check_loop: 
        ; dont add bullet to array if already present
        cmp [bx + Player.bullet_xy + si], di
        JE .draw_ship_WO_fire
        add si, 2
        cmp si, [bx + Player.bullet_index]
        JLE .redundant_bullet_check_loop

    ; store bullet loc and increase index
    mov si, [bx + Player.bullet_index]
    add word [bx + Player.bullet_index], 2

    .draw_ship_WO_fire:
    mov word [bx + Player.bullet_xy + si], di
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
    CLD;

    ; copy the pixel from image to it's place on the screen
    .loop:
        pop ax
        push ax
        lodsb ; load byte from [si] to al, inc si

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
    sti
    ret


; Draw bullets
draw_bullets:
    ; param bx contain player struc
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
    ; uncomment to use a fixed color as BG
    ; xor di, di
    ; mov cx, WIDTH*HEIGHT
    ; mov al, 20 ;0x01 ;BG_COLOR
    ; rep stosb
    ; mov si, stone_image
    ; JMP .ret
    
   ; draw_image:
    ; param di has x
    ; param ax has y
    ; param cx is BG color then dont draw
    ; param dx has image struc

    mov ax, 0
    .draw_stones_y:
        mov di, 0 ;CUSTOM_IMAGE_SIZE
        .draw_stones_x:
            mov dx, [stone_image]
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
    ret


bullet_hit:
    ; checks if a bullet is hit
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

    ; find x and y coord of each bullet and find overlap with victim
    ; by checking each boundry of the ship
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
        ; bx ship is dead
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
    ; read map structure and place ship location accordingly
    ; reads map.bin, which is a 8 times scaled down version of the actual VGA pixel space

    push bp
    ; to make player as center of the frame (unused code)
    ; find player
    ; mov si, [map] ; will store player location in map
    ; mov cx, WIDTH * HEIGHT / 64
    ; .find_player_loop:
    ;     lodsb 
    ;     cmp al, 'P'
    ;     JE .break_player_loop
    ;     loop .find_player_loop
    ; .break_player_loop:
    ; sub si, ((HEIGHT/8)+1) * (WIDTH/8) / 2
    
    mov dx, 0 ; x counter
    mov bx, 0 ; y counter
    mov di, 0 ; enemy ship counter
    mov si, [map]

    mov cx, WIDTH*HEIGHT / 64 ; scaled map size 
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
        
        ; place enemy ship
        mov [di + enemies + Player.ship_x], dx
        mov [di + enemies + Player.ship_y], bx
        mov byte [di + enemies + Player.draw], 1
        add di, QUANTA_PLAYER_SIZE
        inc bp

        .check_player:
        cmp al, 'P'
        JNE .loop_
        ; place player ship
        mov [player + Player.ship_x], dx
        mov [player + Player.ship_y], bx
        mov byte [player + Player.draw], 1

        .loop_:
        ; revert to scaled map pixel space
        shr bx, 3
        shr dx, 3
        inc dx
        loop .loop
        
    .ret:
    pop bp
    ret

write_string:
    ; param bp, msg
    ; param cx, len
    pusha

    push cx
    xor di, di
    mov cx, WIDTH*HEIGHT
    mov al, 0 ;0x01 ;BG_COLOR
    rep stosb
    pop cx

    mov bx, 0x0004
    mov dx, 40 ; text width
    sub dx, cx
    shr dx, 1
    mov dh, 25/2 ; text height

    push es
    ; hide cursor
    xor ax, ax
    mov es, ax
    mov ah, 0x13
    mov al, 1

    int 10h
    pop es ; restore es to graphic memory

    popa
    ret
