;
; I used this Website/Document as a reference to create "main.asm".
;
; GB ASM Programming Tutorial: Hello World!
; https://eldred.fr/gb-asm-tutorial/hello-world.html
;
; The Cycle-Accurate Game Boy Docs (p25: 7. Joypad)
; https://github.com/AntonioND/giibiiadvance/blob/master/docs/TCAGBD.pdf
;
; OAM DMA tutorial
; https://gbdev.gg8.se/wiki/articles/OAM_DMA_tutorial
;
; Dead C Scroll
; https://github.com/BlitterObjectBob/DeadCScroll
;
; Pan Docs: Interrupts
; https://gbdev.io/pandocs/Interrupts.html
;

INCLUDE "hardware.inc"

VBlankScrollStart EQU 8*12-2
VBlankScrollEnd   EQU 8*17-2
ScrollSpeed       EQU 1
BgScrollStartY    EQU -8*3+1
BgScrollTopY      EQU BgScrollStartY+8*5
BgScrollBottomY   EQU BgScrollStartY
PlayerStartY      EQU 8*12-4 ;8*17-4
PlayerStartX      EQU 8*10
ShadowStartY      EQU PlayerStartY+8*5+5
ShadowStartX      EQU PlayerStartX
ChangeShadowPal   EQU ShadowStartY-8*2-4
DpadWait          EQU 3
; Tile
PlayerTile        EQU 40
ShadowTile        EQU 41
PlayerTileLTurnL  EQU 42
PlayerTileLTurnR  EQU 43
PlayerTileRTurnL  EQU 43
PlayerTileRTurnR  EQU 42

SECTION	"VBlank Handler",ROM0[$40]
	push af
	ld a,1
	ld [wVBlankDone],a
	pop af
	reti

SECTION	"HBlank Handler",ROM0[$48]
	push af
	push hl
	push de

	ldh a,[rLY]
	ld e,a
	sub 8*4 ; 8*4-2
	jr c,RetHBlank1

	ld a,e
	sub VBlankScrollStart
	jr c,HBlank1BgScroll

	xor a
	ldh [rSCY],a
	ldh [rSCX],a

	ld a,e
	sub VBlankScrollEnd
	jr nc,RetHBlank1

	ld a,e
	sub VBlankScrollStart
	ld l,a
	ldh a,[hDrawBuffer]
	ld h,a
	ld a,[hl]
	ldh [rBGP],a
	jr RetHBlank0

HBlank1BgScroll:
	ld a,[wJoypadX]
	ldh [rSCX],a
	ld a,[wBgScrollY]
	ldh [rSCY],a
	ld a,%11100100
	ldh [rBGP],a
	jr RetHBlank0

RetHBlank1:
	ld a,%11100100
	ldh [rBGP],a

RetHBlank0:
	pop de
	pop hl
	pop af
	reti

SECTION "Header",ROM0[$100]

EntryPoint:
	di
	jp Start

REPT $150 - $104
	db 0
ENDR

SECTION "Start",ROM0[$150]

Start:
	call CopyDMARoutine ; move DMA subroutine to HRAM
	call WaitVBlank

	xor	a
	ldh [rLCDC],a
	ldh [rIE],a
	ldh [rIF],a
	ldh [rSTAT],a
	ldh [rNR52],a ; disable the audio
	ldh [rSCY],a ; Scroll Y
	ldh [rSCX],a ; Scroll X
	ld [wVBlankDone],a

	; Set Tiles data
	ld hl,_VRAM8000
	ld de,Tiles
	ld bc,TilesEnd - Tiles
	call CopyTiles

	; Set BG tile map
	ld hl,_SCRN0
	ld de,BgTileMap
	ld bc,BgTileMapEnd - BgTileMap
	call CopyTiles

	; Init display registers
	ld a,%11100100
	ldh [rBGP],a ; BG Palette
	ldh [rOBP0],a ; Object Palette 0
	ld a,%01010100
	ldh [rOBP1],a ; Object Palette 1

	; Turn screen on, display background
	ld a,LCDCF_ON|LCDCF_BG8000|LCDCF_OBJON|LCDCF_BGON
	ldh [rLCDC],a

	; Set up the lcdc int
	ld a,STATF_LYC|STATF_MODE00 ; Mode 0 HBlank STAT Interrupt source
	ldh [rSTAT],a

	; enable the interrupts
	ld a,IEF_VBLANK|IEF_LCDC ; VBLANK = ROM0[$40], LCDC = ROM0[$48]
	ldh [rIE],a
	xor a
	ei
	ldh [rIF],a

	; Set wShadowOAM
	ld hl,wShadowOAM
	ld bc,4*40
.iniwShadowOAM
	xor a
	ld [hli],a
	dec bc
	ld a,b
	or c
	jr nz,.iniwShadowOAM

	; Set Joypad/Player
	xor a
	;ld [wJoypadState],a
	ld [wJoypadDpad],a
	ld [wJoypadBtn],a
	ld [wJoypadDpadWait],a
	ld [wJoypadX],a
	ld a,PlayerStartY
	;ld [wJoypadY],a
	ld [wPlayerY],a
	ld a,PlayerStartX
	ld [wPlayerX],a

	ld a,%00000000 ; rOBP0
	ld [wPlayerPalette],a
	call SetShadowPalette

	; Set Raster Table
	ld a,$30
	ldh [hDrawBuffer],a
	ld a,ScrollSpeed
	ld [wScrollSpeed],a
	ld [wScrollPaletteWait],a
	ld a,BgScrollBottomY
	ld [wBgScrollY],a
	jp SetOAM

MainLoop:
	call WaitForVBlankDone ; halt until interrupt occurs
	xor a
	ld [wVBlankDone],a
	call ChangeScrollPalette

	call CheckJoypad
	ld a,[wJoypadDpad]
	ld e,a
	and %00000001
	jp nz,.joypadIncX

	ld a,e
	and %00000010
	jp nz,.joypadDecX

	ld a,e
	and %00001000
	call nz,.joypadIncY

	ld a,e
	and %00000100
	call nz,.joypadDecY

	call SetPlayer
	jp SetOAM

.joypadIncX
	ld a,e
	and %00001000
	call nz,.joypadIncY
	ld a,e
	and %00000100
	call nz,.joypadDecY

	ld a,[wJoypadX]
	inc a
	ld [wJoypadX],a
	call SetPlayerRTurn
	jp SetOAM

.joypadDecX
	ld a,e
	and %00001000
	call nz,.joypadIncY
	ld a,e
	and %00000100
	call nz,.joypadDecY

	ld a,[wJoypadX]
	dec a
	ld [wJoypadX],a
	call SetPlayerLTurn
	jp SetOAM

.joypadIncY
	ld a,[wJoypadDpadWait]
	sub DpadWait
	jr c,.joypadIncY0
	xor a
	ld [wJoypadDpadWait],a

	ld a,[wBgScrollY]
	cp BgScrollTopY
	jr z,.joypadIncY0
	inc a
	ld [wBgScrollY],a
	ld a,[wPlayerY]
	inc a
	ld [wPlayerY],a
.joypadIncY0
	call SetPlayer
	ret

.joypadDecY
	ld a,[wJoypadDpadWait]
	sub DpadWait
	jr c,.joypadDecY0
	xor a
	ld [wJoypadDpadWait],a

	ld a,[wBgScrollY]
	cp BgScrollBottomY
	jr z,.joypadDecY0
	dec a
	ld [wBgScrollY],a
	ld a,[wPlayerY]
	dec a
	ld [wPlayerY],a
.joypadDecY0
	call SetPlayer
	ret

SetOAM:
	call SetShadowPalette
	call WaitVBlank
	; call the DMA subroutine we copied to HRAM
	; which then copies the bytes to the OAM and sprites begin to draw
	ld a,HIGH(wShadowOAM)
	call hOAMDMA
	jp MainLoop

WaitForVBlankDone:
.waitloop
	halt ; halt until interrupt occurs (low power)
	ld a,[wVBlankDone]
	and a
	jr z,.waitloop
	ret

WaitVBlank:
	ldh a,[rLY]
	cp SCRN_Y ; 144 ; Check if the LCD is past VBlank
	jr nz,WaitVBlank
	ret

CopyTiles:
	ld a,[de] ; Grab 1 byte from the source
	ld [hli],a ; Place it at the destination, incrementing hl
	inc de ; Move to next byte
	dec bc ; Decrement count
	ld a,b ; Check if count is 0, since `dec bc` doesn't update flags
	or c
	jr nz,CopyTiles
	ret

CopyDMARoutine:
	ld hl,DMARoutine
	ld b,DMARoutineEnd - DMARoutine ; Number of bytes to copy
	ld c,LOW(hOAMDMA) ; Low byte of the destination address
.copy
	ld a,[hli]
	ldh [c],a
	inc c
	dec b
	jr nz,.copy
	ret

DMARoutine:
	ldh [rDMA],a
	
	ld a,40
.wait
	dec a
	jr nz,.wait
	ret
DMARoutineEnd:

CheckJoypad:
	ld a,P1F_4
	ld [rP1],a ; select P14
	ld a,[rP1]
	ldh a,[rP1] ; Wait a few cycles.
	cpl ; Complement A.
	and %00001111 ; Get only first 4 bits.
	ld [wJoypadBtn],a
	ld a,P1F_5
	ld [rP1],a ; Select P15.
	ldh a,[rP1]
	ldh a,[rP1]
	ldh a,[rP1]
	ldh a,[rP1]
	ldh a,[rP1]
	ldh a,[rP1] ; Wait a few MORE cycles.
	cpl
	and %00001111
	ld [wJoypadDpad],a
	ld b,a
	ld a,%11000000 ; Deselect P14 and P15.
	ld [rP1],a

	ld a,[wJoypadDpadWait]
	inc a
	ld [wJoypadDpadWait],a
	ret

SetShadowPalette:
	ld a,[wPlayerY]
	sub ChangeShadowPal
	jr c,.setPal1
	ld a,%00000000 ; rOBP0
	ld [wShadowPalette],a
	ret
.setPal1
	ld a,%00010000 ; rOBP1
	ld [wShadowPalette],a
	ret

SetShadow:
	ld hl,wShadowOAM+4*2
	ld a,ShadowStartY
	ld d,a
	add a,b
	ld [hli],a
	ld a,ShadowStartX
	ld e,a
	ld [hli],a
	ld a,ShadowTile
	ld [hli],a
	ld a,[wShadowPalette]
	or %01000000 ; Attributes/Flags
	ld [hli],a
	;
	ld a,d
	add a,c
	ld [hli],a
	ld a,e
	add a,8
	ld [hli],a
	ld a,ShadowTile
	ld [hli],a
	ld a,[wShadowPalette]
	or %01100000
	ld [hli],a
	;
	ld a,d
	add a,8
	add a,b
	ld [hli],a
	ld a,e
	ld [hli],a
	ld a,ShadowTile
	ld [hli],a
	ld a,[wShadowPalette]
	or %00000000
	ld [hli],a
	;
	ld a,d
	add a,8
	add a,c
	ld [hli],a
	ld a,e
	add a,8
	ld [hli],a
	ld a,ShadowTile
	ld [hli],a
	ld a,[wShadowPalette]
	or %00100000
	ld [hli],a
	ret

SetPlayer:
	ld hl,wShadowOAM
	ld a,[wPlayerY]
	ld d,a
	ld [hli],a
	ld a,[wPlayerX]
	ld e,a
	ld [hli],a
	ld a,PlayerTile
	ld [hli],a
	ld a,[wPlayerPalette]
	or %00000000
	ld [hli],a
	;
	ld a,d
	ld [hli],a
	ld a,e
	add a,8
	ld [hli],a
	ld a,PlayerTile
	ld [hli],a
	ld a,[wPlayerPalette]
	or %00100000
	ld [hli],a
	ld b,0
	ld c,0
	jr SetShadow

SetPlayerRTurn:
	ld hl,wShadowOAM
	ld a,[wPlayerY]
	ld d,a
	ld [hli],a
	ld a,[wPlayerX]
	ld e,a
	ld [hli],a
	ld a,PlayerTileRTurnL
	ld [hli],a
	ld a,[wPlayerPalette]
	or %00100000
	ld [hli],a
	;
	ld a,d
	ld [hli],a
	ld a,e
	add a,8
	ld [hli],a
	ld a,PlayerTileRTurnR
	ld [hli],a
	ld a,[wPlayerPalette]
	or %00100000
	ld [hli],a
	ld b,0
	ld c,1
	jp SetShadow

SetPlayerLTurn:
	ld hl,wShadowOAM
	ld a,[wPlayerY]
	ld d,a
	ld [hli],a
	ld a,[wPlayerX]
	ld e,a
	ld [hli],a
	ld a,PlayerTileLTurnL
	ld [hli],a
	ld a,[wPlayerPalette]
	or %00000000
	ld [hli],a
	;
	ld a,d
	ld [hli],a
	ld a,e
	add a,8
	ld [hli],a
	ld a,PlayerTileLTurnR
	ld [hli],a
	ld a,[wPlayerPalette]
	or %00000000
	ld [hli],a
	ld b,1
	ld c,0
	jp SetShadow

ChangeScrollPalette:
	ld a,[wScrollPaletteWait]
	dec a
	ld [wScrollPaletteWait],a
	and a
	ret nz
	
	ld a,[wScrollSpeed]
	ld [wScrollPaletteWait],a

	ld a,[hDrawBuffer]
	ld b,a
	sub $37
	jr nc,.setPalette2

	ld a,b
	inc a
	ldh [hDrawBuffer],a
	ret

.setPalette2:
	ld a,$30
	ldh [hDrawBuffer],a
	ret

Tiles:
	INCBIN "tiles.bin"
TilesEnd:

BgTileMap:
	INCBIN "map.bin"
BgTileMapEnd:

SECTION "Raster Scroll Palette 1",ROM0[$3000]
	;%11100100=$e4/%11100101=$e5
	db $e5,$e4,$e5,$e4,$e5,$e5,$e4,$e4,$e5,$e5,$e5,$e4,$e4,$e4,$e5,$e5
	db $e5,$e4,$e4,$e4,$e5,$e5,$e5,$e5,$e4,$e4,$e4,$e4,$e5,$e5,$e5,$e5
	db $e4,$e4,$e4,$e4,$e5,$e5,$e5,$e5
SECTION "Raster Scroll Palette 2",ROM0[$3100];+1
	db $e5,$e5,$e4,$e5,$e4,$e5,$e5,$e4,$e4,$e5,$e5,$e5,$e4,$e4,$e4,$e5
	db $e5,$e5,$e4,$e4,$e4,$e5,$e5,$e5,$e5,$e4,$e4,$e4,$e4,$e5,$e5,$e5
	db $e5,$e4,$e4,$e4,$e4,$e5,$e5,$e5
SECTION "Raster Scroll Palette 3",ROM0[$3200];+2
	db $e5,$e5,$e4,$e5,$e4,$e4,$e5,$e5,$e4,$e4,$e5,$e5,$e5,$e4,$e4,$e4
	db $e5,$e5,$e5,$e4,$e4,$e4,$e5,$e5,$e5,$e5,$e4,$e4,$e4,$e4,$e5,$e5
	db $e5,$e5,$e4,$e4,$e4,$e4,$e5,$e5
SECTION "Raster Scroll Palette 4",ROM0[$3300];+3
	db $e5,$e5,$e4,$e5,$e4,$e4,$e5,$e5,$e4,$e4,$e4,$e5,$e5,$e5,$e4,$e4
	db $e4,$e5,$e5,$e5,$e4,$e4,$e4,$e5,$e5,$e5,$e5,$e4,$e4,$e4,$e4,$e5
	db $e5,$e5,$e5,$e4,$e4,$e4,$e4,$e5
SECTION "Raster Scroll Palette 5",ROM0[$3400];+4
	db $e5,$e5,$e4,$e5,$e4,$e4,$e5,$e5,$e4,$e4,$e4,$e5,$e5,$e5,$e4,$e4
	db $e4,$e5,$e5,$e5,$e4,$e4,$e4,$e4,$e5,$e5,$e5,$e5,$e4,$e4,$e4,$e4
	db $e5,$e5,$e5,$e5,$e4,$e4,$e4,$e4
SECTION "Raster Scroll Palette 6",ROM0[$3500];+5
	db $e5,$e5,$e4,$e5,$e5,$e4,$e4,$e5,$e5,$e4,$e4,$e4,$e5,$e5,$e5,$e4
	db $e4,$e4,$e5,$e5,$e5,$e4,$e4,$e4,$e4,$e5,$e5,$e5,$e5,$e4,$e4,$e4
	db $e4,$e5,$e5,$e5,$e5,$e4,$e4,$e4
SECTION "Raster Scroll Palette 7",ROM0[$3600];+6
	db $e5,$e4,$e5,$e4,$e5,$e5,$e4,$e4,$e5,$e5,$e4,$e4,$e4,$e5,$e5,$e5
	db $e4,$e4,$e4,$e5,$e5,$e5,$e4,$e4,$e4,$e4,$e5,$e5,$e5,$e5,$e4,$e4
	db $e4,$e4,$e5,$e5,$e5,$e5,$e4,$e4
SECTION "Raster Scroll Palette 8",ROM0[$3700];+7
	db $e5,$e4,$e5,$e4,$e5,$e5,$e4,$e4,$e5,$e5,$e5,$e4,$e4,$e4,$e5,$e5
	db $e5,$e4,$e4,$e4,$e5,$e5,$e5,$e4,$e4,$e4,$e4,$e5,$e5,$e5,$e5,$e4
	db $e4,$e4,$e4,$e5,$e5,$e5,$e5,$e4
SECTION "Raster Scroll Palette 0",ROM0[$3800];0
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00

SECTION "Shadow OAM",WRAM0[_RAM]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to
wVBlankDone: ds 1
; Joypad
;wJoypadState: ds 1
wJoypadDpad: ds 1
wJoypadBtn: ds 1
wJoypadDpadWait: ds 1
;wJoypadY: ds 1
wJoypadX: ds 1
; Scroll
wScrollPaletteWait: ds 1
wScrollSpeed: ds 1
wBgScrollY: ds 1
; Player
wPlayerY: ds 1
wPlayerX: ds 1
wPlayerPalette: ds 1
wShadowY: ds 1
wShadowX: ds 1
wShadowPalette: ds 1

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to
hDrawBuffer:
	ds 1 ; buffer offsets (put in h, l=00)