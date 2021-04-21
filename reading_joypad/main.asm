;
; I used this Website/Document as a reference to create "main.asm". 
;
; GB ASM Programming Tutorial: Hello World!
; https://eldred.fr/gb-asm-tutorial/hello-world.html
;
; The Cycle-Accurate Game Boy Docs (p25: 7. Joypad)
; https://github.com/AntonioND/giibiiadvance/blob/master/docs/TCAGBD.pdf
;

INCLUDE "hardware.inc"

JOYPAD_STATE    EQU _RAM

SECTION "Header", ROM0[$100]

EntryPoint:
	di
	jp Start

REPT $150 - $104
	db 0
ENDR

SECTION "Game code", ROM0

Start:
	; Turn off the LCD
.waitVBlank
	ld a, [rLY]
	cp 144 ; Check if the LCD is past VBlank
	jr c, .waitVBlank

	xor a ; ld a, 0 ; We only need to reset a value with bit 7 reset, but 0 does the job
	ld [rLCDC], a ; We will have to write to LCDC again later, so it's not a bother, really.

	ld hl, $9000
	ld de, FontTiles
	ld bc, FontTilesEnd - FontTiles

.copyFont
	ld a, [de] ; Grab 1 byte from the source
	ld [hli], a ; Place it at the destination, incrementing hl
	inc de ; Move to next byte
	dec bc ; Decrement count
	ld a, b ; Check if count is 0, since `dec bc` doesn't update flags
	or c
	jr nz, .copyFont
	ld hl, $9800 ; This will print the string at the top-left corner of the screen
	ld de, NoneStr

.copyString
	ld a, [de]
	ld [hli], a
	inc de
	and a ; Check if the byte we just copied is zero
	jr nz, .copyString ; Continue if it's not

	; Init display registers
	ld a, %11100100
	ld [rBGP], a

	xor a
	ld [rSCY], a
	ld [rSCX], a

	; Shut sound down
	ld [rNR52], a

	; Turn screen on, display background
	ld a, %10000001
	ld [rLCDC], a

.lockup
	; Reading Joypad
	ld a, P1F_4
	ld [rP1], a ; select P14
	ld a, [rP1]
	ldh a, [rP1] ; Wait a few cycles.
	cpl	; Complement A.
	and a, $0F ; Get only first 4 bits.
	swap a ; Swap it.
	ld b, a
	ld a, P1F_5
	ld [rP1], a ; Select P15.
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1] ; Wait a few MORE cycles.
	cpl
	and a, $0F
	or a, b ; Put A and B together.
	ld [JOYPAD_STATE], a ; Save joypad state.
	ld a, $30 ; Deselect P14 and P15.
	ld [rP1], a

	; Check JOYPAD_STATE
	ld a, [JOYPAD_STATE]
	and %00000001
	jr nz, .printRightStr

	ld a, [JOYPAD_STATE]
	and %00000010
	jr nz, .printLeftStr

	ld a, [JOYPAD_STATE]
	and %00000100
	jr nz, .printUpStr

	ld a, [JOYPAD_STATE]
	and %00001000
	jr nz, .printDownStr

	jr .printNoneStr

; printStr
.printRightStr
	ld hl, $9800
	ld de, RightStr
	jr .copyString2

.printLeftStr
	ld hl, $9800
	ld de, LeftStr
	jr .copyString2

.printUpStr
	ld hl, $9800
	ld de, UpStr
	jr .copyString2

.printDownStr
	ld hl, $9800
	ld de, DownStr
	jr .copyString2

.printNoneStr
	ld hl, $9800
	ld de, NoneStr
	jr .copyString2

.copyString2
	ld a, [de]
	ld [hli], a
	inc de
	and a
	jr nz, .copyString2

	jr .lockup

SECTION "Font", ROM0
	
FontTiles:
INCBIN "font.chr"
FontTilesEnd:

NoneStr:
	db "None ", 0
LeftStr:
	db "Left ", 0
RightStr:
	db "Right", 0
UpStr:
	db "Up   ", 0
DownStr:
	db "Down ", 0

