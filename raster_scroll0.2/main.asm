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
; Dead C Scroll
; https://github.com/BlitterObjectBob/DeadCScroll
;
; Pan Docs: Interrupts
; https://gbdev.io/pandocs/#interrupts
;

SCROLL_SPEED EQU 30

INCLUDE "hardware.inc"

SECTION	"VBlank Handler",ROM0[$40]
	push af
	ld a,1
	ld [wVBlankDone],a
	pop af
	reti

SECTION	"HBlank Handler",ROM0[$48]
	push af
	push hl

	ldh a,[rLY]
	ld l,a
	ldh a,[hDrawBuffer]
	ld h,a
	ld a,[hl]
	ldh [rBGP],a

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

SECTION "Initialize",ROM0[$150]

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
	ld a,STATF_MODE00 ; Mode 0 HBlank STAT Interrupt source
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

	; Initialize Joypad State
	xor a
	ld [wJoypadState],a

	; Set OAM
	ld hl,wShadowOAM
	ld a,16+8*10-2 ; Y
	ld [wJoypadYpos],a
	ld [hli],a
	ld a,8+8*9+1 ; X
	ld [wJoypadXpos],a
	ld [hli],a
	ld a,9 ; Tile Index
	ld [hli],a
	ld a,%00000000 ; Attributes/Flags
	ld [hli],a
	;
	ld a,16+8*10-2
	ld [hli],a
	ld a,8+8*10+1
	ld [hli],a
	ld a,9
	ld [hli],a
	ld a,%00100000
	ld [hli],a
	;
	ld a,16+8*11-2
	ld [hli],a
	ld a,8+8*9-1
	ld [hli],a
	ld a,8
	ld [hli],a
	ld a,%00000000
	ld [hli],a
	;
	ld a,16+8*11-2
	ld [hli],a 
	ld a,8+8*10-1
	ld [hli],a 
	ld a,8
	ld [hli],a
	ld a,%00100000
	ld [hli],a

	; set Raster Table
	ld a,$30 ; ScrollPalette1
	ldh [hDrawBuffer],a
	xor a
	ld [wScrollPalette],a
	ld [wScrollStop],a
	ld a,SCROLL_SPEED
	ld [wScrollSpeed],a
	ld a,1
	ld [wScrollPaletteWait],a

SECTION "Main",ROM0

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

	ld a, [wJoypadState]
	and %00000100
	jp nz, .speedUp

	xor a
	ld [wScrollStop],a
	ld a,SCROLL_SPEED
	ld [wScrollSpeed],a

	ld hl,wShadowOAM
	ld a,[wJoypadYpos]
	ld b,a
	ld [hli],a
	ld a,[wJoypadXpos]
  ld c,a
	ld [hli],a
	inc hl
	inc hl
	;
	ld a,b
	ld [hli],a
	ld a,c
	add a,8
	ld [hli],a
	inc hl
	inc hl
	;
	ld a,b
	add a,8
	ld [hli],a
	ld a,c
	ld [hli],a
	inc hl
	inc hl
	;
	ld a,b
	add a,8
	ld [hli],a
	ld a,c
	add a,8
	ld [hli],a

	jp MainLoop

.speedUp
	ld a,1
	ld [wScrollStop],a
	ld a,[wScrollSpeed]
	ld h,a
	cp 3
	jp z,MainLoop
	
	ld a,h
	dec a
	ld [wScrollSpeed],a

	jp MainLoop

.incX
	ld hl,wShadowOAM
	ld a,[wJoypadYpos]
	dec a
	ld b,a
	ld [hli],a
	ld a,[wJoypadXpos]
	inc a
	ld c,a
	ld [hli],a
	inc hl
	inc hl
	;
	ld a,b
	inc a
	inc a
	ld [hli],a
	ld a,c
	add a,8
	ld [hli],a
	inc hl
	inc hl
	;
	ld a,b
	add a,8
	ld [hli],a
	ld a,c
	dec a
	dec a
	ld [hli],a
	inc hl
	inc hl
	;
	ld a,b
	inc a
	inc a
	add a,8
	ld [hli],a
	ld a,c
	dec a
	dec a
	add a,8
	ld [hli],a

	jp MainLoop

.decX
	ld hl,wShadowOAM
	ld a,[wJoypadYpos]
	inc a
	ld b,a 
	ld [hli],a
	ld a,[wJoypadXpos]
	dec a
	ld c,a
	ld [hli],a
	inc hl
	inc hl
	;
	ld a,b
	dec a
	dec a
	ld [hli],a
	ld a,c
	add a,8
	ld [hli],a
	inc hl
	inc hl
	;
	ld a,b
	add a,8
	ld [hli],a
	ld a,c
	inc a
	inc a
	ld [hli],a
	inc hl
	inc hl
	;
	ld a,b
	dec a
	dec a
	add a,8
	ld [hli],a
	ld a,c
	inc a
	inc a
	add a,8
	ld [hli],a

	jp MainLoop

SECTION "Wait VBlank routine",ROM0
WaitForVBlankDone:
.waitloop:
	halt ; halt until interrupt occurs (low power)
	ld a,[wVBlankDone]
	and a
	jr z,.waitloop

	; call the DMA subroutine we copied to HRAM
	; which then copies the bytes to the OAM and sprites begin to draw
	ld a,HIGH(wShadowOAM)
	call hOAMDMA

	ret

WaitVBlank:
	ldh a,[rLY]
	cp SCRN_Y ; 144 ; Check if the LCD is past VBlank
	jr nz,WaitVBlank
	ret

SECTION "Copy Tiles routine",ROM0
CopyTiles:
	ld a,[de] ; Grab 1 byte from the source
	ld [hli],a ; Place it at the destination, incrementing hl
	inc de ; Move to next byte
	dec bc ; Decrement count
	ld a,b ; Check if count is 0, since `dec bc` doesn't update flags
	or c
	jr nz,CopyTiles
	ret

SECTION "OAM DMA routine",ROM0
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

SECTION "Raster Scroll routine",ROM0
ChangeScrollPalette:
	ld a,[wScrollStop]
	and a
	ret z

	ld a,[wScrollPaletteWait]
	dec a
	ld [wScrollPaletteWait],a
	and a
	ret nz
	
	ld a,[wScrollSpeed]
	ld [wScrollPaletteWait],a

	ld a,[wScrollPalette]
	and a
	jr z,.setPalette2

	ld a,$30 ; ScrollPalette1
	ldh [hDrawBuffer],a
	xor a
	ld [wScrollPalette],a
	ret

.setPalette2:
	ld a,$31 ; ScrollPalette2
	ldh [hDrawBuffer],a
	ld a,1
	ld [wScrollPalette],a
	ret

SECTION "Tiles",ROM0
Tiles:
	INCBIN "tiles.bin"
TilesEnd:

SECTION "Map",ROM0
BgTileMap:
	INCBIN "map.bin"
BgTileMapEnd:

SECTION "Raster Scroll 1",ROM0[$3000]
ScrollPalette1: ; %11100100=$e4/%11010100=$d4/%11000100=$c4
	db $e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4 ; Map Y:1->4(4)
	db $e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4
	db $d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4 ; Map Y:5->12(8)
	db $d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4
	db $d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4
	db $d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4
	db $e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4 ; Map Y:13->18(6)
	db $e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4
	db $e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4
	db $e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4
	db $e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4 ;

SECTION "Raster Scroll 2",ROM0[$3100]
ScrollPalette2: ; %11100100=$e4/%11010100=$d4/%11000100=$c4
	db $e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4 ; Map Y:1->4(4)
	db $e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4
	db $e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4 ; Map Y:5->12(8)
	db $e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4
	db $e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4
	db $e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4,$e4,$e4,$d4,$d4
	db $e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4 ; Map Y:13->18(6)
	db $e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4
	db $e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4
	db $e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4
	db $e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4 ;

SECTION "Shadow OAM",WRAM0[_RAM]
wShadowOAM:
	ds 4*40 ; This is the buffer we'll write sprite data to

SECTION	"State",WRAM0
	wJoypadState:
		ds 1
	wJoypadYpos:
		ds 1
	wJoypadXpos:
		ds 1
	wVBlankDone:
		ds 1
	wScrollPalette:
		ds 1
	wScrollPaletteWait:
		ds 1
	wScrollStop:
		ds 1
	wScrollSpeed:
		ds 1

SECTION "OAM DMA",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to

SECTION	"HRAM Variables",HRAM
; buffer offsets (put in h, l=00)
; $30 = ScrollPalette1
hDrawBuffer:
	ds 1