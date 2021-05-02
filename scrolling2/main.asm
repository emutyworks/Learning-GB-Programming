;
; I used this Website/Document as a reference to create "main.asm".
;
; GB ASM Programming Tutorial: Hello World!
; https://eldred.fr/gb-asm-tutorial/hello-world.html
;
; The Cycle-Accurate Game Boy Docs (p25: 7. Joypad)
; https://github.com/AntonioND/giibiiadvance/blob/master/docs/TCAGBD.pdf
;
; Pan Docs: Video Display
; https://gbdev.io/pandocs/#video-display
;
; OAM DMA tutorial
; https://gbdev.gg8.se/wiki/articles/OAM_DMA_tutorial
;

SCROLL_WAIT EQU 10

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

	; Initialize BG tile map area
	ld hl, $9800
	ld bc, $9FFF - $9800

.iniBgTileMapArea
	ld a, $00
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, .iniBgTileMapArea

	; Set BG tile map
	ld hl, _SCRN0
	ld de, BgTileMap
	ld bc, BgTileMapEnd - BgTileMap
	call CopyTiles
	
	; Set Windows tile map
	ld hl, _SCRN1
	ld de, WindowTileMap
	ld bc, WindowTileMapEnd - WindowTileMap
	call CopyTiles

	; Init display registers
	ld a, %11100100
	ld [rBGP], a ; BG Palette
	ld [rOBP0], a ; Object Palette 0
	ld [rOBP1], a ; Object Palette 1

	ld a, $00
	ld [rSCY], a ; Scroll Y
	ld [rSCX], a ; Scroll X

	ld a, 7+8*10
	ld [rWX], a ; Window X Position
	ld a, 8*10
	ld [rWY], a ; Window Y Position

	ld a, SCROLL_WAIT
	ld [SCROLL_X_WAIT], a

	; Shut sound down
	ld [rNR52], a

	; Turn screen on, display background
	ld a, %11110011 ; LCDCF_ON,LCDCF_WIN9C00,LCDCF_WINON,LCDCF_BG8000,LCDCF_OBJON,LCDCF_BGON
	ld [rLCDC], a

	; Initialize wShadowOAM
	ld hl, wShadowOAM
	ld bc, 4 * 40

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
	ld a, 80
	ld [JOYPAD_YPOS], a
	ld a, 84
	ld [JOYPAD_XPOS], a

	; Set OAM
	ld hl, wShadowOAM
	ld a, [JOYPAD_YPOS]
	ld [hli], a
	ld a, [JOYPAD_XPOS]
	ld [hli], a
	ld a, 4 ; Tile Index
	ld [hli], a
	ld a, %00000000 ; Attributes/Flags
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
	jr nz, IncXPos

	ld a, [JOYPAD_STATE]
	and %00000010
	jr nz, DecXPos

	ld a, [JOYPAD_STATE]
	and %00000100
	jr nz, DecYPos

	ld a, [JOYPAD_STATE]
	and %00001000
	jr nz, IncYPos

SetOAM:
	ld hl, wShadowOAM
	ld a, [JOYPAD_YPOS]
	ld [hli], a
	ld a, [JOYPAD_XPOS]
	ld [hli], a

	call WaitVBlank

	; call the DMA subroutine we copied to HRAM
	; which then copies the bytes to the OAM and sprites begin to draw
	ld  a, HIGH(wShadowOAM)
	call hOAMDMA

	; Scroll
	ld a, [SCROLL_X_WAIT]
	dec a
	jr z, ScrollIncX
	ld [SCROLL_X_WAIT], a

	jr MainLoop

ScrollIncX:
	ld a, [rSCX]
	inc a
	ld [rSCX], a
	ld a, SCROLL_WAIT
	ld [SCROLL_X_WAIT], a
	
	jr MainLoop 

IncXPos:
	ld a, [JOYPAD_XPOS]
	inc a	
	ld [JOYPAD_XPOS], a
	jr SetOAM

DecXPos:
	ld a, [JOYPAD_XPOS]
	dec a	
	ld [JOYPAD_XPOS], a
	jr SetOAM

IncYPos:
	ld a, [JOYPAD_YPOS]
	inc a	
	ld [JOYPAD_YPOS], a
	jr SetOAM

DecYPos:
	ld a, [JOYPAD_YPOS]
	dec a	
	ld [JOYPAD_YPOS], a
	jr SetOAM

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
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
BgTileMapEnd:

WindowTileMap:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $02,$02,$03,$03,$03,$03,$03,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $02,$03,$03,$03,$03,$03,$03,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $02,$02,$02,$02,$02,$02,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
WindowTileMapEnd:

SECTION "STATE", WRAM0[_RAM]

JOYPAD_STATE:
	ds 1
JOYPAD_YPOS:
	ds 1
JOYPAD_XPOS:
	ds 1
SCROLL_X_WAIT:
	ds 1

SECTION "Shadow OAM", WRAM0[_RAM+$100]

wShadowOAM:
	ds 4 * 40 ; This is the buffer we'll write sprite data to

SECTION "OAM DMA", HRAM

hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to