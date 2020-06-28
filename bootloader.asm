org 0x7C00
bits 16
; reset system
mov al, 0x00
int 0x13

; read certain length of code from 0x8000 into RAM
; each sector is of 512B sector 0 is boot loader at 0x7C00, sector 1 is the rest of the 512B and usable space starts at 0x8000ie sector 2
mov cl, 0x02 ; each sec
mov ch, 0x00 ; cylinder number (first cylinder)
;mov dl, xxx ; drive number is auto filled upon reset in dl
mov dh, 0x00 ; head number (first head)
mov al, 0x01 ; n of sectors to read
mov ah, 0x02 ; read disk sectors into memory. 
mov bx, 0x8000; address of the available user space

int 0x13

jmp 0x8000
; fill up the entire 512B and put last bytes as magic number
times 510 - ($-$$) db 0
db 0x55 ; magic byte 1
db 0xAA ; magic byte 2

