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
  ld [wPosY],a
  ld [wPosX],a
  ld [wHex],a
  ld [wJoypad],a
  ld [wJoypadWait],a
  ld [wVBlankDone],a
  ld [wMainLoopFlg],a
  ld [wMode],a

  xor a
  ldh [rWY],a
  ld a,8*8-1
  ldh [rWX],a

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
	ld hl,_SCRN1
	ld de,BgTileMapWin1
	ld bc,BgTileMapWin1End - BgTileMapWin1
	call CopyData
	xor a
	ldh [rVBK],a ; Tile Indexes
	ld hl,_SCRN0
	ld de,BgTileMap0
	ld bc,BgTileMap0End - BgTileMap0
	call CopyData
	ld hl,_SCRN1
	ld de,BgTileMapWin0
	ld bc,BgTileMapWin0End - BgTileMapWin0
	call CopyData

  ld a,LCDCF_ON|LCDCF_OBJON|LCDCF_BGON|LCDCF_WINON|LCDCF_WIN9C00
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
  ld [wLengthTimer0],a
  ld a,$0f
  ld [wVolume0],a
  ld a,1
  ld [wSweep0],a
  xor a
  ld [wEnv0],a
  ld [wShift0],a
  ld [wLFSR0],a
  ld [wDivider0],a
  call SetSRegFF20
  call SetSRegFF21
  call SetSRegFF22
  ;
  xor a
  ld a,3
  ld [wOctave1],a
  ld a,$f
  ld [wVolume1],a
  ld a,2
  ld [wDuty1],a
  ld a,7
  ld [wSweep1],a
  ld a,$3f
  ld [wLengthTimer1],a
  xor a
  ld [wPace1],a
  ld [wDir1],a
  ld [wStep1],a
  ld [wEnv1],a
  ld [wNote1],a
  call SetSRegFF10
  call SetSRegFF11
  call SetSRegFF12
  call SetSRegFF1314

  ;Init audio registers
  ld a,%10000000
  ldh [rAUDENA],a    ; All sound on/off
  ld a,%01110111
  ldh [rAUDVOL],a    ; -LLL-RRR Output level
  xor a
  ldh [rAUDTERM],a   ; Sound output terminal
  ldh [rAUD1SWEEP],a
  ldh [rAUD1LEN],a
  ldh [rAUD1ENV],a
  ldh [rAUD4ENV],a

  call SetMode

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
  bit JBitUp,a
  jr nz,.jUp
  bit JBitDown,a
  jr nz,.jDown
  bit JBitRight,a
  ld c,a
  and %00100001
  cp $21
  jr z,.setMode1
  ld a,c
  and %00100010
  cp $22
  jr z,.setMode0
  ld a,c
  bit JBitButtonA,a
  jr nz,PlaySound
  bit JBitButtonB,a
  jr nz,.stopSound
  and %00000011
  jr nz,SetSoundValue
  jp ViewSoundValue
.setMode0
  xor a
  ld [wMode],a
  call SetMode
  jp ViewSoundValue
.setMode1
  ld a,1
  ld [wMode],a
  call SetMode
  jp ViewSoundValue
.stopSound
  xor a
  ldh [rAUD1ENV],a
  ldh [rAUD4ENV],a
  jp ViewSoundValue
.jUp
  ld a,[wJoyPadPos]
  cp 0
  jr nz,.decPos
  ld a,[wSValueMax]
  jr .setPos
.jDown
  ld a,[wSValueMax]
  ld c,a
  ld a,[wJoyPadPos]
  cp c
  jr nz,.incPos
  xor a
  jr .setPos
.decPos
  dec a
  jr .setPos
.incPos
  inc a
.setPos
  ld [wJoyPadPos],a
  jp ViewSoundValue

PlaySound:
  ld a,[wMode]
  cp 0
  jr z,.playMode0
  ;.playMode1
  ld a,%00010001
  ldh [rAUDTERM],a
  call SetSRegFF10
  call SetSRegFF11
  call SetSRegFF12
  call SetSRegFF1314
  ld a,[wFF14]
  ldh [rAUD1HIGH],a
  jp ViewSoundValue
.playMode0
  ld a,%10001000
  ldh [rAUDTERM],a
  call SetSRegFF20
  call SetSRegFF21
  call SetSRegFF22
  ld a,%10000000
  ldh [rAUD4GO],a
  jr ViewSoundValue

SetSoundValue:
  ld a,[wSValueTbl]
  ld d,a
  ld a,[wSValueTbl+1]
  ld e,a
  ld a,[wJoyPadPos]
  add a,e
  ld e,a
  ld a,[wJoypad]
  bit JBitLeft,a
  jr nz,.incValue
  ld a,[de]
  dec a
  jr .calc
.incValue
  ld a,[de]
  inc a
.calc
  ld b,a
  ld a,[wMode]
  cp 0
  jr z,.calcMode0
  ld a,[wJoyPadPos]
  cp 8
  jr c,.calcMode0
  jr z,.calcOvtave
  ;Note
  ld a,b
  cp $FF
  jr z,.setNote6
  cp 7
  jr z,.setNote0
  ld [de],a
  jr ViewSoundValue
.setNote0
  xor a
  ld [de],a
  ld a,[wOctave1]
  inc a
  cp 8
  jr z,ViewSoundValue
  ld [wOctave1],a
  jr ViewSoundValue
.setNote6
  ld a,6
  ld [de],a
  ld a,[wOctave1]
  dec a
  cp 1
  jr z,ViewSoundValue
  ld [wOctave1],a
  jr ViewSoundValue
.calcOvtave
  ld a,b
  cp 1
  jr z,.setOctave7
  cp 8
  jr z,.setOctave2
  ld [de],a
  jr ViewSoundValue
.setOctave2
  ld a,2
  ld [de],a
  jr ViewSoundValue
.setOctave7
  ld a,7
  ld [de],a
  jr ViewSoundValue
.calcMode0
  ld a,[wSRegCalcTbl]
  ld h,a
  ld a,[wSRegCalcTbl+1]
  ld l,a
  ld a,[wJoyPadPos]
  add a,l
  ld l,a
  ld c,[hl]
  ld a,b
  and c
  ld [de],a

ViewSoundValue:
  ld hl,wShadowOAM
  ld a,[wSValueTbl]
  ld d,a
  ld a,[wSValueTbl+1]
  ld e,a
  ld a,SValueY
  ld [wPosY],a
  ld a,SValueX
  ld [wPosX],a
  ld a,[wSValueMax]
  inc a
  ld c,a
  ; view sound registers
  ld a,[wMode]
  cp 0
  jp z,.mode0
  dec c
.mode1
  ld a,[de]
  ld [wHex],a
  ld a,c
  cp 5
  jr nz,.mode1SetSprite0x
  call SetHexSprite00
  jr .mode1Next
.mode1SetSprite0x
  call SetHexSprite0x
.mode1Next
  inc e
  ld a,[wPosY]
  add a,8
  ld [wPosY],a
  dec c
  jr nz,.mode1
  ;Note
  ld a,SValueY+8*9
  ld [wPosY],a
  ld a,SValueX
  ld [wPosX],a
  call SetNoteSprite
  ld a,SValueY
  ld [wPosY],a
  ld a,SValueX+8*9
  ld [wPosX],a
  ld a,[wFF10]
  ld [wHex],a
  call SetHexSprite00
  ld a,SValueY+24
  ld [wPosY],a
  ld a,[wFF11]
  ld [wHex],a
  call SetHexSprite00
  ld a,SValueY+40
  ld [wPosY],a
  ld a,[wFF12]
  ld [wHex],a
  call SetHexSprite00
  ld a,SValueY+64
  ld [wPosY],a
  ld a,[wFF13]
  ld [wHex],a
  call SetHexSprite00
  ld a,SValueY+72
  ld [wPosY],a
  ld a,[wFF14]
  ld [wHex],a
  call SetHexSprite00
  jr .selected
.mode0
  ld a,[de]
  ld [wHex],a
  ld a,c
  cp 7
  jr nz,.mode0SetSprite0x
  call z,SetHexSprite00
  jr .mode0Next
.mode0SetSprite0x
  call SetHexSprite0x
.mode0Next
  inc e
  ld a,[wPosY]
  add a,8
  ld [wPosY],a
  dec c
  jr nz,.mode0
  ld a,SValueY
  ld [wPosY],a
  ld a,SValueX+8*9
  ld [wPosX],a
  ld a,[wFF20]
  ld [wHex],a
  call SetHexSprite00
  ld a,SValueY+8
  ld [wPosY],a
  ld a,[wFF21]
  ld [wHex],a
  call SetHexSprite00
  ld a,SValueY+32
  ld [wPosY],a
  ld a,[wFF22]
  ld [wHex],a
  call SetHexSprite00

.selected
  ld a,SValueY
  ld c,a
  ld a,[wJoyPadPos]
  rlca
  rlca
  rlca
  add a,c
  ld [hli],a
  ld a,SValueX
  ld [hli],a
  ld a,23
  ld [hli],a
  xor a
  ld [hli],a

  mResetShadowOAM

  ld a,1
  ld [wMainLoopFlg],a
  jp MainLoop

SetMode:
  xor a
  ld [wJoyPadPos],a

  ld a,[wMode]
  cp 0
  jr z,.setMode0
  ;setMode1
  ld a,SValueX+8*6
  ldh [rSCX],a
  ld a,9 ; max-1
  ld [wSValueMax],a
  ld a,HIGH(wSValue1Tbl)
  ld [wSValueTbl],a
  ld a,LOW(wSValue1Tbl)
  ld [wSValueTbl+1],a
  ld a,HIGH(SRegCalc1Tbl)
  ld [wSRegCalcTbl],a
  ld a,LOW(SRegCalc1Tbl)
  ld [wSRegCalcTbl+1],a

  call ResetWin
  xor a
	ldh [rVBK],a
	ld hl,RegAddrPos
  ld a,0
  ld [hli],a
  ld a,1
  ld [hl],a
	ld hl,RegAddrPos+32*3
  ld a,0
  ld [hli],a
  ld a,2
  ld [hl],a
	ld hl,RegAddrPos+32*5
  ld a,0
  ld [hli],a
  ld a,3
  ld [hl],a
	ld hl,RegAddrPos+32*8
  ld a,0
  ld [hli],a
  ld a,4
  ld [hl],a
	ld hl,RegAddrPos+32*9
  ld a,0
  ld [hli],a
  ld a,5
  ld [hl],a
  ret
.setMode0
  xor a
  ldh [rSCX],a
  ld a,6 ; max-1
  ld [wSValueMax],a
  ld a,HIGH(wSValue0Tbl)
  ld [wSValueTbl],a
  ld a,LOW(wSValue0Tbl)
  ld [wSValueTbl+1],a
  ld a,HIGH(SRegCalc0Tbl)
  ld [wSRegCalcTbl],a
  ld a,LOW(SRegCalc0Tbl)
  ld [wSRegCalcTbl+1],a

  call ResetWin
  xor a
	ldh [rVBK],a
	ld hl,RegAddrPos
  ld a,0
  ld [hli],a
  ld a,8
  ld [hl],a
	ld hl,RegAddrPos+32
  ld a,0
  ld [hli],a
  ld a,9
  ld [hl],a
	ld hl,RegAddrPos+32*4
  ld a,0
  ld [hli],a
  ld a,10
  ld [hl],a
  ret

ResetWin:
  ld a,47
  ld de,31
  ld c,10
  ld hl,RegAddrPos
.loop
  ld [hli],a
  ld [hl],a
  add hl,de
  dec c
  jr nz,.loop
  ret

SetSRegFF10:
  ld a,[wPace1]
  and %00000111
  rlca
  rlca
  rlca
  rlca
  ld b,a
  ld a,[wDir1]
  and %00000001
  rlca
  rlca
  rlca
  or b
  ld b,a
  ld a,[wStep1]
  and %00000111
  or b
  ldh [rAUD1SWEEP],a
  ld [wFF10],a
  ret
SetSRegFF11:
  ld a,[wDuty1]
  and %00000011
  rrca
  rrca
  ld b,a
  ld a,[wLengthTimer1]
  and %00111111
  or b
  ldh [rAUD1LEN],a
  ld [wFF11],a
  ret
SetSRegFF12:
  ld a,[wVolume1]
  and %00001111
  rlca
  rlca
  rlca
  rlca
  ld b,a
  ld a,[wEnv1]
  and %00000001
  rlca
  rlca
  rlca
  or b
  ld b,a
  ld a,[wSweep1]
  and %00000111
  or b
  ldh [rAUD1ENV],a
  ld [wFF12],a
  ret
SetSRegFF1314:
  ld hl,MusicalScalePosTbl
  ld a,[wOctave1]
  sub 2
  add a,l
  ld l,a
  ld a,[hl]
  ld hl,MusicalScaleTbl
  add a,l
  ld l,a
  ld a,[wNote1]
  rlca
  add a,l
  ld l,a
  ld a,[hli]
  ldh [rAUD1LOW],a
  ld [wFF13],a
  ld a,[hl]
  or %10000000
  ld [wFF14],a
  ret

SetSRegFF20:
  ld a,[wLengthTimer0]
  ldh [rAUD4LEN],a
  ld [wFF20],a
  ret
SetSRegFF21:
  ld a,[wVolume0]
  and %00001111
  swap a
  ld b,a
  ld a,[wEnv0]
  and %00000001
  rlca
  rlca
  rlca
  or b
  ld b,a
  ld a,[wSweep0]
  and %00000111
  or b
  ldh [rAUD4ENV],a
  ld [wFF21],a
  ret
SetSRegFF22:
  ld a,[wShift0]
  and %00001111
  swap a
  ld b,a
  ld a,[wLFSR0]
  and %00000001
  rlca
  rlca
  rlca
  or b
  ld b,a
  ld a,[wDivider0]
  and %00000111
  or b
  ldh [rAUD4POLY],a
  ld [wFF22],a
  ret

SetOAM:
  ld a,[wVBlankDone]
  cp 1
  jp nz,MainLoop
  xor a
  ld [wVBlankDone],a
  ld [wMainLoopFlg],a

  mSetOAM
  jp MainLoop

SetHexSprite00:
  ;x0
  ld a,[wPosY]
  ld [hli],a
  ld a,[wPosX]
  sub 4
  ld [hli],a
  ld a,[wHex]
  and %11110000
  swap a
  ld [hli],a
  xor a
  ld [hli],a
SetHexSprite0x:
  ;0x
  ld a,[wPosY]
  ld [hli],a
  ld a,[wPosX]
  ld [hli],a
  ld a,[wHex]
  and %00001111
  ld [hli],a
  xor a
  ld [hli],a
  ret
SetNoteSprite:
  ;0x
  ld a,[wPosY]
  ld [hli],a
  ld a,[wPosX]
  ld [hli],a
  ld a,[de]
  add a,$10
  ld [hli],a
  xor a
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