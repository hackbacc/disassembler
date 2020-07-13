org 0x8000  ; address from where kernel space starts

; Global Initialisations
%define WIDTH 320
%define HEIGHT 200
%define CUSTOM_IMAGE_SIZE 20 ; 20x20 images only
%define BG_COLOR 0x00
%define BULLET_LENGTH 0x05
%define FRAME_DELAY 0xF240
%define N_ENEMIES 30 ; max allowed number of enemies
%define QUANTA_PLAYER_SIZE 0x100 ;  should be a multiple of 16, cannot have arbitary structure size where we can iterate
%define KEYBOARD_IVT 0x0024 ; location of the default keyboard handler ISR 
%define RTC_IVT 0x0070 ; location of system timer ISR, (not used)

pusha

xor ax, ax
mov ds, ax
mov es, ax

; initialise all the ships
mov dx, 0
mov bx, 0
.init_enemies:
    ; makes multiple copies of Player structure
    mov di, enemies
    add di, dx
    mov si, player
    mov cx, Player_size
    rep movsb  ; copies player structure to enemy
    mov si, enemies
    add si, dx
    add dx, QUANTA_PLAYER_SIZE ; 
    inc bx
    cmp bx, N_ENEMIES
    JL .init_enemies
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
; replace default ISR
mov word [KEYBOARD_IVT], keyboard_isr
mov word [KEYBOARD_IVT+2], ax
sti

;RTC isr (not used)
;  cli
;  xor ax, ax
; mov dword [RTC_IVT], forever_loop
; mov word [RTC_IVT+2], ax
; sti

xor ax, ax
mov ds, ax
mov es, ax
mov es, word [GRAPHIC_MEM_A] ; all the values written starting from this address will represent a pixel on the screen

; create level and spawn objects
mov ax, 0
call check_level_n_upgrade

; show startup msg
mov word bp, begin_msg
mov cx, begin_msg_len
call write_string
MOV     CX,  20
MOV     DX,  FRAME_DELAY 
mov ax, 0x8600
int 0x15

; code to use timer ISR (not used)
; some_loop:
;  hlt
   ; JMP some_loop
; JMP $

; forever loop
forever_loop:
     pusha

    ; delay
    MOV     CX,  0 ;0FH
    MOV     DX,  FRAME_DELAY 
    mov ax, 0x8600
    int 0x15

    ; Fill background with corresponding images.
    call fill_screen
    mov ax, 0xFFFF

    ; check if level up or game over.
    call check_level_n_upgrade

    ; move each enemy's bullets down in each frame refesh
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

    ; move player's bullets up in each frame
    mov si, 0
    mov bx, player
    mov dx, 0
    call move_bullets

    ; draw bullets for player
    mov al, 0x03
    mov bx, player
    call draw_bullets

    ; draw bullets for enemies
    xor cx, N_ENEMIES
    mov bx, enemies
    .draw_enemy_bullets:
        mov al, 0x02
        pusha
        call draw_bullets
        popa
        add bx, QUANTA_PLAYER_SIZE
        loop .draw_enemy_bullets

    ; check if the bullet of player hits enemy
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

    ; check if bullet of enemy hits player
    mov cx, N_ENEMIES
    mov si, enemies
    .check_bullet_hit_on_player:
        mov bx, player
        pusha
        call bullet_hit
        popa
        add si, QUANTA_PLAYER_SIZE
        loop .check_bullet_hit_on_player
    ;
    
    ; draw player ship
    mov di, 0xFFFF
    mov bx, player
    mov dx, [player_ship_image]
    mov di, 0xFFFF
    call draw_ship

    ; draw enemy ships
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

    ; if player ship is alive ok
    cmp byte [player + Player.draw], 0
    JNE forever_loop

    ; else you got rekd
    mov word bp, rekd_msg
    mov cx, rekd_msg_len
    call write_string

    ; press r to reset game
    .some:
        JMP .some

; end of forever loop

%include "functions.asm"
; no code execution after this
; bss and data segments

exit:
begin_msg: db "YOU READY?!"
begin_msg_len equ $-begin_msg

rekd_msg: db "YOU GOT REKD"
rekd_msg_len equ $-rekd_msg

won_game: db "YOU DID THE IMPOSSIBLE! YOU WON!!!"
won_game_len equ $-won_game

lvlup_msg: db "LEVEL UP!"
lvlup_msg_len equ $-lvlup_msg

GRAPHIC_MEM_A dw 0xA000 ; wont work as macro

bins:

level: db 1

player_ship_image: dw 0
player_ship_image0: incbin "bins/play_ship.bin" 
player_ship_image1: incbin "bins/play_ship.bin" 
player_ship_image2: incbin "bins/play_ship.bin" 

enemy_ship_image: dw 0
enemy_ship_image0: incbin "bins/enem_ship.bin" 
enemy_ship_image1: incbin "bins/enem_ship1.bin" 
enemy_ship_image2: incbin "bins/enem_ship2.bin" 

stone_image: dw 0
stone_image0: incbin "bins/stone4.bin" 
stone_image1: incbin "bins/stone3.bin" 

map: dw 0
map0: incbin "bins/map.bin"
map1: incbin "bins/map1.bin"
map2: incbin "bins/map2.bin"


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

times 512*16 - ($-$$) db 0
