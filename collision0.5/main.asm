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

	call WaitVBlank

	; Turn screen off
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
	ld a, $00
	ld [JOYPAD_STATE], a
	ld a, 16+8
	ld [JOYPAD_YPOS], a
	ld a, 8*3
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
	jp nz, IncXPos

	ld a, [JOYPAD_STATE]
	and %00000010
	jp nz, DecXPos

	ld a, [JOYPAD_STATE]
	and %00000100
	jp nz, DecYPos

	ld a, [JOYPAD_STATE]
	and %00001000
	jp nz, IncYPos

SetOAM:
	ld hl, wShadowOAM
	ld a, [JOYPAD_YPOS]
	ld [hli], a
	ld a, [JOYPAD_XPOS]
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

IncXPos:
	call CollisionIncX
	and a
	jp nz, SetOAM

	ld hl, JOYPAD_XPOS ; 12
	inc [hl] ; 12

	ld a, 7
	ld [PLAYER_INDEX], a
	ld a, %00000000
	ld [PLAYER_ATTRI], a

	jp SetOAM

DecXPos:
	call CollisionDecX
	and a
	jp nz, SetOAM

	ld hl, JOYPAD_XPOS
	dec [hl]

	ld a, 7
	ld [PLAYER_INDEX], a
	ld a, %00100000 ; X flip
	ld [PLAYER_ATTRI], a

	jp SetOAM

IncYPos:
	call CollisionIncY
	and a
	jp nz, SetOAM

	ld hl, JOYPAD_YPOS
	inc [hl]

	ld a, 6
	ld [PLAYER_INDEX], a
	ld a, %01000000 ; Y flip
	ld [PLAYER_ATTRI], a

	jp SetOAM

DecYPos:
	call CollisionDecY
	and a
	jp nz, SetOAM

	ld hl, JOYPAD_YPOS
	dec [hl]

	ld a, 6
	ld [PLAYER_INDEX], a
	ld a, %00000000
	ld [PLAYER_ATTRI], a

	jp SetOAM

SECTION "Collision routine", ROM0
CollisionIncY:
	ld a, [JOYPAD_YPOS]
	and a, %11111000
	rra
	rra
	rra
	dec a
	or a, %01000000
	ld [MAP_Y_POS], a

	ld a, [JOYPAD_XPOS]
	and a, %11111000
	rra
	rra
	rra
	dec a
	ld [MAP_X_POS], a
	
	jp Collision

CollisionDecY:
	ld a, [JOYPAD_YPOS]
	and a, %11111000
	rra
	rra
	rra
	dec a
	dec a
	or a, %01000000
	ld [MAP_Y_POS], a

	ld a, [JOYPAD_XPOS]
	and a, %11111000
	rra
	rra
	rra
	dec a
	ld [MAP_X_POS], a
	
	jp Collision

CollisionIncX:
	ld a, [JOYPAD_YPOS]
	and a, %11111000
	rra
	rra
	rra
	dec a
	or a, %01000000
	ld [MAP_Y_POS], a

	ld a, [JOYPAD_XPOS]
	and a, %11111000
	rra
	rra
	rra
	ld [MAP_X_POS], a
	
	jp Collision

CollisionDecX:
	ld a, [JOYPAD_YPOS]
	and a, %11111000
	rra
	rra
	rra
	dec a
	or a, %01000000
	ld [MAP_Y_POS], a

	ld a, [JOYPAD_XPOS]
	dec a
	and a, %11111000
	rra
	rra
	rra
	dec a
	ld [MAP_X_POS], a

	jp Collision

Collision:
	ld a, [MAP_Y_POS]
	rla
	swap a
	and a, %00001111
	or a, %10011000
	ld [MAP_HIGH], a

	ld a, [MAP_Y_POS]
	and a, %00000111
	rla
	swap a
	ld hl, MAP_X_POS
	or a, [hl]
	ld [MAP_LOW], a

	ld a, [MAP_HIGH]
	ld h, a
	ld a, [MAP_LOW]
	ld l, a
	ld a, [hl]
	ld [DEBUG_TILE], a ; debug
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
PLAYER_INDEX: ; Tile Index
	ds 1
PLAYER_ATTRI: ; Attributes/Flags
	ds 1
MAP_Y_POS:
	ds 1
MAP_X_POS:
	ds 1
MAP_HIGH:
	ds 1
MAP_LOW:
	ds 1
DEBUG_TILE:
	ds 1

SECTION "Shadow OAM", WRAM0[_RAM+$100]

wShadowOAM:
	ds 4*40 ; This is the buffer we'll write sprite data to

SECTION "OAM DMA", HRAM

hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to