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

CarStartY         EQU 16+8*8
CarStartX         EQU 8+8*9
CarDataCnt        EQU 16
CarSpeedMax       EQU 3
CarTurnWait       EQU 5
CarDirectionMax   EQU 3
DirectionUpMax    EQU 0
DirectionDownMax  EQU 16+144
DirectionLeftMax  EQU -8
DirectionRightMax EQU 8+160
BGPaletteCnt      EQU 4*1
ObjPaletteCnt     EQU 4*2

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
	ldh [rNR52],a ; disable the audio
	ldh [rSCY],a ; Scroll Y
	ldh [rSCX],a ; Scroll X
	ld [wJoypad],a
	ld [wButton],a
	ld [wCarSpeed],a
	ld [wCarPattern],a
	ld [wCarDirection],a
	ld [wCarSpeedUpWait],a
	ld [wCarSpeedDownWait],a

	; Set Tiles data
	ld hl,_VRAM8000
	ld de,Tiles
	ld bc,TilesEnd - Tiles
	call CopyData

	ld hl,_SCRN0
	ld de,BgTileMap
	ld bc,BgTileMapEnd - BgTileMap
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
	jp .speedDown

.checkJoypad
	ld a,[wJoypad]
	ld c,a
	and %00000001 ; Right
	jr nz,.turnRight
	ld a,c
	and %00000010 ; Left
	jr nz,.turnLeft
	;
	;and %00001000 ; Up
	;jr nz,
	;ld a,c
	;and %00000100 ; Down
	;jr nz,
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
	jr SetCarPattern

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
	jr .checkJoypad
.speedUpWait
	dec a
	ld [wCarSpeedUpWait],a
	jp .checkJoypad
.speedDown
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
	xor a
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
	cp c
	jr nc,.setCarMoveUp1
	ld a,DirectionDownMax
	ld [wCarY],a
	ret
.setCarMoveUp1
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
	cp DirectionRightMax
	jr c,.setCarMoveRight1
	cp DirectionLeftMax
	jr nc,.setCarMoveRight1
	ld a,DirectionLeftMax
	ld [wCarX],a
	ret
.setCarMoveRight1
	ld [wCarX],a
	ret
.setCarMoveDown
	ld a,[wCarSpeed]
	cp 0
	ret z
	ld c,a
	ld a,[wCarY]
	add a,c
	cp DirectionDownMax
	jr c,.setCarMoveDown1
	ld a,DirectionUpMax
	ld [wCarY],a
	ret
.setCarMoveDown1
	ld [wCarY],a
	ret
.setCarMoveLeft
	ld a,[wCarSpeed]
	cp 0
	ret z
	ld c,a
	ld a,[wCarX]
	sub a,c
	cp DirectionLeftMax
	jr nc,.setCarMoveLeft1
	ld [wCarX],a
	ret
.setCarMoveLeft1
	ld a,DirectionRightMax
	ld [wCarX],a
	ret

SetCarSprite:
	ld hl,wShadowOAM
	ld b,HIGH(CarSpriteTbl)
	ld a,[wCarPattern]
	ld c,a
	ld e,4 ; Sprite Table Count
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

BgTileMap:
	INCBIN "map.bin"
BgTileMapEnd:

SECTION "Color Palette",ROM0[$3000]
BGPalette:
	; Gameboy Color palette 0
	dw 15134
	dw 0
	dw 32767
	dw 31

ObjPalette:
	; Gameboy Color palette 0
	dw 15134
	dw 0
	dw 32767
	dw 31
	; Gameboy Color palette 1
	dw 0
	dw 32767
	dw 15134
	dw 31

SECTION "Car Sprite Table",ROM0[$3100]
CarSpriteTbl: ; AddY,AddX,Tile Index,Attributes/Flags
	; Upward
	db 0,0, 4,%00000000
	db 0,8, 4,%00100000
	db 8,0, 5,%00000000
	db 8,8, 5,%00100000
	; Rightward
	db 0,0, 8,%00000000
	db 0,8,10,%00000000
	db 8,0, 8,%01000000
	db 8,8,10,%01000000
	; Downward
	db 0,0, 5,%01000000
	db 0,8, 5,%01100000
	db 8,0, 4,%01000000
	db 8,8, 4,%01100000
	; Leftward
	db 0,0,10,%00100000
	db 0,8, 8,%00100000
	db 8,0,10,%01100000
	db 8,8, 8,%01100000

SECTION "Car SpeedUp Table1",ROM0[$3200]
CarSpeedUpTbl: ; Wait
	db 0
	db 120
	db 80
	db 20
	db 80

SECTION "Car SpeedDown Table1",ROM0[$3300]
CarSpeedDownTbl: ; Wait
	db 0
	db 120
	db 80
	db 20
	db 0

SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

SECTION "State",WRAM0[$C100]
wJoypad: ds 1
wButton: ds 1
;
wCarY: ds 1
wCarX: ds 1
wCarPattern: ds 1
wCarDirection: ds 1
wCarSpeed: ds 1
wCarSpeedUpWait: ds 1
wCarSpeedDownWait: ds 1
wCarTurnWait: ds 1

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to