;
; I used this Website/Document as a reference to create "main.asm".
;
; Lesson H9- Hello World on the Gameboy and Gameboy Color
; https://www.chibiakumas.com/z80/helloworld.php#LessonH9
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

SpriteCenterY  EQU 84 ; 16+68
SpriteCenterX  EQU 84 ; 8+76
RotateAngleMax EQU 64

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
	call SetBGPalette
	call SetObjPalette

	xor a
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
	call CopyData

	; Init display registers
	;ld a,%11100100
	;ldh [rBGP],a ; BG Palette
	;ldh [rOBP0],a ; Object Palette 0
	;ldh [rOBP1],a ; Object Palette 1

	; Turn screen on, display background
	ld a,LCDCF_ON|LCDCF_OBJON
	ldh [rLCDC],a

	; Set OAM
	call InitwShadowOAM

	; Set Sprite Table
	ld hl,wSpriteTbl
	ld de,SpriteTbl
	ld bc,SpriteTblEnd - SpriteTbl
	call CopyData

MainLoop:
	ld hl,wShadowOAM
	call DrawSprite
	call DrawSprite2
	call SetOAM
	call WaitDraw

	jp MainLoop

DrawSprite:
	ld a,SpriteCenterY
	ld [hli],a ; Y Position
	ld a,SpriteCenterX
	ld [hli],a ; X Position
	ld a,1
	ld [hli],a ; Tile Index
	ld a,1
	ld [hli],a ; Attributes/Flags
	ret

DrawSprite2:
	ld bc,wSpriteTbl
.drawSprite2
	call CalcRotate
	ld a,[wRotateY]
	ld [hli],a ; Y Position
	ld a,[wRotateX]
	ld [hli],a ; X Position
	ld a,[wRotateIndex]
	ld [hli],a ; Tile Index
	ld a,[wRotateAttr]
	ld [hli],a ; Attributes/Flags
	ld a,c
	sub a,LOW(wSpriteTblEnd)
	jp nz,.drawSprite2
	ret

CalcRotate:
	ld a,[bc]
	ld [wRotateIndex],a
	inc c
	ld a,[bc]
	ld [wRotateAttr],a
	inc c
	ld a,[bc]
	ld [wRotateRange],a
	inc c

	; Get RotateTbl
	ld a,[bc] ; Angle
	inc a
	ld d,a
	sub a,RotateAngleMax
	jp z,.getRotateTbl1
	ld a,d
	ld [bc],a
	jp .getRotateTbl2
.getRotateTbl1
	xor a
	ld [bc],a
.getRotateTbl2
	inc c
	add a,a
	add a,a
	push bc
	push hl
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
	ld a,[wRotateRange]
.calcRotationY
	add hl,bc
	dec a
	jr nz,.calcRotationY
	ld a,SpriteCenterY
	add a,h
	ld [wRotateY],a

	ld h,d
	ld l,e
	ld a,[wRotateRange]
.calcRotationX
	add hl,de
	dec a
	jr nz,.calcRotationX
	ld a,SpriteCenterX
	add a,h
	ld [wRotateX],a
	pop hl
	pop bc
	ret

WaitDraw:
	ld b,6
.waitDraw
	call WaitVBlank
	dec b
	jr nz,.waitDraw
	ret

SetBGPalette:
	ld hl,BGPalette
	ld c,0 ; Palette 0
.setBGPalette
	ld a,[hli] ; GGGRRRRR
	ld e,a
	ld a,[hli] ; xBBBBBGG
	ld d,a
	inc a
	ret z

	push hl
	ld hl,rBCPS ; $FF68
	ld [hl],c
	inc hl ; $FF69
	ld [hl],e
	dec hl
	inc c
	ld [hl],c
	inc hl
	ld [hl],d
	inc c
	pop hl
	jr .setBGPalette

SetObjPalette:
	ld hl,ObjPalette
	ld c,0 ; Palette 0
.setObjPalette
	ld a,[hli] ; GGGRRRRR
	ld e,a
	ld a,[hli] ; xBBBBBGG
	ld d,a
	inc a
	ret z

	push hl
	ld hl,rOCPS ; $FF6A
	ld [hl],c
	inc hl ; $FF6B
	ld [hl],e
	dec hl
	inc c
	ld [hl],c
	inc hl
	ld [hl],d
	inc c
	pop hl
	jr .setObjPalette

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

CopyData:
	ld a,[de] ; Grab 1 byte from the source
	ld [hli],a ; Place it at the destination, incrementing hl
	inc de ; Move to next byte
	dec bc ; Decrement count
	ld a,b ; Check if count is 0, since `dec bc` doesn't update flags
	or c
	jr nz,CopyData
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

InitwShadowOAM:
	ld hl,wShadowOAM
	ld bc,4*40
.initwShadowOAM
	xor a
	ld [hli],a
	dec bc
	ld a,b
	or c
	jr nz,.initwShadowOAM
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

SECTION "Sprite Table",ROM0[$3100]
SpriteTbl: ;Index,Attributes/Flags,Range,Angle(0-63)
	db 1,0,17,53,
	db 1,0,10,57,
	db 1,1, 7, 0,
	db 1,0,11, 8,
	db 1,0,18,11,
	
	db 1,0,21,57,
	db 1,0,17,60,
	db 1,1,15, 0,
	db 1,0,18, 5,
	db 1,0,22, 8,
	
	db 1,0, 7,49,
	db 1,0,15,49,
	db 1,0, 7,16,
	db 1,0,15,16,
	
	db 1,0,16,44,
	db 1,0,10,40,
	db 1,1, 7,31,
	db 1,0,10,23,
	db 1,0,17,20,
	
	db 1,0,20,40,
	db 1,0,16,36,
	db 1,1,15,32,
	db 1,0,17,27,
	db 1,0,21,23,
SpriteTblEnd:

SECTION "Color Palette",ROM0[$3200]
BGPalette:
	  ; xBBBBBGGGGGRRRRR
	dw %0111111111111111 ; BG0 0
	dw %0000001111100000 ; BG0 1
	dw %0000000000011111 ; BG0 2
	dw %0111110000000000 ; BG0 3
	dw $FFFF

ObjPalette:
	  ; xBBBBBGGGGGRRRRR
	dw %0000000000011111 ; BG0 0
	dw %0000001111111111 ; BG0 1
	dw %0000000000011111 ; BG0 2
	dw %0000000000010000 ; BG0 3
	dw %0000000000011111 ; BG0 0
	dw %0111111111111111 ; BG0 1
	dw %0111110000000000 ; BG0 2
	dw %0100100000000000 ; BG0 3
	dw $FFFF

SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

SECTION "Sprite Work",WRAM0[$C100]
wSpriteTbl: 
	ds 4*24
wSpriteTblEnd:

wRotateY: ds 1
wRotateX: ds 1
wRotateRange: ds 1
wRotateIndex: ds 1
wRotateAttr: ds 1

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to