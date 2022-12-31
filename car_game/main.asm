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

Car1StartY        EQU 16+8*4
Car1StartX        EQU 8+8*9
Car1Palette       EQU 0
Car2Palette       EQU 3
Car3Palette       EQU 2
CarDataCnt        EQU 16*1
CarStartDirection EQU 2
CarDirectionMax   EQU 7
CarSpeedMax       EQU 3
CarTurnWait       EQU 5
BGPaletteCnt      EQU 4*2
ObjPaletteCnt     EQU 4*5
SoundDataCnt      EQU 3
ScrollMaxY        EQU 16+8*12
ScrollMaxX        EQU 8+8*11
ScrollAreaYup     EQU 16+8*4
ScrollAreaYdown   EQU 16+8*12
ScrollAreaXleft   EQU 8+8*4
ScrollAreaXright  EQU 8+8*14
ScreenMaxY        EQU 16+8*15
ScreenMaxX        EQU 8+8*17
ScreenMinY        EQU 16+8
ScreenMinX        EQU 8+8

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
	ld [wJoypad],a
	ld [wButton],a
	ld [wCarSpeed],a
	ld [wCarPattern],a
	ld [wEngineSound],a
	ld [wSpriteY],a
	ld [wSpriteX],a
	ld [wSpritePallete],a
	ld [wScrollY],a
	ld [wScrollX],a
	ld [wScrollYflg],a
	ld [wScrollXflg],a
	ld [wSoundTbl],a
	ld [wSoundTbl+1],a
	ld [wSoundWait],a

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
	ld [wCarY],a
	ld a,Car1StartX
	ld [wCarX],a
	ld a,CarTurnWait
	ld [wCarTurnWait],a
	ld a,[CarSpeedUpTbl]
	ld [wCarSpeedUpWait],a
	ld a,[CarSpeedDownTbl]
	ld [wCarSpeedDownWait],a
	ld a,CarStartDirection
	ld [wCarDirection],a
	call SetCarPattern
	call InitSound

	; init light
	ld a,2
	ld [wLightPalette1],a
	ld a,1
	ld [wLightPalette2],a
	ld a,0
	ld [wLightPalette3],a
	ld a,160
	ld [wLightWait],a
	ld a,HIGH(LightPalette)
	ld [wLightPalette],a
	ld a,LOW(LightPalette)
	ld [wLightPalette+1],a

MainLoop:
	call PlaySound
	call ReadingJoypad
	call SetCarMove

	; Car1Sprite
	ld hl,wShadowOAM
	ld a,Car1Palette
	ld [wSpritePallete],a
	ld a,[wCarY]
	ld [wSpriteY],a
	ld a,[wCarX]
	ld [wSpriteX],a

	; adjust scroll position
	ld a,[wScrollY]
	cp ScrollMaxY
	jr c,.setSCY
	cp ScrollMaxY+8
	jr nc,.resetWScrollY
	xor a
	ld [wScrollYflg],a
	ld a,ScrollMaxY
	ld [wScrollY],a
	jr .setSCY
.resetWScrollY
	xor a
	ld [wScrollY],a
	ld [wScrollYflg],a
.setSCY
	ldh [rSCY],a

	ld a,[wScrollX]
	cp ScrollMaxX
	jr c,.setSCX
	cp ScrollMaxX+8
	jr nc,.resetWScrollX
	xor a
	ld [wScrollXflg],a
	ld a,ScrollMaxX
	ld [wScrollX],a
	jr .setSCX
.resetWScrollX
	xor a
	ld [wScrollX],a
	ld [wScrollXflg],a
.setSCX
	ldh [rSCX],a

	ld b,HIGH(CarSpriteTbl)
	ld a,[wCarPattern]
	ld c,a
	call SetCarSprite
	call SetLight

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
	ld a,0
	ld [wCarDirection],a
	ld a,CarTurnWait
	ld [wCarTurnWait],a
	jp SetCarPattern

.turnLeft
	ld a,[wCarTurnWait]
	cp 0
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
	cp 0
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
	cp 0
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
	ld a,[wCarDirection]
	cp 0
	jp z,.setCarMoveUp
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
	ld a,[wCarY]
	cp ScrollAreaYup
	jr c,.setCarUpMoveScroll
	sub a,c
	ld [wCarY],a
	ret

.setCarUpMoveScroll
	ld a,[wScrollY]
	sub a,c
	ld [wScrollY],a

	ld a,[wScrollYflg]
	or 0
	ret nz
	ld a,[wCarY]
	cp ScreenMinY
	ret c
	sub a,c
	ld [wCarY],a
	ret

SetCarDownMove:
	ld c,a
	ld a,[wCarY]
	cp ScrollAreaYdown
	jr nc,.setCarDownMoveScroll
	add a,c
	ld [wCarY],a
	ld a,1
	ld [wScrollYflg],a
	ret

.setCarDownMoveScroll
	ld a,[wScrollY]
	add a,c
	ld [wScrollY],a

	ld a,[wScrollYflg]
	or 0
	ret nz
	ld a,[wCarY]
	cp ScreenMaxY
	ret nc
	add a,c
	ld [wCarY],a
	ret

SetCarRightMove:
	ld c,a
	ld a,[wCarX]
	cp ScrollAreaXright
	jr nc,.setCarRightMoveScroll
	add a,c
	ld [wCarX],a
	ld a,1
	ld [wScrollXflg],a
	ret

.setCarRightMoveScroll
	ld a,[wScrollX]
	add a,c
	ld [wScrollX],a

	ld a,[wScrollXflg]
	or 0
	ret nz
	ld a,[wCarX]
	cp ScreenMaxX
	ret nc
	add a,c
	ld [wCarX],a
	ret

SetCarLeftMove:
	ld c,a
	ld a,[wCarX]
	cp ScrollAreaXleft
	jr c,.setCarLeftMoveScroll
	sub a,c
	ld [wCarX],a
	ret

.setCarLeftMoveScroll
	ld a,[wScrollX]
	sub a,c
	ld [wScrollX],a

	ld a,[wScrollXflg]
	or 0
	ret nz
	ld a,[wCarX]
	cp ScreenMinX
	ret c
	sub a,c
	ld [wCarX],a
	ret

CalcEngineSound:
	ld a,[wEngineSound]
	ld c,a
	ld a,[wCarSpeed]
	cp c
	ret z
	ld [wEngineSound],a
	ld de,SoundTbl
	cp 0
	jp z,SetEngineSound
	ld c,a
.calcEngineSound
	ld a,e
	add a,SoundDataCnt
	ld e,a
	dec c
	ld a,c
	cp 0
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
	ld e,4 ; Sprite pattern count
.setCarSprite
	ld a,[wSpriteY]
	ld d,a
	ld a,[bc]
	add a,d
	ld [hli],a ; Y Position
	inc c
	ld a,[wSpriteX]
	ld d,a
	ld a,[bc]
	add a,d
	ld [hli],a ; X Position
	inc c
	ld a,[bc]
	ld [hli],a ; Tile Index
	inc c
	ld a,[wSpritePallete]
	ld d,a
	ld a,[bc]
	or d ; set palette
	ld [hli],a ; Attributes/Flags
	inc c
	dec e
	jr nz,.setCarSprite
	ret

SetSprite:
	ld a,[wSpriteY]
	ld [hli],a ; Y Position
	ld a,[wSpriteX]
	ld [hli],a ; X Position
	ld a,[wSpriteIndex]
	ld [hli],a ; Tile Index
	ld a,[wSpritePallete]
	ld [hli],a ; Attributes/Flags
	ret

SetLight:
	ld a,[wLightWait]
	dec a
	cp 0
	jr nz,.setLight2
	ld a,[wLightPalette]
	ld b,a
	ld a,[wLightPalette+1]
	ld c,a
	ld a,[bc]
	cp 0
	jr z,.setLight1
	ld [wLightWait],a
	inc bc
	ld a,[bc]
	ld [wLightPalette1],a
	inc bc
	ld a,[bc]
	ld [wLightPalette2],a
	inc bc
	ld a,[bc]
	ld [wLightPalette3],a
	inc bc
	ld a,b
	ld [wLightPalette],a
	ld a,c
	ld [wLightPalette+1],a
	jr .setLight3

.setLight1
	ld a,255
.setLight2
	ld [wLightWait],a
.setLight3
	ld a,16+2
	ld [wSpriteY],a
	ld a,8+8*13+2
	ld [wSpriteX],a
	ld a,26
	ld [wSpriteIndex],a
	ld a,1
	ld [wSpritePallete],a
	call SetSprite
	ld a,25
	ld [wSpriteIndex],a
	ld a,[wLightPalette1]
	ld [wSpritePallete],a
	ld a,16+8*3+4
	ld [wSpriteY],a
	ld a,8+8*13+5
	ld [wSpriteX],a
	call SetSprite
	ld a,[wLightPalette2]
	ld [wSpritePallete],a
	ld a,16+8*4+4
	ld [wSpriteY],a
	call SetSprite
	ld a,[wLightPalette3]
	ld [wSpritePallete],a
	ld a,16+8*5+4
	ld [wSpriteY],a
	call SetSprite
	ld a,16+8*8+6
	ld [wSpriteY],a
	ld a,8+8*13+2
	ld [wSpriteX],a
	ld a,26
	ld [wSpriteIndex],a
	ld a,%01000001
	ld [wSpritePallete],a
	call SetSprite
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

Tiles:
	INCBIN "tiles.bin"
TilesEnd:

BgTileMap0: ; Tile Indexes
	INCBIN "map.bin"
BgTileMapEnd0:

BgTileMap1: ; BG Map Attributes
	;0 0   1   2   3   4   5    6  7   8   9   10  11  12  13  14  15
	db $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	;  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;1
	db $01,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;2
	db $00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;3
	db $00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;4
	db $00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;5
	db $00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;6
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;7
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;8
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;9
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,%01000001,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;10
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;11
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;12
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;14
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;15
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;16
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01
	db $01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;17
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
	db $01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;18
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;19
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;20
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;21
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;22
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;23
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;24
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;25
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;26
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;27
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;28
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;29
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;30
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;31
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
BgTileMapEnd1:

SECTION "Car Sprite Table",ROM0[$3000]
CarSpriteTbl: ; AddY,AddX,Tile Index,Attributes/Flags
	; Upward
	db 0,0,126,%10000000
	db 0,8,126,%10100000
	db 8,0,127,%10000000
	db 8,8,127,%10100000
	; Upward right
	db 0,0,118,%10000000
	db 0,8,117,%10000000
	db 8,0,119,%10000000
	db 8,8,118,%11100000
	; Rightward
	db 0,0,124,%10000000
	db 0,8,125,%10000000
	db 8,0,124,%11000000
	db 8,8,125,%11000000
	; Downward right
	db 0,0,119,%11000000
	db 0,8,118,%10100000
	db 8,0,118,%11000000
	db 8,8,117,%11000000
	; Downward
	db 0,0,127,%11000000
	db 0,8,127,%11100000
	db 8,0,126,%11000000
	db 8,8,126,%11100000
	; Downward left
	db 0,0,118,%10000000
	db 0,8,119,%11100000
	db 8,0,117,%11100000
	db 8,8,118,%11100000
	; Leftward
	db 0,0,125,%10100000
	db 0,8,124,%10100000
	db 8,0,125,%11100000
	db 8,8,124,%11100000
	; Upward left
	db 0,0,117,%10100000
	db 0,8,118,%10100000
	db 8,0,118,%11000000
	db 8,8,119,%10100000

;SECTION "Color Palette",ROM0
BGPalette:
	; 0
	dw 15134
	dw 23391
	dw 10840
	dw 3472
	; 1
	dw 15134
	dw 8456
	dw 24311
	dw 32767

ObjPalette:
	; 0
	dw 15134
	dw 0
	dw 32767
	dw 31
	; 1
	dw 15134
	dw 0
	dw 32767
	dw 1023
	; 2
	dw 15134
	dw 0
	dw 32767
	dw 512
	; 3
	dw 15134
	dw 0
	dw 32767
	dw 31744
	; 4
	dw 0
	dw 0
	dw 0
	dw 32767

LightPalette:
	db 64,2,1,4
	db 64,2,4,0
	db 64,4,1,0
	db 1,2,1,0
	db 0

SECTION "Engine Sound Table",ROM0[$3100]
; ver.04 Wave Output
SoundTbl: ; Output level,Frequency low,Hi
	db %01000000,$60,%10000000
	db %00100000,$A0,%10000000
	db %00100000,$FF,%10000001
	db %00100000,$FF,%10000010

WaveData:
	db $12,$56 ; 1,2,5,6
	db $BC,$DC ; 11,12,13,12
	db $DB,$DD ; 13,11,13,13
	db $CE,$A9 ; 12,14,10,09
	db $76,$65 ; 07,06,06,05
WaveDataEnd:

SECTION "Car SpeedUp Table",ROM0[$3200]
CarSpeedUpTbl: ; Wait
	db 0
	db 20
	db 50
	db 20

SECTION "Car SpeedDown Table",ROM0[$3300]
CarSpeedDownTbl: ; Wait
	db 0
	db 30
	db 50
	db 20

SECTION "Sound Table",ROM0[$3400]
INCLUDE "sound_tbl.inc"

SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

SECTION "State",WRAM0
wJoypad: ds 1
wButton: ds 1
wCarY: ds 1
wCarX: ds 1
wCarSpeed: ds 1
wCarPattern: ds 1
wCarPalette: ds 1
wCarDirection: ds 1
wCarSpeedUpWait: ds 1
wCarSpeedDownWait: ds 1
wCarTurnWait: ds 1
wEngineSound: ds 1
wSpriteY: ds 1
wSpriteX: ds 1
wSpriteIndex: ds 1
wSpritePallete: ds 1
wScrollY: ds 1
wScrollX: ds 1
wScrollYflg: ds 1
wScrollXflg: ds 1
;
wSoundTbl: ds 2
wSoundWait: ds 1
;
wLightWait: ds 1
wLightPalette: ds 2
wLightPalette1: ds 1
wLightPalette2: ds 1
wLightPalette3: ds 1

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to