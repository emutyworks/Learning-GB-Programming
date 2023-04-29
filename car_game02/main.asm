;
; I used this Website/Document as a reference to create "main.asm".
;
; Lesson H9- Hello World on the Gameboy and Gameboy Color
; https://www.chibiakumas.com/z80/helloworld.php#LessonH9
;
; Pan Docs
; https://gbdev.io/pandocs/
;
; OAM DMA tutorial
; https://gbdev.gg8.se/wiki/articles/OAM_DMA_tutorial
;
; The Cycle-Accurate Game Boy Docs (p25: 7. Joypad)
; https://github.com/AntonioND/giibiiadvance/blob/master/docs/TCAGBD.pdf
;

INCLUDE "hardware.inc"
INCLUDE "equ.inc"
INCLUDE "macro.inc"

SECTION "Header",ROM0[$100]

EntryPoint:
	di
	jr Start

REPT $150 - $104
	db 0
ENDR

SECTION "Start",ROM0[$150]

Start:
	call CopyDMARoutine ; move DMA subroutine to HRAM
	mWaitVBlank

	; Set BG Palette
	ld a,%10000000 ; Palette 0, Auto increment after writing
	ldh [rBCPS],a
	ld c,BGPaletteCnt
	ld hl,BGPalette
	ld de,rBCPD
	call SetPalette

	; Set Object Palette
	ld a,%10000000
	ldh [rOCPS],a
	ld c,ObjPaletteCnt
	ld hl,ObjPalette
	ld de,rOCPD
	call SetPalette

	xor a
	ldh [rLCDC],a
	ldh [rIE],a
	ldh [rIF],a
	ldh [rSTAT],a
	ldh [rSVBK],a
	ldh [rSCY],a
	ldh [rSCX],a
	ld [wJoypad],a
	ld [wButton],a
	ld [wCarDir],a
	ld [wInputWait],a
	ld [wCarSpeedY],a
	ld [wCarSpeedX],a

	; Set Tiles data
	ld hl,_VRAM8000
	ld de,Tiles
	ld bc,TilesEnd - Tiles
	call CopyData
	call SetMapPartTbl

	; Reset Map Indexes/Attributes Table
	ld hl,wMapIndexesTbl
	ld e,MapSize*2
	xor a
.resetMapLoop
	ld [hli],a
	dec e
	jr nz,.resetMapLoop

	; Set Map data
	ld a,HIGH(InitMapTbl)
	ld [wMapTbl],a
	ld a,LOW(InitMapTbl)
	ld [wMapTbl+1],a
	ld a,32

.initMapData
	dec a
	push af
	
	ld h,HIGH(MapVramTbl)
	add a,a
	ld l,a
	ld a,[hli]
	ld e,a ;l
	ld a,[hl]
	ld d,a ;h
	push de
	mSetMapTbl
	pop de
	mSetVram
	ld bc,MapTblSize
	ld a,[wMapTbl]
	ld h,a
	ld a,[wMapTbl+1]
	ld l,a
	add hl,bc
	ld a,h
	ld [wMapTbl],a
	ld a,l
	ld [wMapTbl+1],a

	pop af
	cp 0
	jp nz,.initMapData

	xor a
	ldh [rVBK],a
	ld hl,$9A01
	ld de,Message1
	ld bc,Message1End - Message1
	call CopyData

	ld a,LCDCF_ON|LCDCF_BG8000|LCDCF_OBJON|LCDCF_BGON
	ldh [rLCDC],a

	call InitwShadowOAM

	; Set Car Sprite
	ld a,CarStartY
	ld [wCarPosY],a
	ld a,CarStartX
	ld [wCarPosX],a

	ld a,0
	ld [wCarDir],a

MainLoop:
	mWaitVBlank

;	ld a,[wInputWait]
;	cp 0
;	jr z,.check
;	dec a
;	ld [wInputWait],a
;	jr MainLoop

.check
	xor a
	ld [wCarSpeedY],a
	ld [wCarSpeedX],a

	mCheckJoypad

	ld a,[wJoypad]
	ld e,a
	bit JBitRight,a
	jr z,.left

	ld a,[wCarDir]
	cp CarMaxDir
	jr nz,.add
	xor a
	ld [wCarDir],a
	jr .check0

.add
	inc a
	ld [wCarDir],a
	jr .check0

.left
	ld a,e
	bit JBitLeft,a
	jr z,.check0

	ld a,[wCarDir]
	cp 0
	jr nz,.dec

	ld a,CarMaxDir
	ld [wCarDir],a
	jr .check0

.dec
	dec a
	ld [wCarDir],a

.check0
	ld a,[wCarDir]
	cp 0
	jr nz,.check1

	ld a,[wButton]
	bit JBitButtonA,a
	jp z,.set0
	ld a,255
	ld [wCarSpeedY],a
.set0
	ld bc,CarSpriteTbl+16*0
	ld hl,wShadowOAM
	call SetCarSprite
	ld a,InputWait
	ld [wInputWait],a
	jp .next

.check1
	cp 1
	jr nz,.check2

	ld a,[wButton]
	bit JBitButtonA,a
	jp z,.set1
	ld a,255
	ld [wCarSpeedY],a
	ld a,[wCarPosY]
	bit 0,a
	jp z,.set1
	ld a,1
	ld [wCarSpeedX],a

.set1
	ld bc,CarSpriteTbl+16*1
	ld hl,wShadowOAM
	call SetCarSprite
	ld a,InputWait
	ld [wInputWait],a
	jp .next

.check2
	cp 2
	jr nz,.check3

	ld a,[wButton]
	bit JBitButtonA,a
	jp z,.set2
	ld a,255
	ld [wCarSpeedY],a
	ld a,1
	ld [wCarSpeedX],a
.set2
	ld bc,CarSpriteTbl+16*2
	ld hl,wShadowOAM
	call SetCarSprite
	ld a,InputWait
	ld [wInputWait],a
	jp .next

.check3
	cp 3
	jr nz,.check4

	ld a,[wButton]
	bit JBitButtonA,a
	jp z,.set3
	ld a,1
	ld [wCarSpeedX],a
	ld a,[wCarPosX]
	bit 0,a
	jp z,.set3
	ld a,255
	ld [wCarSpeedY],a

.set3
	ld bc,CarSpriteTbl+16*3
	ld hl,wShadowOAM
	call SetCarSprite
	ld a,InputWait
	ld [wInputWait],a
	jp .next

.check4
	cp 4
	jr nz,.check5

	ld a,[wButton]
	bit JBitButtonA,a
	jp z,.set4
	ld a,1
	ld [wCarSpeedX],a

.set4
	ld bc,CarSpriteTbl+16*4
	ld hl,wShadowOAM
	call SetCarSprite
	ld a,InputWait
	ld [wInputWait],a
	jp .next

.check5
	cp 5
	jr nz,.check6

	ld a,[wButton]
	bit JBitButtonA,a
	jp z,.set5
	ld a,1
	ld [wCarSpeedX],a
	ld a,[wCarPosX]
	bit 0,a
	jp z,.set5
	ld a,1
	ld [wCarSpeedY],a

.set5
	ld bc,CarSpriteTbl+16*5
	ld hl,wShadowOAM
	call SetCarSprite
	ld a,InputWait
	ld [wInputWait],a
	jp .next

.check6
	cp 6
	jr nz,.check7

	ld a,[wButton]
	bit JBitButtonA,a
	jp z,.set6
	ld a,1
	ld [wCarSpeedY],a
	ld [wCarSpeedX],a

.set6
	ld bc,CarSpriteTbl+16*6
	ld hl,wShadowOAM
	call SetCarSprite
	ld a,InputWait
	ld [wInputWait],a
	jp .next

.check7
	cp 7
	jr nz,.check8

	ld a,[wButton]
	bit JBitButtonA,a
	jp z,.set7
	ld a,1
	ld [wCarSpeedY],a
	ld a,[wCarPosY]
	bit 0,a
	jp z,.set7
	ld a,1
	ld [wCarSpeedX],a

.set7
	ld bc,CarSpriteTbl+16*7
	ld hl,wShadowOAM
	call SetCarSprite
	ld a,InputWait
	ld [wInputWait],a
	jp .next

.check8
	cp 8
	jr nz,.check9

	ld a,[wButton]
	bit JBitButtonA,a
	jp z,.set8
	ld a,1
	ld [wCarSpeedY],a

.set8
	ld bc,CarSpriteTbl+16*8
	ld hl,wShadowOAM
	call SetCarSprite
	ld a,InputWait
	ld [wInputWait],a
	jp .next

.check9
	cp 9
	jr nz,.check10

	ld a,[wButton]
	bit JBitButtonA,a
	jp z,.set9
	ld a,1
	ld [wCarSpeedY],a
	ld a,[wCarPosY]
	bit 0,a
	jp z,.set9
	ld a,255
	ld [wCarSpeedX],a

.set9
	ld bc,CarSpriteTbl+16*9
	ld hl,wShadowOAM
	call SetCarSprite
	ld a,InputWait
	ld [wInputWait],a
	jp .next

.check10
	cp 10
	jr nz,.check11

	ld a,[wButton]
	bit JBitButtonA,a
	jp z,.set10
	ld a,1
	ld [wCarSpeedY],a
	ld a,255
	ld [wCarSpeedX],a

.set10
	ld bc,CarSpriteTbl+16*10
	ld hl,wShadowOAM
	call SetCarSprite
	ld a,InputWait
	ld [wInputWait],a
	jp .next

.check11
	cp 11
	jr nz,.check12

	ld a,[wButton]
	bit JBitButtonA,a
	jp z,.set11
	ld a,255
	ld [wCarSpeedX],a
	ld a,[wCarPosX]
	bit 0,a
	jp z,.set11
	ld a,1
	ld [wCarSpeedY],a

.set11
	ld bc,CarSpriteTbl+16*11
	ld hl,wShadowOAM
	call SetCarSprite
	ld a,InputWait
	ld [wInputWait],a
	jp .next

.check12
	cp 12
	jr nz,.check13

	ld a,[wButton]
	bit JBitButtonA,a
	jp z,.set12
	ld a,255
	ld [wCarSpeedX],a

.set12
	ld bc,CarSpriteTbl+16*12
	ld hl,wShadowOAM
	call SetCarSprite
	ld a,InputWait
	ld [wInputWait],a
	jp .next

.check13
	cp 13
	jr nz,.check14

	ld a,[wButton]
	bit JBitButtonA,a
	jp z,.set13
	ld a,255
	ld [wCarSpeedX],a
	ld a,[wCarPosX]
	bit 0,a
	jp z,.set13
	ld a,255
	ld [wCarSpeedY],a

.set13
	ld bc,CarSpriteTbl+16*13
	ld hl,wShadowOAM
	call SetCarSprite
	ld a,InputWait
	ld [wInputWait],a
	jr .next

.check14
	cp 14
	jr nz,.check15

	ld a,[wButton]
	bit JBitButtonA,a
	jp z,.set14
	ld a,255
	ld [wCarSpeedX],a
	ld [wCarSpeedY],a

.set14
	ld bc,CarSpriteTbl+16*14
	ld hl,wShadowOAM
	call SetCarSprite
	ld a,InputWait
	ld [wInputWait],a
	jr .next

.check15
	cp 15
	jr nz,.next

	ld a,[wButton]
	bit JBitButtonA,a
	jp z,.set15
	ld a,255
	ld [wCarSpeedY],a
	ld a,[wCarPosY]
	bit 0,a
	jp z,.set15
	ld a,255
	ld [wCarSpeedX],a

.set15
	ld bc,CarSpriteTbl+16*15
	ld hl,wShadowOAM
	call SetCarSprite
	ld a,InputWait
	ld [wInputWait],a
	jr .next

.next
	mWaitVBlank
	mSetOAM
	jp MainLoop

SetCarSprite:
	ld a,[wCarSpeedY]
	ld d,a
	ld a,[wCarPosY]
	add a,d
	ld [wCarPosY],a

	ld a,[wCarSpeedX]
	ld d,a
	ld a,[wCarPosX]
	add a,d
	ld [wCarPosX],a

	ld e,4 ; Sprite pattern count
.loop
	ld a,[wCarPosY]
	ld d,a
	ld a,[bc]
	add a,d
	ld [hli],a ; Y Position
	inc c
	ld a,[wCarPosX]
	ld d,a
	ld a,[bc]
	add a,d
	ld [hli],a ; X Position
	inc c
	ld a,[bc]
	ld [hli],a ; Tile Index
	inc c
	ld a,[bc]
	ld [hli],a ; Attributes/Flags
	inc c
	dec e
	jr nz,.loop
	ret

SetMapPartTbl:
	ld hl,wMapPartTbl
	ld bc,MapPartTblSize
.reset
	xor a
	ld [hli],a
	dec bc
	ld a,b
	or c
	jr nz,.reset

	ld bc,MapPartTbl
	ld hl,wMapPartTbl
.loop
	ld e,0
	ld a,[bc]
	ld d,a
	and %00011111
	ld [hli],a
	;cp BGPriorityTile
	;jr c,.skip1
	;ld e,%10000000 ; BG-to-OAM Priority
.skip1
	ld a,d
	and %00100000 ; Horizontal Flip
	or e
	ld e,a
	ld a,d
	and %11000000
	swap a
	rrca
	rrca
	or e
	inc hl
	ld [hld],a
	inc bc

	ld e,0
	ld a,[bc]
	ld d,a
	and %00011111
	ld [hli],a
	;cp BGPriorityTile
	;jr c,.skip2
	;ld e,%10000000 ; BG-to-OAM Priority
.skip2
	ld a,d
	and %00100000 ; Horizontal Flip
	or e
	ld e,a
	ld a,d
	and %11000000
	swap a
	rrca
	rrca
	or e
	inc hl
	ld [hli],a
	inc bc

	ld de,MapPartTblEnd
	ld a,c
	cp e
	jr nz,.loop
	ld a,b
	cp d
	jr nz,.loop
  ret

SetPalette:
.loop
	ld a,[hli]
	ld [de],a
	ld a,[hli]
	ld [de],a
	dec c
	jr nz,.loop
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
.loop
	ld a,[hli]
	ldh [c],a
	inc c
	dec b
	jr nz,.loop
	ret

DMARoutine:
	ldh [rDMA],a
	ld a,40
.loop
	dec a
	jr nz,.loop
	ret
DMARoutineEnd:

InitwShadowOAM:
	ld hl,wShadowOAM
	ld c,4*40
	xor a
.loop
	ld [hli],a
	dec c
	jr nz,.loop
	ret

INCLUDE "data.inc"
INCLUDE "wram.inc"