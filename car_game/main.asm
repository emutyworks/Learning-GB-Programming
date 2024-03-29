;
; I used this Website/Document as a reference to create "main.asm".
;
; Lesson P21 - Sound on the Gameboy and GBC
; https://www.chibiakumas.com/z80/platform3.php#LessonP21
; https://www.youtube.com/watch?v=LCPLGkYJk5M
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
INCLUDE "sound_equ.inc"
INCLUDE "equ.inc"

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

	; Set BG Palette
	ld a,%10000000 ; Palette 0, Auto increment after writing
	ld [rBCPS],a
	ld c,BGPaletteCnt
	ld hl,BGPalette
	ld de,rBCPD
	call SetPalette

	; Set Object Palette
	ld a,%10000000
	ld [rOCPS],a
	ld c,ObjPaletteCnt
	ld hl,ObjPalette
	ld de,rOCPD
	call SetPalette

	xor a
	ldh [rLCDC],a
	ldh [rIE],a
	ldh [rIF],a
	ldh [rSTAT],a
	ldh [rSCY],a
	ldh [rSCX],a
	ld [wNextSCY],a
	ld [wNextSCX],a
	ld [wJoypad],a
	ld [wButton],a
	ld [wCarSpeed],a
	ld [wCarPattern],a
	ld [wEngineSound],a
	ld [wSoundTbl],a
	ld [wSoundTbl+1],a

	ld hl,wLightPalette
	ld [hl],HIGH(LightPalette)
	inc hl
	ld [hl],LOW(LightPalette)

	; Set Tiles data
	ld hl,_VRAM8000
	ld de,Tiles
	ld bc,TilesEnd - Tiles
	call CopyData

	; Set Map data
	ld a,1
	ldh [rVBK],a ; BG Map Attributes
	ld hl,_SCRN0
	ld de,BgTileMap1
	ld bc,BgTileMapEnd1 - BgTileMap1
	call CopyData
	xor a
	ldh [rVBK],a ; Tile Indexes
	ld hl,_SCRN0
	ld de,BgTileMap0
	ld bc,BgTileMapEnd0 - BgTileMap0
	call CopyData

	; Turn screen on, display background
	ld a,LCDCF_ON|LCDCF_BG8000|LCDCF_OBJON|LCDCF_BGON
	ldh [rLCDC],a

	call InitwShadowOAM

	; Set Car
	ld a,Car1StartY
	ld [wPosY],a
	ld [wNextPosY],a
	ld a,Car1StartX
	ld [wPosX],a
	ld [wNextPosX],a
	ld a,CarTurnWait
	ld [wCarTurnWait],a
	ld a,[CarSpeedUpTbl]
	ld [wCarSpeedUpWait],a
	ld a,[CarSpeedDownTbl]
	ld [wCarSpeedDownWait],a
	ld a,2
	ld [wCarDirection],a
	call SetCarPattern

	; Init OAM Table
	ld bc,InitOamTbl
	ld hl,wShadowOAM
	ld d,OamTblCnt
.initOAMTable
	ld a,[bc]
	ld [hli],a
	inc c
	dec d
	jr nz,.initOAMTable

	ld bc,InitOamTbl
	ld hl,wOAMPosition
	ld d,OamTblCnt
.initOAMTable2
	ld a,[bc]
	ld [hli],a
	inc c
	dec d
	ld a,[bc]
	ld [hli],a
	inc c
	dec d
	inc c
	dec d
	inc c
	dec d
	jr nz,.initOAMTable2

	; Set Sound
	ld hl,wSoundTbl
	ld [hl],HIGH(Sound01Tbl)
	inc hl
	ld [hl],LOW(Sound01Tbl)
	call InitSound

	; Set Loop Flg
	ld a,LoopSound
	ld [wLoopFlg],a

MainLoop:
	ld a,[wLoopFlg]
	and LoopSound
	call nz,PlaySound

	call ReadingJoypad
	call SetCarMove
	call CheckCollisionMap

	ld b,HIGH(CarSpriteTbl)
	ld a,[wCarPattern]
	ld c,a
	call SetCarSprite

	; Adjust OAM Scroll Position
	ld bc,wOAMPosition
	ld hl,wShadowOAM
	ld e,OAMPositionCnt
.adjustOAMScrollPosition
	ldh a,[rSCY]
	ld d,a
	ld a,[bc]
	sub d
	ld [hli],a ; Y Position
	inc c
	ldh a,[rSCX]
	ld d,a
	ld a,[bc]
	sub d
	ld [hli],a ; X Position
	inc c
	inc l
	inc l
	dec e
	jr nz,.adjustOAMScrollPosition

.mainLoop1
	call SetOAM
	jp MainLoop

ReadingJoypad:
	ld a,P1F_4
	ld [rP1],a ; select P14
	ld a,[rP1]
	ldh a,[rP1] ; Wait a few cycles.
	cpl ; A xor FF
	and %00001111 ; Get only first 4 bits.
	ld [wButton],a
	ld a,P1F_5
	ld [rP1],a ; select P15
	ldh a,[rP1]
	ldh a,[rP1]
	ldh a,[rP1]
	ldh a,[rP1]
	ldh a,[rP1]
	ldh a,[rP1] ; Wait a few MORE cycles.
	cpl
	and %00001111
	ld [wJoypad],a
	ld a,%11000000 ; Deselect P14 and P15.
	ld [rP1],a
	
	; Car Speed
	ld a,[wButton]
	and %00000001
	jr nz,.speedUp
	ld a,[CarSpeedUpTbl]
	ld [wCarSpeedUpWait],a
	jp .speedDown

.checkJoypad
	ld a,[wJoypad]
	ld c,a
	and %00000001 ; Right
	jr nz,.turnRight
	ld a,c
	and %00000010 ; Left
	jr nz,.turnLeft
	ret

.turnRight
	ld a,[wCarTurnWait]
	cp 0
	jr nz,.turnWaitDec
	ld a,[wCarDirection]
	cp CarDirectionMax
	jr z,.turnRight1
	inc a
	ld [wCarDirection],a
	ld a,CarTurnWait
	ld [wCarTurnWait],a
	jp SetCarPattern
.turnRight1
	xor a
	ld [wCarDirection],a
	ld a,CarTurnWait
	ld [wCarTurnWait],a
	jp SetCarPattern

.turnLeft
	ld a,[wCarTurnWait]
	or a
	jr nz,.turnWaitDec
	ld a,[wCarDirection]
	cp 0
	jr z,.turnLeft1
	dec a
	ld [wCarDirection],a
	ld a,CarTurnWait
	ld [wCarTurnWait],a
	jr SetCarPattern
.turnLeft1
	ld a,CarDirectionMax
	ld [wCarDirection],a
	ld a,CarTurnWait
	ld [wCarTurnWait],a
	jr SetCarPattern

.turnWaitDec
	dec a
	ld [wCarTurnWait],a
	ret

.speedUp
	;call CalcEngineSound
	ld a,[wCarSpeed]
	cp CarSpeedMax
	jr z,.checkJoypad
	ld c,a
	ld a,[wCarSpeedUpWait]
	or a
	jr nz,.speedUpWait
	inc c
	ld a,c
	ld [wCarSpeed],a
	ld b,HIGH(CarSpeedUpTbl)
	ld a,[bc]
	ld [wCarSpeedUpWait],a
	ld [wCarSpeedDownWait],a
	jp .checkJoypad
.speedUpWait
	dec a
	ld [wCarSpeedUpWait],a
	jp .checkJoypad
.speedDown
	call CalcEngineSound
	ld a,[wCarSpeed]
	cp 0
	jp z,.checkJoypad
	ld c,a
	ld a,[wCarSpeedDownWait]
	or a
	jr nz,.speedDownWait
	dec c
	ld a,c
	ld [wCarSpeed],a
	ld b,HIGH(CarSpeedDownTbl)
	ld a,[bc]
	ld [wCarSpeedDownWait],a
	ld a,[CarSpeedUpTbl]
	ld [wCarSpeedUpWait],a
	jp .checkJoypad
.speedDownWait
	dec a
	ld [wCarSpeedDownWait],a
	jp .checkJoypad

SetCarPattern:
	ld a,[wCarDirection]
	cp 0
	jr z,.setCarPattern1
	ld c,a
	ld a,CarDataCnt
.setCarPatternLoop
	dec c
	jr z,.setCarPattern2
	add a,CarDataCnt
	jr .setCarPatternLoop
.setCarPattern1
	xor a
.setCarPattern2
	ld [wCarPattern],a
	ret

SetCarMove:
	ld a,[wCarDirection] ; 701
	or a                 ; 6 2
	jp z,.setCarMoveUp   ; 543
	cp 1
	jp z,.setCarMoveUpRight
	cp 2
	jp z,.setCarMoveRight
	cp 3
	jp z,.setCarMoveDownRight
	cp 4
	jp z,.setCarMoveDown
	cp 5
	jp z,.setCarMoveDownLeft
	cp 6
	jp z,.setCarMoveLeft
	cp 7
	jp z,.setCarMoveUpLeft
	ret

.setCarMoveUp
	ld a,[wCarSpeed]
	cp 0
	ret z
	call SetCarUpMove
	ret

.setCarMoveUpRight
	ld a,[wCarSpeed]
	cp 0
	ret z
	call SetCarUpMove
	ld a,[wCarSpeed]
	call SetCarRightMove
	ret

.setCarMoveRight
	ld a,[wCarSpeed]
	cp 0
	ret z
	call SetCarRightMove
	ret

.setCarMoveDownRight
	ld a,[wCarSpeed]
	cp 0
	ret z
	call SetCarDownMove
	ld a,[wCarSpeed]
	call SetCarRightMove
	ret

.setCarMoveDown
	ld a,[wCarSpeed]
	cp 0
	ret z
	call SetCarDownMove
	ret

.setCarMoveDownLeft
	ld a,[wCarSpeed]
	cp 0
	ret z
	call SetCarDownMove
	ld a,[wCarSpeed]
	call SetCarLeftMove
	ret

.setCarMoveLeft
	ld a,[wCarSpeed]
	cp 0
	ret z
	call SetCarLeftMove
	ret

.setCarMoveUpLeft
	ld a,[wCarSpeed]
	cp 0
	ret z
	call SetCarUpMove
	ld a,[wCarSpeed]
	call SetCarLeftMove
	ret

SetCarUpMove:
	ld c,a
	ld a,[wPosY]
	cp ScrollAreaYup
	jr c,.setCarUpMoveScroll
	sub a,c
	ld [wNextPosY],a
	ret

.setCarUpMoveScroll
	ldh a,[rSCY]
	sub a,c
	ld [wNextSCY],a

	ld a,[wPosY]
	cp ScreenMinY
	ret c
	sub a,c
	ld [wNextPosY],a
	ret

SetCarDownMove:
	ld c,a
	ld a,[wPosY]
	cp ScrollAreaYdown
	jr nc,.setCarDownMoveScroll
	add a,c
	ld [wNextPosY],a
	ret

.setCarDownMoveScroll
	ldh a,[rSCY]
	add a,c
	ld [wNextSCY],a

	ld a,[wPosY]
	cp ScreenMaxY
	ret nc
	add a,c
	ld [wNextPosY],a
	ret

SetCarRightMove:
	ld c,a
	ld a,[wPosX]
	cp ScrollAreaXright
	jr nc,.setCarRightMoveScroll
	add a,c
	ld [wNextPosX],a
	ret

.setCarRightMoveScroll
	ldh a,[rSCX]
	add a,c
	ld [wNextSCX],a

	ld a,[wPosX]
	cp ScreenMaxX
	ret nc
	add a,c
	ld [wNextPosX],a
	ret

SetCarLeftMove:
	ld c,a
	ld a,[wPosX]
	cp ScrollAreaXleft
	jr c,.setCarLeftMoveScroll
	sub a,c
	ld [wNextPosX],a
	ret

.setCarLeftMoveScroll
	ldh a,[rSCX]
	sub a,c
	ld [wNextSCX],a

	ld a,[wPosX]
	cp ScreenMinX
	ret c
	sub a,c
	ld [wNextPosX],a
	ret

CheckCollisionMap:
	ld a,[wCarDirection]     ; 701
	or a                     ; 6 2
	jp z,.checkCollisionMap0 ; 543
	cp 1
	jp z,.checkCollisionMap1
	cp 2
	jp z,.checkCollisionMap2
	cp 3
	jp z,.checkCollisionMap3
	cp 4
	jp z,.checkCollisionMap4
	cp 5
	jp z,.checkCollisionMap5
	cp 6
	jp z,.checkCollisionMap6
	cp 7
	jp z,.checkCollisionMap7
	ret

.calcCollisionMap
	and %11111000
	rrca
	rrca
	ld d,a
	and %11110000
	swap a
	add a,HIGH(CollisionMap)
	ld h,a
	ld a,d
	and %00001111
	swap a
	ld l,a
	;
	ld a,[wCollisionX]
	and %11111000
	rrca
	rrca
	rrca
	add a,l
	ld l,a
	ld a,[hl]
	ret

.checkCollisionMap0
	ld a,[wNextPosX]
	ld d,a
	ld a,[wNextSCX]
	add a,d
	ld [wCollisionX],a
	ld a,[wNextSCY]
	ld d,a
	ld a,[wNextPosY]
	add a,d
	ld [wCollisionY],a
	call .calcCollisionMap
	or a
	jp nz,.checkCollisionMap01
	ld a,[wCollisionX]
	add a,CarCollisionAdd
	ld [wCollisionX],a
	ld a,[wCollisionY]
	call .calcCollisionMap
	or a
	jp z,.checkCollisionMap
.checkCollisionMap01
	ld a,[wNextPosY]
	add CarCollision
	ld [wNextPosY],a
	jp .checkCollisionMap

.checkCollisionMap1
	ld a,[wNextPosX]
	ld d,a
	ld a,[wNextSCX]
	add a,d
	add a,CarCollisionAdd
	ld [wCollisionX],a
	ld a,[wNextSCY]
	ld d,a
	ld a,[wNextPosY]
	add a,d
	ld [wCollisionY],a
	call .calcCollisionMap
	or a
	jp nz,.checkCollisionMap11
	ld a,[wCollisionY]
	add a,CarCollisionAdd
	call .calcCollisionMap
	or a
	jp z,.checkCollisionMap
.checkCollisionMap11
	ld a,[wNextPosY]
	add CarCollision
	ld [wNextPosY],a
	ld a,[wNextPosX]
	sub CarCollision
	ld [wNextPosX],a
	jp .checkCollisionMap

.checkCollisionMap2
	ld a,[wNextPosX]
	ld d,a
	ld a,[wNextSCX]
	add a,d
	add a,CarCollisionAdd
	ld [wCollisionX],a
	ld a,[wNextSCY]
	ld d,a
	ld a,[wNextPosY]
	add a,d
	ld [wCollisionY],a
	call .calcCollisionMap
	or a
	jp nz,.checkCollisionMap21
	ld a,[wCollisionY]
	add a,CarCollisionAdd
	call .calcCollisionMap
	or a
	jp z,.checkCollisionMap
.checkCollisionMap21
	ld a,[wNextPosX]
	sub CarCollision
	ld [wNextPosX],a
	jp .checkCollisionMap

.checkCollisionMap3
	ld a,[wNextPosX]
	ld d,a
	ld a,[wNextSCX]
	add a,d
	add a,CarCollisionAdd
	ld [wCollisionX],a
	ld a,[wNextSCY]
	ld d,a
	ld a,[wNextPosY]
	add a,d
	add a,CarCollisionAdd
	ld [wCollisionY],a
	call .calcCollisionMap
	or a
	jp z,.checkCollisionMap
.checkCollisionMap31
	ld a,[wNextPosY]
	sub CarCollision
	ld [wNextPosY],a
	ld a,[wNextPosX]
	sub CarCollision
	ld [wNextPosX],a
	jp .checkCollisionMap

.checkCollisionMap4
	ld a,[wNextPosX]
	ld d,a
	ld a,[wNextSCX]
	add a,d
	ld [wCollisionX],a
	ld a,[wNextSCY]
	ld d,a
	ld a,[wNextPosY]
	add a,d
	add a,CarCollisionAdd
	ld [wCollisionY],a
	call .calcCollisionMap
	or a
	jp nz,.checkCollisionMap41
	ld a,[wCollisionX]
	add a,CarCollisionAdd
	ld [wCollisionX],a
	ld a,[wCollisionY]
	call .calcCollisionMap
	or a
	jp z,.checkCollisionMap
.checkCollisionMap41
	ld a,[wNextPosY]
	sub CarCollision
	ld [wNextPosY],a
	jp .checkCollisionMap

.checkCollisionMap5
	ld a,[wNextPosX]
	ld d,a
	ld a,[wNextSCX]
	add a,d
	ld [wCollisionX],a
	ld a,[wNextSCY]
	ld d,a
	ld a,[wNextPosY]
	add a,d
	add a,CarCollisionAdd
	ld [wCollisionY],a
	call .calcCollisionMap
	or a
	jp nz,.checkCollisionMap51
	ld a,[wCollisionX]
	add a,CarCollisionAdd
	ld [wCollisionX],a
	ld a,[wCollisionY]
	call .calcCollisionMap
	or a
	jp z,.checkCollisionMap
.checkCollisionMap51
	ld a,[wNextPosY]
	sub CarCollision
	ld [wNextPosY],a
	ld a,[wNextPosX]
	add CarCollision
	ld [wNextPosX],a
	jp .checkCollisionMap

.checkCollisionMap6
	ld a,[wNextPosX]
	ld d,a
	ld a,[wNextSCX]
	add a,d
	ld [wCollisionX],a
	ld a,[wNextSCY]
	ld d,a
	ld a,[wNextPosY]
	add a,d
	ld [wCollisionY],a
	call .calcCollisionMap
	or a
	jp nz,.checkCollisionMap61
	ld a,[wCollisionY]
	add a,CarCollisionAdd
	call .calcCollisionMap
	or a
	jp z,.checkCollisionMap
.checkCollisionMap61
	ld a,[wNextPosX]
	add CarCollision
	ld [wNextPosX],a
	jp .checkCollisionMap

.checkCollisionMap7
	ld a,[wNextPosX]
	ld d,a
	ld a,[wNextSCX]
	add a,d
	ld [wCollisionX],a
	ld a,[wNextSCY]
	ld d,a
	ld a,[wNextPosY]
	add a,d
	ld [wCollisionY],a
	call .calcCollisionMap
	or a
	jp nz,.checkCollisionMap71
	ld a,[wCollisionX]
	add a,CarCollisionAdd
	ld [wCollisionX],a
	ld a,[wCollisionY]
	call .calcCollisionMap
	or a
	jp z,.checkCollisionMap
.checkCollisionMap71
	ld a,[wNextPosY]
	add CarCollision
	ld [wNextPosY],a
	ld a,[wNextPosX]
	add CarCollision
	ld [wNextPosX],a
	jp .checkCollisionMap

.checkCollisionMap
	ld a,[wNextPosY]
	ld [wPosY],a
	ld a,[wNextPosX]
	ld [wPosX],a
	ld a,[wNextSCY]
	ldh [rSCY],a
	ld a,[wNextSCX]
	ldh [rSCX],a
	ret

CalcEngineSound:
	ld a,[wEngineSound]
	ld c,a
	ld a,[wCarSpeed]
	cp c
	ret z
	ld [wEngineSound],a
	ld de,SoundTbl
	or a
	jp z,SetEngineSound
	ld c,a
.calcEngineSound
	ld a,e
	add a,SoundDataCnt
	ld e,a
	dec c
	ld a,c
	or a
	jr nz,.calcEngineSound
SetEngineSound: ; ver.04 Wave Output
	ld b,$FF
	ld c,$1C
	ld a,[de]
	ldh [c],a ; $FF1C ; Output level
	inc e
	inc c
	ld a,[de]
	ldh [c],a ; $FF1D ; Frequency low
	inc e
	inc c
	ld a,[de]
	ldh [c],a ; $FF1E ; Frequency hi
	ret

SetCarSprite:
	ld h,HIGH(wShadowOAM)
	ld l,Car1S
	ld e,4 ; Sprite pattern count
.setCarSprite
	ld a,[wPosY]
	ld d,a
	ld a,[bc]
	add a,d
	ld [hli],a ; Y Position
	inc c
	ld a,[wPosX]
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
	jr nz,.setCarSprite
	ret

SetLightPalette:
	ld a,[wLightPalette]
	ld b,a
	ld a,[wLightPalette+1]
	ld c,a
	ld h,HIGH(wShadowOAM)
	ld l,Light1SA
	ld a,[bc]
	ld [hl],a
	inc bc
	ld l,Light2SA
	ld a,[bc]
	ld [hl],a
	inc bc
	ld l,Light3SA
	ld a,[bc]
	ld [hl],a
	inc bc
	ld hl,wLightPalette
	ld [hl],b
	inc hl
	ld [hl],c
	ret

SetPalette:
	ld a,[hli]
	ld [de],a
	ld a,[hli]
	ld [de],a
	dec c
	jr nz,SetPalette
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
	ld c,4*40
	xor a
.initwShadowOAM
	ld [hli],a
	dec c
	jr nz,.initwShadowOAM
	ret

INCLUDE "sound_asm.inc"
INCLUDE "data.inc"
INCLUDE "wram.inc"