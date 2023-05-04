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
	ld [wCarSpeedY],a
	ld [wCarSpeedX],a
	ld [wCarSpeed],a
	ld [wSpeedUpWait],a
	ld [wSpeedDownWait],a

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

	;debug
;	ld e,DebugWait
;.loopWait
;	mWaitVBlank
;	dec e
;	jr nz,.loopWait

	mCheckJoypad
	ld a,[wButton]
	bit JBitButtonA,a
	jr nz,.setSpeed
	jr .joypad

.setSpeed
	ld a,SpeedDownWait
	ld [wSpeedDownWait],a

	ld a,[wSpeedUpWait]
	cp 0
	jr z,.addSpeed
	dec a
	ld [wSpeedUpWait],a
	jr .joypad

.addSpeed
	ld a,SpeedUpWait
	ld [wSpeedUpWait],a
	ld a,[wCarSpeed]
	cp CarMaxSpeed
	jr z,.joypad
	inc a
	ld [wCarSpeed],a

.joypad
	ld a,[wCarDir]
	ld e,a
	ld a,[wJoypad]
	bit JBitRight,a
	jr nz,.jRight
	bit JBitLeft,a
	jr nz,.jLeft
	jr .jpDir

.jRight
	inc e
	jr .jpDir
.jLeft
	dec e

.jpDir
	ld a,e
	and %00001111
	ld [wCarDir],a
	ld bc,DirJpTbl
	add a,a
	ld c,a
	ld a,[bc]
	ld l,a
	inc c
	ld a,[bc]
	ld h,a
	jp hl

Dir00:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld e,a
	xor a
	sub e
	ld [wCarSpeedY],a
.set
	ld bc,CarSpriteTbl+SpriteTblCnt*0
	ld hl,wShadowOAM
	call SetCarSprite
	jp NextLoop

Dir01:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld e,a
	xor a
	sub e
	ld [wCarSpeedY],a
	ld a,e
	cp 2
	jr z,.setX
	ld a,[wCarPosY]
	bit 0,a
	jr z,.set
.setX
	ld a,1
	ld [wCarSpeedX],a
.set
	ld bc,CarSpriteTbl+SpriteTblCnt*1
	ld hl,wShadowOAM
	call SetCarSprite
	jp NextLoop

Dir02:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld [wCarSpeedX],a
	ld e,a
	xor a
	sub e
	ld [wCarSpeedY],a
.set
	ld bc,CarSpriteTbl+SpriteTblCnt*2
	ld hl,wShadowOAM
	call SetCarSprite
	jp NextLoop

Dir03:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld [wCarSpeedX],a
	cp 2
	jr z,.setY
	ld a,[wCarPosX]
	bit 0,a
	jp z,.set
.setY
	ld a,255
	ld [wCarSpeedY],a
.set
	ld bc,CarSpriteTbl+SpriteTblCnt*3
	ld hl,wShadowOAM
	call SetCarSprite
	jp NextLoop

Dir04:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld [wCarSpeedX],a
.set
	ld bc,CarSpriteTbl+SpriteTblCnt*4
	ld hl,wShadowOAM
	call SetCarSprite
	jp NextLoop

Dir05:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld [wCarSpeedX],a
	cp 2
	jr z,.setY
	ld a,[wCarPosX]
	bit 0,a
	jp z,.set
.setY
	ld a,1
	ld [wCarSpeedY],a
.set
	ld bc,CarSpriteTbl+SpriteTblCnt*5
	ld hl,wShadowOAM
	call SetCarSprite
	jp NextLoop

Dir06:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld [wCarSpeedY],a
	ld [wCarSpeedX],a
.set
	ld bc,CarSpriteTbl+SpriteTblCnt*6
	ld hl,wShadowOAM
	call SetCarSprite
	jp NextLoop

Dir07:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld [wCarSpeedY],a
	cp 2
	jr z,.setX
	ld a,[wCarPosY]
	bit 0,a
	jp z,.set
.setX
	ld a,1
	ld [wCarSpeedX],a
.set
	ld bc,CarSpriteTbl+SpriteTblCnt*7
	ld hl,wShadowOAM
	call SetCarSprite
	jp NextLoop

Dir08:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld [wCarSpeedY],a
.set
	ld bc,CarSpriteTbl+SpriteTblCnt*8
	ld hl,wShadowOAM
	call SetCarSprite
	jp NextLoop

Dir09:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld [wCarSpeedY],a
	cp 2
	jr z,.setX
	ld a,[wCarPosY]
	bit 0,a
	jp z,.set
.setX
	ld a,255
	ld [wCarSpeedX],a
.set
	ld bc,CarSpriteTbl+SpriteTblCnt*9
	ld hl,wShadowOAM
	call SetCarSprite
	jp NextLoop

Dir10:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld [wCarSpeedY],a
	ld e,a
	xor a
	sub e
	ld [wCarSpeedX],a
.set
	ld bc,CarSpriteTbl+SpriteTblCnt*10
	ld hl,wShadowOAM
	call SetCarSprite
	jp NextLoop

Dir11:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld e,a
	xor a
	sub e
	ld [wCarSpeedX],a
	ld a,e
	cp 2
	jr z,.setY
	ld a,[wCarPosX]
	bit 0,a
	jp z,.set
.setY
	ld a,1
	ld [wCarSpeedY],a
.set
	ld bc,CarSpriteTbl+SpriteTblCnt*11
	ld hl,wShadowOAM
	call SetCarSprite
	jp NextLoop

Dir12:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld e,a
	xor a
	sub e
	ld [wCarSpeedX],a
.set
	ld bc,CarSpriteTbl+SpriteTblCnt*12
	ld hl,wShadowOAM
	call SetCarSprite
	jp NextLoop

Dir13:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld e,a
	xor a
	sub e
	ld [wCarSpeedX],a
	ld a,e
	cp 2
	jr z,.setY
	ld a,[wCarPosX]
	bit 0,a
	jp z,.set
.setY
	ld a,255
	ld [wCarSpeedY],a
.set
	ld bc,CarSpriteTbl+SpriteTblCnt*13
	ld hl,wShadowOAM
	call SetCarSprite
	jp NextLoop

Dir14:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld e,a
	xor a
	sub e
	ld [wCarSpeedX],a
	ld [wCarSpeedY],a
.set
	ld bc,CarSpriteTbl+SpriteTblCnt*14
	ld hl,wShadowOAM
	call SetCarSprite
	jp NextLoop

Dir15:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld e,a
	xor a
	sub e
	ld [wCarSpeedY],a
	ld a,e
	cp 2
	jr z,.setX
	ld a,[wCarPosY]
	bit 0,a
	jp z,.set
.setX
	ld a,255
	ld [wCarSpeedX],a
.set
	ld bc,CarSpriteTbl+SpriteTblCnt*15
	ld hl,wShadowOAM
	call SetCarSprite

NextLoop:
	mWaitVBlank
	mSetOAM

	xor a
	ld [wCarSpeedY],a
	ld [wCarSpeedX],a

	ld a,[wSpeedDownWait]
	cp 0
	jr z,.speedDownWait
	dec a
	ld [wSpeedDownWait],a
	jp MainLoop

.speedDownWait
	ld a,[wCarSpeed]
	cp 0
	jp z,MainLoop
	dec a
	ld [wCarSpeed],a
	ld a,SpeedDownWait
	ld [wSpeedDownWait],a
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