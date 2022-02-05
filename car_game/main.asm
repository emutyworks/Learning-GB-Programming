;
; I used this Website/Document as a reference to create "main.asm".
;
; Lesson P21 - Sound on the Gameboy and GBC
; https://www.chibiakumas.com/z80/platform3.php#LessonP21
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

CarStartY         EQU 16+8*16
CarStartX         EQU 8+8*2
CarDataCnt        EQU 16*2
CarSpeedMax       EQU 3
CarTurnWait       EQU 5
CarDirectionMax   EQU 3
BGPaletteCnt      EQU 4*3
ObjPaletteCnt     EQU 4*1
;SoundDataCnt      EQU 5 ; ver.03 Tone & Sweep
SoundDataCnt      EQU 3 ; ver.04 Wave Output

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
	ldh [rSCY],a ; Scroll Y
	ldh [rSCX],a ; Scroll X
	ld [wJoypad],a
	ld [wButton],a
	ld [wCarSpeed],a
	ld [wCarPattern],a
	ld [wCarDirection],a
	ld [wEngineSound],a

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
	ld a,CarStartY
	ld [wCarY],a
	ld a,CarStartX
	ld [wCarX],a
	ld a,CarTurnWait
	ld [wCarTurnWait],a
	ld a,[CarSpeedUpTbl]
	ld [wCarSpeedUpWait],a
	ld a,[CarSpeedDownTbl]
	ld [wCarSpeedDownWait],a

	; Set Sound
	ld a,%00010001 ; -LLL-RRR Channel volume
	ldh [$FF24],a
	ld a,%11111111 ; Channel Sound output terminal
	ldh [$FF25],a
	ld a,%10000000 ; Sound on/off
	ldh [$FF26],a

	; Set Wave Data
	ld hl,$FF30
	ld de,WaveData
	ld bc,WaveDataEnd - WaveData
	call CopyData

	ld a,%10000000 ; Wave Output on/off
	ldh [$FF1A],a
	ld a,$FF ; Sound Length
	ldh [$FF1B],a
	ld de,SoundTbl
	call SetEngineSound

MainLoop:
	call ReadingJoypad
	call SetCarMove
	call SetCarSprite
	call SetOAM
	jr MainLoop

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
	call CalcEngineSound
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
	jr z,.setCarMoveUp
	cp 1
	jr z,.setCarMoveRight
	cp 2
	jr z,.setCarMoveDown
	cp 3
	jr z,.setCarMoveLeft
	ret

.setCarMoveUp
	ld a,[wCarSpeed]
	cp 0
	ret z
	ld c,a
	ld a,[wCarY]
	sub a,c
	ld [wCarY],a
	ret

.setCarMoveRight
	ld a,[wCarSpeed]
	cp 0
	ret z
	ld c,a
	ld a,[wCarX]
	add a,c
	ld [wCarX],a
	ret

.setCarMoveDown
	ld a,[wCarSpeed]
	cp 0
	ret z
	ld c,a
	ld a,[wCarY]
	add a,c
	ld [wCarY],a
	ret

.setCarMoveLeft
	ld a,[wCarSpeed]
	cp 0
	ret z
	ld c,a
	ld a,[wCarX]
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
	ld d,HIGH(SoundTbl)
	ld e,0
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

;SetEngineSound: ; ver.03 Tone & Sweep
;	ld a,[wEngineSound]
;	ld c,a
;	ld a,[wCarSpeed]
;	cp c
;	ret z
;	ld [wEngineSound],a
;	ld d,HIGH(SoundTbl)
;	ld e,0
;	cp 0
;	jp z,.setEngineSound
;	ld c,a
;.setEngineSoundLoop
;	ld a,e
;	add a,SoundDataCnt
;	ld e,a
;	dec c
;	ld a,c
;	cp 0
;	jr nz,.setEngineSoundLoop
;	ld a,e
;.setEngineSound
;	ld b,$FF
;	ld c,$10
;	ld a,[de]
;	ldh [c],a ; $FF10 Sweep register
;	inc de
;	inc c
;	ld a,[de]
;	ldh [c],a ; $FF11 Sound length/Wave pattern duty
;	inc de
;	inc c
;	ld a,[de]
;	ldh [c],a ; $FF12 Volume Envelope
;	inc de
;	inc c
;	ld a,[de]
;	ldh [c],a ; $FF13 Frequency low
;	inc de
;	inc c
;	ld a,[de]
;	ldh [c],a ; $FF14 Frequency hi
;	ret

SetCarSprite:
	ld hl,wShadowOAM
	ld b,HIGH(CarSpriteTbl)
	ld a,[wCarPattern]
	ld c,a
	ld e,8 ; Sprite Table Count
.setCarSprite
	ld a,[wCarY]
	ld d,a
	ld a,[bc]
	add a,d
	ld [hli],a ; Y Position
	inc c
	ld a,[wCarX]
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

Tiles:
	INCBIN "tiles.bin"
TilesEnd:

BgTileMap0: ; Tile Indexes
	INCBIN "map.bin"
BgTileMapEnd0:

BgTileMap1: ; BG Map Attributes
	;0 0   1   2   3   4   5    6  7   8   9   10  11  12  13  14  15
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;1
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;2
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;3
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;4
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;5
	db $00,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;6
	db $00,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;7
	db $00,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;8
	db $00,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;9
	db $00,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;10
	db $00,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;11
	db $00,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;12
	db $00,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;13
	db $00,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;14
	db $00,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;15
	db $00,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;16
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  ;17
	db $00,$00,$00,$00,$00,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
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
	db 0,0,116,%00000000
	db 0,8,116,%00100000
	db 8,0,117,%00000000
	db 8,8,117,%00100000
	db 0,0,126,%10000000
	db 0,8,126,%10100000
	db 8,0,127,%10000000
	db 8,8,127,%10100000
	; Rightward
	db 0,0,120,%00000000
	db 0,8,121,%00000000
	db 8,0,120,%01000000
	db 8,8,121,%01000000
	db 0,0,124,%10000000
	db 0,8,125,%10000000
	db 8,0,124,%11000000
	db 8,8,125,%11000000
	; Downward
	db 0,0,117,%01000000
	db 0,8,117,%01100000
	db 8,0,116,%01000000
	db 8,8,116,%01100000
	db 0,0,127,%11000000
	db 0,8,127,%11100000
	db 8,0,126,%11000000
	db 8,8,126,%11100000
	; Leftward
	db 0,0,121,%00100000
	db 0,8,120,%00100000
	db 8,0,121,%01100000
	db 8,8,120,%01100000
	db 0,0,125,%10100000
	db 0,8,124,%10100000
	db 8,0,125,%11100000
	db 8,8,124,%11100000

	; Upper right
	db 0,0,120,%00000000
	db 0,8,122,%00000000
	db 8,0,121,%00000000
	db 8,8,123,%00000000
	; lower right
	db 0,0,121,%01000000
	db 0,8,123,%01000000
	db 8,0,120,%01000000
	db 8,8,122,%01000000
	; lower left
	db 0,0,123,%01100000
	db 0,8,121,%01100000
	db 8,0,122,%01100000
	db 8,8,120,%01100000
	; Upper left
	db 0,0,122,%00100000
	db 0,8,120,%00100000
	db 8,0,123,%00100000
	db 8,8,121,%00100000

SECTION "Color Palette",ROM0
BGPalette:
	; Gameboy Color palette 0
	dw 15134
	dw 23391
	dw 10840
	dw 3472
	; Gameboy Color palette 1
	dw 15134
	dw 0
	dw 32767
	dw 31
	; Gameboy Color palette 2
	dw 15134
	dw 8456
	dw 24311
	dw 32767

ObjPalette:
	; Gameboy Color palette 0
	dw 15134
	dw 0
	dw 32767
	dw 31

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

; ver.03 Tone & Sweep
;SoundTbl: ;Sweep,Wave pattern duty,Envelope,Frequency low,Hi
;	db %01111111,%00000000,%11110000,$00,%10000000
;	db %01110011,%00000000,%11110000,$00,%10000001
;	db %01110000,%00000000,%11110000,$00,%10000010
;	db %01110000,%00000000,%11110000,$FF,%10000011

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

SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

SECTION "State",WRAM0
wJoypad: ds 1
wButton: ds 1
;
wCarY: ds 1
wCarX: ds 1
wCarSpeed: ds 1
wCarPattern: ds 1
wCarDirection: ds 1
wCarSpeedUpWait: ds 1
wCarSpeedDownWait: ds 1
wCarTurnWait: ds 1
wEngineSound: ds 1

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to