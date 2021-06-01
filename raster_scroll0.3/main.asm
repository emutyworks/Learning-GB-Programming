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

VBlankScrollStart EQU 8*5-1
VBlankScrollEnd   EQU 8*11-1
PlayerStartPosY   EQU 16+8*8
PlayerStartPosX   EQU 8+8*9
ScrollSpeed       EQU 3

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
	sub a,VBlankScrollStart
	jr c,RetHBlank1

	ld a,e
	sub a,VBlankScrollEnd
	jr nc,RetHBlank1

	ld a,e
	sub a,VBlankScrollStart
	ld l,a
	ldh a,[hDrawBuffer]
	ld h,a
	ld a,[hl]
	ldh [rBGP],a
	jr RetHBlank0

RetHBlank1:
	ld a,$e4
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
	ldh	[rIE],a
	ldh	[rIF],a
	ldh	[rSTAT],a
	ldh [rNR52],a ; disable the audio
	ldh [rSCY],a ; Scroll Y
	ld a,8*6
	ldh [rSCX],a ; Scroll X

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
	ldh [rOBP1],a ; Object Palette 1

	; Turn screen on, display background
	ld a,LCDCF_ON|LCDCF_BG8000|LCDCF_OBJON|LCDCF_BGON
	ldh [rLCDC],a

	; set up the lcdc int
	ld a,STATF_LYC|STATF_MODE00 ; Mode 0 HBlank STAT Interrupt source
	ldh [rSTAT],a

	; enable the interrupts
	ld a,IEF_VBLANK|IEF_LCDC ; VBLANK = ROM0[$40], LCDC = ROM0[$48]
	ldh [rIE],a
	xor a
	ei
	ldh [rIF],a

	; Initialize wShadowOAM
	ld hl,wShadowOAM
	ld bc,4*40
.iniwShadowOAM
	xor a
	ld [hli],a
	dec bc
	ld a,b
	or c
	jr nz,.iniwShadowOAM

	; Initialize Joypad
	xor a
	ld [wJoypadState],a
	ld a,PlayerStartPosY
	ld [wJoypadYpos],a
	ld a,PlayerStartPosX
	ld [wJoypadXpos],a

	; Set Raster Table	
	ld a,$30
	ldh [hDrawBuffer],a
	ld a,ScrollSpeed
	ld [wScrollSpeed],a
	ld a,1
	ld [wScrollPaletteWait],a

	jp SetOAM

MainLoop:
	call WaitForVBlankDone ; halt until interrupt occurs
	xor a
	ld [wVBlankDone],a
	call ChangeScrollPalette

	; Reading Joypad
	ld a,P1F_4
	ld [rP1],a ; select P14
	ld a,[rP1]
	ldh a,[rP1] ; Wait a few cycles.
	cpl ; Complement A.
	and a,%00001111 ; Get only first 4 bits.
	swap a ; Swap it.
	ld b,a
	ld a,P1F_5
	ld [rP1],a ; Select P15.
	ldh a,[rP1]
	ldh a,[rP1]
	ldh a,[rP1]
	ldh a,[rP1]
	ldh a,[rP1]
	ldh a,[rP1] ; Wait a few MORE cycles.
	cpl
	and a,%00001111
	or a,b ; Put A and B together.
	ld [wJoypadState],a ; Save joypad state.
	ld a,%11000000 ; Deselect P14 and P15.
	ld [rP1],a

	ld a,[wJoypadState]
	and %00000001
	jp nz,.incX

	ld a,[wJoypadState]
	and %00000010
	jp nz,.decX

	ld b,0 ; Y:Left
	ld c,0 ; Y:Right

	jp SetOAM

.incX
	ld a,[wJoypadXpos]
	inc a
	ld [wJoypadXpos],a
	ld b,0
	ld c,1

	jp SetOAM

.decX
	ld a,[wJoypadXpos]
	dec a
	ld [wJoypadXpos],a
	ld b,1
	ld c,0

SetOAM:
	; Player
	ld hl,wShadowOAM
	ld a,[wJoypadYpos]
	ld d,a
	ld [hli],a
	ld a,[wJoypadXpos]
	ld e,a
	ld [hli],a
	ld a,40 ; Tile Index
	ld [hli],a
	ld a,%00000000 ; Attributes/Flags
	ld [hli],a
	;
	ld a,d
	ld [hli],a
	ld a,e
	add a,8
	ld [hli],a
	ld a,40
	ld [hli],a
	ld a,%00100000
	ld [hli],a

	; Shadow
	ld a,d
	add a,6
	ld d,a
	add a,b
	ld [hli],a
	ld a,e
	ld [hli],a
	ld a,41 ; Tile Index
	ld [hli],a
	ld a,%01000000 ; Attributes/Flags
	ld [hli],a
	;
	ld a,d
	add a,c
	ld [hli],a
	ld a,e
	add a,8
	ld [hli],a
	ld a,41 ; Tile Index
	ld [hli],a
	ld a,%01100000 ; Attributes/Flags
	ld [hli],a
	;
	ld a,d
	add a,8
	ld d,a
	add a,b
	ld [hli],a
	ld a,e
	ld [hli],a
	ld a,41 ; Tile Index
	ld [hli],a
	ld a,%00000000 ; Attributes/Flags
	ld [hli],a
	;
	ld a,d
	add a,c
	ld [hli],a
	ld a,e
	add a,8
	ld [hli],a
	ld a,41 ; Tile Index
	ld [hli],a
	ld a,%00100000 ; Attributes/Flags
	ld [hli],a

	call WaitVBlank

	; call the DMA subroutine we copied to HRAM
	; which then copies the bytes to the OAM and sprites begin to draw
	ld a,HIGH(wShadowOAM)
	call hOAMDMA

	jp MainLoop

WaitForVBlankDone:
.waitloop:
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
	jr  nz,.wait
	ret
DMARoutineEnd:

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
	sub a,$36
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

SECTION "Raster Scroll 1",ROM0[$3000]
	;%11100100=$e4/%00100100=$24
	;%01100100=$64/%00100101=$25
	db $64,$25,$64,$25,$64,$64,$25,$25,$64,$64,$25,$25,$64,$64,$64,$25
	db $25,$25,$64,$64,$64,$25,$25,$25,$64,$64,$64,$64,$25,$25,$25,$25
	db $64,$64,$64,$64,$25,$25,$25,$25,$64,$64,$64,$64,$25,$25,$25,$25

SECTION "Raster Scroll 2",ROM0[$3100]
	db $25,$64,$25,$64,$25,$64,$64,$25,$25,$64,$64,$25,$25,$64,$64,$64,$25
	db $25,$25,$64,$64,$64,$25,$25,$25,$64,$64,$64,$64,$25,$25,$25,$25
	db $64,$64,$64,$64,$25,$25,$25,$25,$64,$64,$64,$64,$25,$25,$25,$25

SECTION "Raster Scroll 3",ROM0[$3200]
	db $64,$25,$64,$25,$64,$25,$64,$64,$25,$25,$64,$64,$25,$25,$64,$64,$64,$25
	db $25,$25,$64,$64,$64,$25,$25,$25,$64,$64,$64,$64,$25,$25,$25,$25
	db $64,$64,$64,$64,$25,$25,$25,$25,$64,$64,$64,$64,$25,$25,$25,$25

SECTION "Raster Scroll 4",ROM0[$3300]
	db $25,$64,$25,$64,$25,$64,$25,$64,$64,$25,$25,$64,$64,$25,$25,$64,$64,$64,$25
	db $25,$25,$64,$64,$64,$25,$25,$25,$64,$64,$64,$64,$25,$25,$25,$25
	db $64,$64,$64,$64,$25,$25,$25,$25,$64,$64,$64,$64,$25,$25,$25,$25

SECTION "Raster Scroll 5",ROM0[$3400]
	db $64,$25,$64,$25,$64,$25,$64,$25,$64,$64,$25,$25,$64,$64,$25,$25,$64,$64,$64,$25
	db $25,$25,$64,$64,$64,$25,$25,$25,$64,$64,$64,$64,$25,$25,$25,$25
	db $64,$64,$64,$64,$25,$25,$25,$25,$64,$64,$64,$64,$25,$25,$25,$25

SECTION "Raster Scroll 6",ROM0[$3500]
	db $25,$64,$25,$64,$25,$64,$25,$64,$25,$64,$64,$25,$25,$64,$64,$25,$25,$64,$64,$64,$25
	db $25,$25,$64,$64,$64,$25,$25,$25,$64,$64,$64,$64,$25,$25,$25,$25
	db $64,$64,$64,$64,$25,$25,$25,$25,$64,$64,$64,$64,$25,$25,$25,$25

SECTION "Raster Scroll 7",ROM0[$3600]
	db $64,$25,$64,$25,$64,$25,$64,$25,$64,$25,$64,$64,$25,$25,$64,$64,$25,$25,$64,$64,$64,$25
	db $25,$25,$64,$64,$64,$25,$25,$25,$64,$64,$64,$64,$25,$25,$25,$25
	db $64,$64,$64,$64,$25,$25,$25,$25,$64,$64,$64,$64,$25,$25,$25,$25


SECTION "Shadow OAM",WRAM0[_RAM]
	wShadowOAM:
		ds 4*40 ; This is the buffer we'll write sprite data to
	wJoypadState:
		ds 1
	wJoypadYpos:
		ds 1
	wJoypadXpos:
		ds 1
	wVBlankDone:
		ds 1
	wScrollPaletteWait:
		ds 1
	wScrollStop:
		ds 1
	wScrollSpeed:
		ds 1

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to

; buffer offsets (put in h, l=00)
; $30 = ScrollPalette1
hDrawBuffer:
	ds 1