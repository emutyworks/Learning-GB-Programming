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
	ld [wCarTurn],a
	ld [wCarSpriteY],a
	ld [wCarSpriteX],a
	ld [wCarSpeedY],a
	ld [wCarSpeedX],a
	ld [wCarSpeed],a
	ld [wTurnWait],a
	ld [wDriftWait],a
	ld [wSpeedWait],a
	ld [wSpeedWaitInit],a
	ld [wSpeedWaitCnt],a
	ld [wSmokeY],a
	ld [wSmokeX],a
	ld [wSmokeAddY],a
	ld [wSmokeAddX],a
	ld [wSmokeWait],a
	ld [wNewCarSpriteY],a
	ld [wNewCarSpriteX],a
	ld [wNewRSCY],a
	ld [wNewRSCX],a
	ld [wNewSmokeY],a
	ld [wNewSmokeX],a

	; Set Sprites/Tiles data
	ld hl,_VRAM8000
	ld de,Sprites
	ld bc,SpritesEnd - Sprites
	call CopyData
	ld hl,_VRAM9000
	ld de,Tiles
	ld bc,TilesEnd - Tiles
	call CopyData

	; Set Map data
	ld a,1
	ldh [rVBK],a ; BG Map Attributes
	ld hl,_SCRN0
	ld de,BgTileMap1
	ld bc,BgTileMap1End - BgTileMap1
	call CopyData
	xor a
	ldh [rVBK],a ; Tile Indexes
	ld hl,_SCRN0
	ld de,BgTileMap0
	ld bc,BgTileMap0End - BgTileMap0
	call CopyData

	ld a,LCDCF_ON|LCDCB_BG8000|LCDCF_OBJON|LCDCF_BGON|LCDCF_OBJ16
	ldh [rLCDC],a

	call InitwShadowOAM

	; Set Car Sprite
	ld a,CarStartY
	ld [wCarSpriteY],a
	ld [wNewCarSpriteY],a
	ld a,CarStartX
	ld [wCarSpriteX],a
	ld [wNewCarSpriteX],a

	ld a,4
	ld [wCarDir],a
	ld [wCarTurn],a
	ld a,$ff
	ld [wCarShift],a

MainLoop:
	mCheckJoypad
	ld a,[wButton]
	bit JBitButtonA,a
	jr nz,.checkShift

	ld a,[wCarShift]
	cp $ff
	jr z,.joypad

	ld a,[wSpeedWait]
	cp 0
	jr z,.waitCount
	dec a
	ld [wSpeedWait],a
	jr .joypad

.waitCount
	ld a,[wSpeedWaitCnt]
	cp 0
	jr z,.shiftDown
	dec a
	ld [wSpeedWaitCnt],a
	ld a,[wSpeedWaitInit]
	ld [wSpeedWait],a
	jr .setSpeed

.checkShift
	ld a,[wCarShift]
	cp CarMaxShift
	jr z,.setSpeed
	;jr .setSpeed ;debug

	ld a,CarMaxShift
	ld [wCarShift],a
	jr .setSpeedWait

.shiftDown
	ld a,[wCarShift]
	dec a
	ld [wCarShift],a

.setSpeedWait
	ld h,HIGH(CarSpeedTbl)
	add a,a
	ld l,a
	ld a,[hli]
	ld [wSpeedWait],a
	ld [wSpeedWaitInit],a
	ld a,[hl]
	ld [wSpeedWaitCnt],a

.setSpeed
	ld a,1
	ld [wCarSpeed],a

.joypad
	ld a,[wCarDir]
	ld e,a

	ld a,[wJoypad]
	bit JBitRight,a
	jr nz,.jRight
	bit JBitLeft,a
	jr nz,.jLeft
	xor a
	ld [wTurnWait],a
	jp .jpDir

.jRight
	ld a,[wTurnWait]
	cp 0
	jp nz,.decTurnWait

	ld a,[wSmokeWait]
	cp 0
	jr nz,.setRight
	ld a,SmokeWait
	ld [wSmokeWait],a
	ld a,[wCarSpriteY]
	ld [wSmokeY],a
	ld a,[wCarSpriteX]
	ld [wSmokeX],a
.setRight
	ld a,[wCarTurn]
	ld e,a
	inc a
	and %00001111
	ld [wCarTurn],a
	ld a,TurnWait
	ld [wTurnWait],a
	ld a,DriftWait
	ld [wDriftWait],a
	jr .jpDir

.jLeft
	ld a,[wTurnWait]
	cp 0
	jr nz,.decTurnWait

	ld a,[wSmokeWait]
	cp 0
	jr nz,.setLeft
	ld a,SmokeWait
	ld [wSmokeWait],a
	ld a,[wCarSpriteY]
	ld [wSmokeY],a
	ld a,[wCarSpriteX]
	ld [wSmokeX],a
.setLeft
	ld a,[wCarTurn]
	ld e,a
	dec a
	and %00001111
	ld [wCarTurn],a
	ld a,TurnWait
	ld [wTurnWait],a
	ld a,DriftWait
	ld [wDriftWait],a
	jr .jpDir

.decTurnWait
	dec a
	ld [wTurnWait],a

.jpDir:
	ld a,e
	and %00001111
	ld [wCarDir],a
	ld b,HIGH(DirJpTbl)
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
	ld a,255
	ld [wCarSpeedY],a
	ld a,1
	ld [wSmokeAddY],a
.set
	jp NextLoop

Dir01:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld a,255
	ld [wCarSpeedY],a
	ld a,1
	ld [wSmokeAddY],a
	ld a,[wCarSpriteY]
	bit 0,a
	jr z,.set
	ld a,1
	ld [wCarSpeedX],a
	ld a,255
	ld [wSmokeAddX],a
.set
	jp NextLoop

Dir02:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld a,1
	ld [wCarSpeedX],a
	ld [wSmokeAddY],a
	ld a,255
	ld [wCarSpeedY],a
	ld [wSmokeAddX],a
.set
	jp NextLoop

Dir03:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld a,1
	ld [wCarSpeedX],a
	ld a,255
	ld [wSmokeAddX],a
	ld a,[wCarSpriteX]
	bit 0,a
	jp z,.set
	ld a,255
	ld [wCarSpeedY],a
	ld a,1
	ld [wSmokeAddY],a
.set
	jp NextLoop

Dir04:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld a,1
	ld [wCarSpeedX],a
	ld a,255
	ld [wSmokeAddX],a
.set
	jp NextLoop

Dir05:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld a,1
	ld [wCarSpeedX],a
	ld a,255
	ld [wSmokeAddX],a
	ld a,[wCarSpriteX]
	bit 0,a
	jp z,.set
	ld a,1
	ld [wCarSpeedY],a
	ld a,255
	ld [wSmokeAddY],a
.set
	jp NextLoop

Dir06:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld a,1
	ld [wCarSpeedY],a
	ld [wCarSpeedX],a
	ld a,255
	ld [wSmokeAddY],a
	ld [wSmokeAddX],a
.set
	jp NextLoop

Dir07:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld a,1
	ld [wCarSpeedY],a
	ld a,255
	ld [wSmokeAddY],a
	ld a,[wCarSpriteY]
	bit 0,a
	jp z,.set
	ld a,1
	ld [wCarSpeedX],a
	ld a,255
	ld [wSmokeAddX],a
.set
	jp NextLoop

Dir08:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld a,1
	ld [wCarSpeedY],a
	ld a,255
	ld [wSmokeAddY],a
.set
	jp NextLoop

Dir09:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld a,1
	ld [wCarSpeedY],a
	ld a,255
	ld [wSmokeAddY],a
	ld a,[wCarSpriteY]
	bit 0,a
	jp z,.set
	ld a,255
	ld [wCarSpeedX],a
	ld a,1
	ld [wSmokeAddX],a
.set
	jp NextLoop

Dir10:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld a,1
	ld [wCarSpeedY],a
	ld [wSmokeAddX],a
	ld a,255
	ld [wCarSpeedX],a
	ld [wSmokeAddY],a
.set
	jp NextLoop

Dir11:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld a,255
	ld [wCarSpeedX],a
	ld a,1
	ld [wSmokeAddX],a
	ld a,[wCarSpriteX]
	bit 0,a
	jp z,.set
	ld a,1
	ld [wCarSpeedY],a
	ld a,255
	ld [wSmokeAddY],a
.set
	jp NextLoop

Dir12:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld a,255
	ld [wCarSpeedX],a
	ld a,1
	ld [wSmokeAddX],a
.set
	jp NextLoop

Dir13:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld a,255
	ld [wCarSpeedX],a
	ld a,1
	ld [wSmokeAddX],a
	ld a,[wCarSpriteX]
	bit 0,a
	jp z,.set
	ld a,255
	ld [wCarSpeedY],a
	ld a,1
	ld [wSmokeAddY],a
.set
	jp NextLoop

Dir14:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld a,255
	ld [wCarSpeedX],a
	ld [wCarSpeedY],a
	ld a,1
	ld [wSmokeAddY],a
	ld [wSmokeAddX],a
.set
	jp NextLoop

Dir15:
	ld a,[wCarSpeed]
	cp 0
	jr z,.set
	ld a,255
	ld [wCarSpeedY],a
	ld a,1
	ld [wSmokeAddY],a
	ld a,[wCarSpriteY]
	bit 0,a
	jp z,.set
	ld a,255
	ld [wCarSpeedX],a
	ld a,1
	ld [wSmokeAddX],a
.set
	;jp NextLoop

NextLoop:
	ld a,[wDriftWait]
	cp 0
	jr nz,.decDriftWait
	jr .skip2

	ld a,[wButton]
	bit JBitButtonA,a
	jr nz,.skip
	xor a
	ld [wDriftWait],a
.skip2
	ld a,[wCarTurn]
	ld [wCarDir],a
	jr .setSprite

.decDriftWait
	dec a
	ld [wDriftWait],a
.skip
	ld a,[wCarTurn]

.setSprite
	rlca
	rlca
	rlca
	ld b,HIGH(CarSpriteTbl)
	ld c,a
	ld hl,wShadowOAM
	mSetCarSprite

SetOAM:
	mWaitVBlank
	mSetOAM

	xor a
	ld [wCarSpeedY],a
	ld [wCarSpeedX],a
	ld [wCarSpeed],a
	jp MainLoop

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