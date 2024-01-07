;
; I used this Website/Document as a reference to create it.
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
INCLUDE "equ.inc"
INCLUDE "macro.inc"

SECTION "VBlank Handler",ROM0[$40]
  push af
  ld a,1
  ld [wVBlankDone],a
  pop af
  reti

SECTION "Header",ROM0[$100]

EntryPoint:
  di
  jr Start

REPT $150 - $104
  db 0
ENDR

SECTION "Start",ROM0[$150]

Start:
  mCopyDMARoutine ; move DMA subroutine to HRAM
  call WaitVBlank

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
  ld [wPosY],a
  ld [wPosX],a
  ld [wHex],a
  ld [wAttr],a
  ld [wJoypad],a
  ld [wJoyPadPos],a
  ld [wJoypadWait],a
  ld [wVBlankDone],a
  ld [wMainLoopFlg],a

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

  ld a,LCDCF_ON|LCDCF_OBJON|LCDCF_BGON
  ldh [rLCDC],a

  mInitwShadowOAM

  ld a,STATF_LYC|STATF_MODE00
  ldh [rSTAT],a

  ld a,IEF_VBLANK
  ldh [rIE],a
  xor a
  ei
  ldh [rIF],a

  ; Set Sound value
  ld a,$3f
  ld [wLengthTimer],a
  ld [wFF20],a
  ld a,$0f
  ld [wVolume],a
  ld a,1
  ld [wSweep],a
  ld a,%11110001
  ld [wFF21],a
  xor a
  ld [wEnv],a
  ld [wShift],a
  ld [wLFSR],a
  ld [wDivider],a
  ld [wFF22],a

  ;Init audio registers
  ld a,%10000000
  ldh [rAUDENA],a    ; All sound on/off
  ldh [rAUD3ENA],a   ; Sound on/off
  ld a,%01110111
  ldh [rAUDVOL],a    ; -LLL-RRR Output level
  ld a,%11111111
  ldh [rAUDTERM],a   ; Sound output terminal
  ld a,%00111111
  ldh [rAUD4LEN],a   ;Sound length
  xor a
  ldh [rAUD4ENV],a

MainLoop:
  ld a,[wMainLoopFlg]
  cp 1
  jp z,SetOAM

  ld a,[wJoypadWait]
  cp 0
  jr z,.resetWait
  dec a
  ld [wJoypadWait],a
  jp ViewSoundValue
.resetWait
  ld a,JoypadWait
  ld [wJoypadWait],a

  mCheckJoypad

  ld a,[wJoypad]
  bit JBitButtonA,a
  jr nz,.playSound
  bit JBitButtonB,a
  jr nz,.stopSound
  bit JBitUp,a
  jr nz,.jUp
  bit JBitDown,a
  jr nz,.jDown
  bit JBitRight,a
  and %00000011
  jr nz,SetSoundValue
  jp ViewSoundValue

.stopSound
  xor a
  ldh [rAUD4ENV],a
  jp ViewSoundValue
.jUp
  ld a,[wJoyPadPos]
  dec a
  cp $ff
  jr z,.setPos
  ld [wJoyPadPos],a
  jp ViewSoundValue
.jDown
  ld a,[wJoyPadPos]
  inc a
  cp 7
  jr z,.resetPos
  ld [wJoyPadPos],a
  jp ViewSoundValue
.setPos
  ld a,6
  ld [wJoyPadPos],a
  jp ViewSoundValue
.resetPos
  xor a
  ld [wJoyPadPos],a
  jp ViewSoundValue
.playSound
  ld a,[wShift]
  and %00001111
  swap a
  ld b,a
  ld a,[wLFSR]
  and %00000001
  rlca
  rlca
  rlca
  or b
  ld b,a
  ld a,[wDivider]
  and %00000111
  or b
  ldh [rAUD4POLY],a
  ld [wFF22],a
  ;
  ld a,[wVolume]
  and %00001111
  swap a
  ld b,a
  ld a,[wEnv]
  and %00000001
  rlca
  rlca
  rlca
  or b
  ld b,a
  ld a,[wSweep]
  and %00000111
  or b
  ldh [rAUD4ENV],a
  ld [wFF21],a
  ld a,[wLengthTimer]
  ldh [rAUD4LEN],a
  ld [wFF20],a
  ld a,%10000000
  ldh [rAUD4GO],a
  jr ViewSoundValue

SetSoundValue:
  ld d,HIGH(wSValueTbl)
  ld a,[wJoyPadPos]
  ld e,a
  ld a,[wJoypad]
  bit JBitRight,a
  jr nz,.incValue
  ld a,[de]
  dec a
  ld [de],a
  jr .jp
.incValue
  ld a,[de]
  inc a
  ld [de],a
.jp
  ld b,HIGH(SoundSelectTbl)
  ld a,[wJoyPadPos]
  rlca
  ld c,a
  ld a,[bc]
  ld l,a
  inc c
  ld a,[bc]
  ld h,a
	jp hl

SSEL0:
  ld a,[de]
  and %00111111
  ld [de],a
  jr ViewSoundValue
SSEL1:
  ld a,[de]
  and %00001111
  ld [de],a
  jr ViewSoundValue
SSEL2:
  ld a,[de]
  and %00000001
  ld [de],a
  jr ViewSoundValue
SSEL3:
  ld a,[de]
  and %00000011
  ld [de],a
  jr ViewSoundValue
SSEL4:
  ld a,[de]
  and %00001111
  ld [de],a
  jr ViewSoundValue
SSEL5:
  ld a,[de]
  and %00000001
  ld [de],a
  jr ViewSoundValue
SSEL6:
  ld a,[de]
  and %00000011
  ld [de],a

ViewSoundValue:
  ld hl,wShadowOAM
  ld de,wSValueTbl
  ld a,SValueY
  ld [wPosY],a
  ld a,SValueX
  ld [wPosX],a
  xor a
  ld [wAttr],a
  ld c,SValueMax

.loop
  ld a,[de]
  ld [wHex],a
  call SetHexSprite
  inc e
  ld a,[wPosY]
  add a,8
  ld [wPosY],a
  dec c
  jr nz,.loop

  ; view sound registers
  ld a,SRegPosX
  ld [wPosX],a
  ld a,[wFF20]
  ld [wHex],a
  ld a,SReg20PosY
  ld [wPosY],a
  call SetHexSprite
  ld a,[wFF21]
  ld [wHex],a
  ld a,SReg21PosY
  ld [wPosY],a
  call SetHexSprite
  ld a,[wFF22]
  ld [wHex],a
  ld a,SReg22PosY
  ld [wPosY],a
  call SetHexSprite

  ;selected
  ld hl,wShadowOAM+3
  ld a,[wJoyPadPos]
  rlca
  rlca
  rlca
  add a,l
  ld l,a
  ld a,1
  ld [hl],a
  ld a,l
  add a,4
  ld l,a
  ld a,1
  ld [hl],a

  ld a,1
  ld [wMainLoopFlg],a
  jp MainLoop

SetOAM:
  ld a,[wVBlankDone]
  cp 1
  jp nz,MainLoop
  xor a
  ld [wVBlankDone],a
  ld [wMainLoopFlg],a

  mSetOAM
  jp MainLoop

SetHexSprite:
  ;0x
  ld a,[wPosY]
  ld [hli],a ; Y Position
  ld a,[wPosX]
  add a,4
  ld [hli],a ; X Position
  ld a,[wHex]
  and %00001111
  ld [hli],a ; Tile Index
  ld a,[wAttr]
  ld [hli],a ; Attributes/Flags
  ;x0
  ld a,[wPosY]
  ld [hli],a
  ld a,[wPosX]
  ld [hli],a
  ld a,[wHex]
  and %11110000
  swap a
  ld [hli],a
  ld a,[wAttr]
  ld [hli],a
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
  ld a,[de]
  ld [hli],a
  inc de
  dec bc
  ld a,b
  or c
  jr nz,CopyData
  ret

WaitVBlank:
.loop
  ldh a,[rLY]
  cp SCRN_Y ; 144 ; Check if the LCD is past VBlank
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

INCLUDE "data.inc"
INCLUDE "wram.inc"