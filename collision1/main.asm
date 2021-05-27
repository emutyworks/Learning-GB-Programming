;
; I used this Website/Document as a reference to create "main.asm".
;
; GB ASM Programming Tutorial: Hello World!
; https://eldred.fr/gb-asm-tutorial/hello-world.html
;
; The Cycle-Accurate Game Boy Docs (p25: 7. Joypad)
; https://github.com/AntonioND/giibiiadvance/blob/master/docs/TCAGBD.pdf
;
; Pan Docs: Memory Map
; https://gbdev.io/pandocs/Memory_Map.html
;
; OAM DMA tutorial
; https://gbdev.gg8.se/wiki/articles/OAM_DMA_tutorial
;

INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]

EntryPoint:
	di
	jp Start

REPT $150 - $104
	db 0
ENDR

SECTION "Initialize", ROM0

Start:
	; move DMA subroutine to HRAM
	call CopyDMARoutine

	; Turn screen off
	call WaitVBlank
	ld a, %00000000 ; LCDCF_OFF
	ld [rLCDC], a

	; Set Tiles data
	ld hl, _VRAM8000
	ld de, Tiles
	ld bc, TilesEnd - Tiles
	call CopyTiles

	; Set BG tile map
	ld hl, _SCRN0
	ld de, BgTileMap
	ld bc, BgTileMapEnd - BgTileMap
	call CopyTiles

	; Init display registers
	ld a, %11100100
	ld [rBGP], a ; BG Palette
	ld [rOBP0], a ; Object Palette 0
	ld [rOBP1], a ; Object Palette 1

	ld a, 0
	ld [rSCY], a ; Scroll Y
	ld [rSCX], a ; Scroll X

	; Shut sound down
	ld [rNR52], a

	; Turn screen on, display background
	ld a, %10010011 ; LCDCF_ON,LCDCF_BG8000,LCDCF_OBJON,LCDCF_BGON
	ld [rLCDC], a

	; Initialize wShadowOAM
	ld hl, wShadowOAM
	ld bc, 4*40

.iniwShadowOAM
	ld a, $00
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, .iniwShadowOAM

	; Initialize Joypad State
	ld a, %00000000
	ld [JOYPAD_STATE], a
	ld a, 7+8*2
	ld [JOYPAD_YPOS], a
	ld a, 7+8*2
	ld [JOYPAD_XPOS], a

	; Set OAM
	ld hl, wShadowOAM
	ld a, [JOYPAD_YPOS]
	ld [hli], a ; Y:16 Displayed in the upper left corner
	ld a, [JOYPAD_XPOS]
	ld [hli], a ; X:8 Displayed in the upper left corner
	ld a, 6 ; Tile Index
	ld [PLAYER_INDEX], a
	ld [hli], a
	ld a, %01000000 ; Attributes/Flags
	ld [PLAYER_ATTRI], a
	ld [hli], a

	jp MainLoop

SECTION "Main", ROM0

MainLoop:
	; Reading Joypad
	ld a, P1F_4
	ld [rP1], a ; select P14
	ld a, [rP1]
	ldh a, [rP1] ; Wait a few cycles.
	cpl	; Complement A.
	and a, %00001111 ; Get only first 4 bits.
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
	and a, %00001111
	or a, b ; Put A and B together.
	ld [JOYPAD_STATE], a ; Save joypad state.
	ld a, %11000000 ; Deselect P14 and P15.
	ld [rP1], a

	jp CheckJoypad

SECTION "Collision routine", ROM0

CheckJoypad:
	ld a, [JOYPAD_STATE]
	and %00000001
	jp nz, .incX

	ld a, [JOYPAD_STATE]
	and %00000010
	jp nz, .decX

	ld a, [JOYPAD_STATE]
	and %00001000
	jp nz, .incY

	ld a, [JOYPAD_STATE]
	and %00000100
	jp nz, .decY

	jp .setOAM

.incX
	ld a, [JOYPAD_XPOS]
	inc a
	ld d, a
	ld [NEW_JOYPAD_X], a
	ld a, [JOYPAD_YPOS]
	ld e, a
	ld [NEW_JOYPAD_Y], a

	ld a, 7
	ld [PLAYER_INDEX], a
	ld a, %00000000
	ld [PLAYER_ATTRI], a

	jp .collisionX

.decX
	ld a, [JOYPAD_XPOS]
	dec a
	ld [NEW_JOYPAD_X], a
	sub a, 7
	ld d, a
	ld a, [JOYPAD_YPOS]
	ld e, a
	ld [NEW_JOYPAD_Y], a

	ld a, 7
	ld [PLAYER_INDEX], a
	ld a, %00100000 ; X flip
	ld [PLAYER_ATTRI], a

	jp .collisionX

.incY
	ld a, [JOYPAD_XPOS]
	ld d, a
	ld [NEW_JOYPAD_X], a
	ld a, [JOYPAD_YPOS]
	inc a
	ld e, a
	ld [NEW_JOYPAD_Y], a

	ld a, 6
	ld [PLAYER_INDEX], a
	ld a, %01000000 ; Y flip
	ld [PLAYER_ATTRI], a

	jp .collisionY

.decY
	ld a, [JOYPAD_XPOS]
	ld d, a
	ld [NEW_JOYPAD_X], a
	ld a, [JOYPAD_YPOS]
	dec a
	ld [NEW_JOYPAD_Y], a
	sub a, 7
	ld e, a

	ld a, 6
	ld [PLAYER_INDEX], a
	ld a, %00000000
	ld [PLAYER_ATTRI], a

	jp .collisionY

.collisionX
	; check map1
	call .calcMap
	ld a, [hl] ; 8
	ld [DEBUG_TILE], a ; debug
	and a
	jp nz, .setOAM

	; check map2
	ld a, [JOYPAD_YPOS]
	and a, 7
	cp a, 7
	jp z, .setJoypad

	ld a, e
	sub a, 8
	ld e, a
	call .calcMap
	ld a, [hl] ; 8
	ld [DEBUG_TILE2], a ; debug
	and a
	jp nz, .setOAM

	jp .setJoypad 

.collisionY
	; check map1
	call .calcMap
	ld a, [hl] ; 8
	ld [DEBUG_TILE], a ; debug
	and a
	jp nz, .setOAM

	; check map2
	ld a, [JOYPAD_XPOS]
	and a, 7
	cp a, 7
	jp z, .setJoypad

	ld a, d
	sub a, 8
	ld d, a
	call .calcMap
	ld a, [hl] ; 8
	ld [DEBUG_TILE2], a ; debug
	and a
	jp nz, .setOAM

	jp .setJoypad 

.setJoypad
	ld a, [NEW_JOYPAD_Y]
	ld [JOYPAD_YPOS], a
	ld a, [NEW_JOYPAD_X]
	ld [JOYPAD_XPOS], a

.setOAM
	ld hl, wShadowOAM
	ld a, [JOYPAD_YPOS]
	add a, 9 ; 8 ; JOYPAD_YPOS+9
	ld [hli], a
	ld a, [JOYPAD_XPOS]
	inc a ; 4 ; JOYPAD_XPOS+1
	ld [hli], a
	ld a, [PLAYER_INDEX]
	ld [hli], a
	ld a, [PLAYER_ATTRI]
	ld [hli], a

	call WaitVBlank

	; call the DMA subroutine we copied to HRAM
	; which then copies the bytes to the OAM and sprites begin to draw
	ld  a, HIGH(wShadowOAM)
	call hOAMDMA

	jp MainLoop

.calcMap
	; X Map
	ld a, d
	and a, %11111000
	rra
	rra
	rra
	ld c, a ; copy
	ld [DEBUG_MAP_X], a

	; Y Map
	ld a, e
	and a, %11111000
	rra
	rra
	ld [DEBUG_MAP_Y], a
	ld b, a ; 4
	and a, %11110000
	swap a
	or a, %10011000
	ld h, a
	ld [DEBUG_MAP_Y_HIGH], a ; 16
	ld a, b
	swap a
	and a, %11110000
	add a, c ; a + map x
	ld l, a
	ld [DEBUG_MAP_Y_LOW], a
	ret

SECTION "Wait VBlank routine", ROM0

WaitVBlank:
	ld a, [rLY]
	cp 144 ; Check if the LCD is past VBlank
	jr c, WaitVBlank
	ret

SECTION "Copy Tiles routine", ROM0

CopyTiles:
	ld a, [de] ; Grab 1 byte from the source
	ld [hli], a ; Place it at the destination, incrementing hl
	inc de ; Move to next byte
	dec bc ; Decrement count
	ld a, b ; Check if count is 0, since `dec bc` doesn't update flags
	or c
	jr nz, CopyTiles
	ret

SECTION "OAM DMA routine", ROM0

CopyDMARoutine:
	ld  hl, DMARoutine
	ld  b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
	ld  c, LOW(hOAMDMA) ; Low byte of the destination address
.copy
	ld  a, [hli]
	ldh [c], a
	inc c
	dec b
	jr  nz, .copy
	ret

DMARoutine:
	ldh [rDMA], a
	
	ld  a, 40
.wait
	dec a
	jr  nz, .wait
	ret
DMARoutineEnd:

SECTION "Tiles", ROM0
	
Tiles:
	INCBIN "tiles.bin"
TilesEnd:

SECTION "Map", ROM0

BgTileMap:
	INCBIN "map.bin"
BgTileMapEnd:

SECTION "STATE", WRAM0[_RAM]

JOYPAD_STATE:
	ds 1
JOYPAD_YPOS:
	ds 1
JOYPAD_XPOS:
	ds 1
NEW_JOYPAD_Y:
	ds 1
NEW_JOYPAD_X:
	ds 1
PLAYER_INDEX: ; Tile Index
	ds 1
PLAYER_ATTRI: ; Attributes/Flags
	ds 1

DEBUG_MAP_Y:
	ds 1
DEBUG_MAP_X:
	ds 1
DEBUG_MAP_Y_HIGH:
	ds 1
DEBUG_MAP_Y_LOW:
	ds 1
DEBUG_TILE:
	ds 1
DEBUG_TILE2:
	ds 1

SECTION "Shadow OAM", WRAM0[_RAM+$100]

wShadowOAM:
	ds 4*40 ; This is the buffer we'll write sprite data to

SECTION "OAM DMA", HRAM

hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to