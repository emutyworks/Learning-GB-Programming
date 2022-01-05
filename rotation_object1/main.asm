;
; I used this Website/Document as a reference to create "main.asm".
;
; 三角関数と弾幕 (Trigonometric functions and barrage)
; https://codeknowledge.livedoor.blog/archives/12749420.html
;
; Z80 固定小数と三角関数 (Z80 Fixed decimals and trigonometric functions)
; https://codeknowledge.livedoor.blog/archives/12907986.html
;
; Pan Docs
; https://gbdev.io/pandocs/
;
; OAM DMA tutorial
; https://gbdev.gg8.se/wiki/articles/OAM_DMA_tutorial
;

INCLUDE "hardware.inc"

Sprite1y EQU 84 ; Y Position
Sprite1x EQU 84 ; X Position
Sprite1i EQU 2  ; Tile Index
Sprite2y EQU 84
Sprite2x EQU 84
Sprite2i EQU 1
Sprite2r EQU 16  ; Range

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

	; Set Tiles data
	ld hl,_VRAM8000
	ld de,Tiles
	ld bc,TilesEnd - Tiles
	call CopyTiles

	; Init display registers
	ld a,%11100100
	ldh [rBGP],a ; BG Palette
	ldh [rOBP0],a ; Object Palette 0
	ldh [rOBP1],a ; Object Palette 1

	; Turn screen on, display background
	ld a,LCDCF_ON|LCDCF_OBJON
	ldh [rLCDC],a

	call InitWShadowOAM

	xor a
	ld [wAngle],a

MainLoop:
	ld hl,wShadowOAM
	call DrawSprite
	call DrawSprite2
	call SetOAM
	;call WaitDraw
	;call WaitVBlank

	jp MainLoop

DrawSprite:
	ld a,Sprite1y
	ld [hli],a ; Y Position
	ld a,Sprite1x
	ld [hli],a ; X Position
	ld a,Sprite1i
	ld [hli],a ; Tile Index
	inc hl ; Attributes/Flags
	ret

DrawSprite2:
	push hl
	
	; Get RotateTbl
	ld a,[wAngle]
	add a,a
	add a,a
	ld l,a
	ld h,HIGH(RotateTbl)
	ld c,[hl]
	inc l
	ld b,[hl] ; BC = RotateTbl Y
	inc l
	ld e,[hl]
	inc l
	ld d,[hl] ; DE = RotateTbl X
	
	; Calculate rotation
	ld h,b
	ld l,c
	ld a,Sprite2r
.calcRotationY
	add hl,bc
	dec a
	jr nz,.calcRotationY
	ld a,h
	add a,Sprite2y
	ld [wSpriteY],a

	ld h,d
	ld l,e
	ld a,Sprite2r
.calcRotationX
	add hl,de
	dec a
	jr nz,.calcRotationX
	ld a,h
	add a,Sprite2x
	ld [wSpriteX],a

	pop hl
	ld a,[wSpriteY]
	ld [hli],a ; Y Position
	ld a,[wSpriteX]
	ld [hli],a ; X Position
	ld a,Sprite2i
	ld [hli],a ; Tile Index
	;inc hl ; Attributes/Flags

	ld a,[wAngle]
	inc a
	ld [wAngle],a
	sub a,64
	ret nz
	xor a
	ld [wAngle],a
	ret

WaitDraw:
	ld b,5
.waitDraw
	call WaitVBlank
	dec b
	jr nz,.waitDraw
	ret

SetOAM:
	call WaitVBlank
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

InitWShadowOAM:
	ld hl,wShadowOAM
	ld bc,4*40
.initWShadowOAM
	xor a
	ld [hli],a
	dec bc
	ld a,b
	or c
	jr nz,.initWShadowOAM
	ret

Tiles:
	INCBIN "tiles.bin"
TilesEnd:

SECTION "Rotate Table",ROM0[$3000]
RotateTbl:
	;  Y      X      Y      X
	dw $0000, $0100, $0019, $00FE,
	dw $0031, $00FB, $004A, $00F4,
	dw $0061, $00EC, $0078, $00E1,
	dw $008E, $00D4, $00A2, $00C5,
	dw $00B5, $00B5, $00C5, $00A2,
	dw $00D4, $008E, $00E1, $0078,
	dw $00EC, $0061, $00F4, $004A,
	dw $00FB, $0031, $00FE, $0019,
	dw $0100, $0000, $00FE, $FFE6,
	dw $00FB, $FFCE, $00F4, $FFB5,
	dw $00EC, $FF9E, $00E1, $FF87,
	dw $00D4, $FF71, $00C5, $FF5D,
	dw $00B5, $FF4A, $00A2, $FF3A,
	dw $008E, $FF2B, $0078, $FF1E,
	dw $0061, $FF13, $004A, $FF0B,
	dw $0031, $FF04, $0019, $FF01,
	dw $0000, $FF00, $FFE6, $FF01,
	dw $FFCE, $FF04, $FFB5, $FF0B,
	dw $FF9E, $FF13, $FF87, $FF1E,
	dw $FF71, $FF2B, $FF5D, $FF3A,
	dw $FF4A, $FF4A, $FF3A, $FF5D,
	dw $FF2B, $FF71, $FF1E, $FF87,
	dw $FF13, $FF9E, $FF0B, $FFB5,
	dw $FF04, $FFCE, $FF01, $FFE6,
	dw $FF00, $FFFF, $FF01, $0019,
	dw $FF04, $0031, $FF0B, $004A,
	dw $FF13, $0061, $FF1E, $0078,
	dw $FF2B, $008E, $FF3A, $00A2,
	dw $FF4A, $00B5, $FF5D, $00C5,
	dw $FF71, $00D4, $FF87, $00E1,
	dw $FF9E, $00EC, $FFB5, $00F4,
	dw $FFCE, $00FB, $FFE6, $00FE,

SECTION "Shadow OAM",WRAM0[_RAM]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

SECTION "Work RAM",WRAM0
wSpriteY: ds 1
wSpriteX: ds 1
wAngle: ds 1

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to
