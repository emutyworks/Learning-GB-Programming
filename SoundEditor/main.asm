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
  ld [wPlayFlg],a

  ; Set Sprites/Tiles data
  ld hl,_VRAM8000
  ld de,Tiles
  ld bc,TilesEnd - Tiles
  call CopyData
  ld hl,_VRAM8800
  ld de,Sprites
  ld bc,SpritesEnd - Sprites
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

  ld a,LCDCF_ON|LCDCF_OBJON|LCDCF_BGON|LCDCF_WINON|LCDCF_WIN9C00|LCDCF_BLK01
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

  ld a,3
  ld [wOctave2],a
  ld a,1
  ld [wLevel2],a
  xor a
  ld [wLengthTimer2],a
  ld [wNote2],a
  ld [wWaveCur],a
  call SetSRegFF1B
  call SetSRegFF1C
  call SetSRegFF1D1E
  call ResetWWave2Num
  call InitWaveData

  ;Init audio registers
  ld a,%10000000
  ldh [rAUDENA],a    ; All sound on/off
  ld a,%01110111
  ldh [rAUDVOL],a    ; -LLL-RRR Output level
  xor a
  ldh [rAUDTERM],a   ; Sound output terminal

  ;set mode
  ld a,2
  ld [wMode],a
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
  bit JBitButtonB,a
  jr nz,CheckButtonB
  bit JBitUp,a
  jr nz,.jUp
  bit JBitDown,a
  jr nz,.jDown
  bit JBitSelect,a
  jr nz,.jSelect

  bit JBitRight,a
  bit JBitButtonA,a
  jp nz,PlaySound
  and %00000011
  jp nz,SetSoundValue
  jp ViewSoundValue

.jSelect
  ld a,[wMode]
  cp 2
  jr z,.jSelectReset
  inc a
  jr .jSelectSet
.jSelectReset
  xor a
.jSelectSet
  ld [wMode],a
  call SetMode
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

CheckButtonB:
  bit JBitStart,a
  jr nz,.resetWWave2Num
  bit JBitRight,a
  jr nz,.incCur
  bit JBitLeft,a
  jr nz,.decCur
  ld c,a
  and %00001100
  jr nz,.calcValue
  call StopSound
  jp ViewSoundValue
.calcValue
  ld hl,wWave2Num
  ld a,[wWaveCur]
  add a,l
  ld l,a
  bit JBitUp,c
  jr nz,.incValue
  bit JBitDown,c
  jr nz,.decValue
  jp ViewSoundValue
.incValue
  ld a,[hl]
  inc a
  jr .setValue
.decValue
  ld a,[hl]
  dec a
.setValue
  and %00001111
  ld [hl],a
  call SetWaveNum
  jp ViewSoundValue
.incCur
  ld a,[wWaveCur]
  inc a
  jr .setCur
.decCur
  ld a,[wWaveCur]
  dec a
.setCur
  and %00011111
  ld [wWaveCur],a
  jp ViewSoundValue
.resetWWave2Num
  call ResetWWave2Num
  call ResetAllWaveGraph
  call ResetWWave2Graph
  call SetWaveGraph
  jp ViewSoundValue

StopSound:
  xor a
  ldh [rAUD1ENV],a
  ldh [rAUD3ENA],a
  ldh [rAUD4ENV],a
  ld [wPlayFlg],a
  ret

PlaySound:
  ld a,[wMode]
  cp 0
  jr z,.playMode0
  cp 1
  jr z,.playMode1
.playMode2
  ld a,[wPlayFlg]
  cp 0
  jp nz,ViewSoundValue
  ld a,1
  ld [wPlayFlg],a
  ld a,%10000000
  ldh [rAUD3ENA],a
  ld a,%01000100
  ldh [rAUDTERM],a
  call SetSRegFF1B
  call SetSRegFF1C
  call SetSRegFF1D1E
  call SetRegFF303F
  ld a,[wFF1E]
  ldh [rAUD3HIGH],a
  jp ViewSoundValue
.playMode1
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
  jp ViewSoundValue

SetSoundValue:
  xor a
  ld [wPlayFlg],a
  ld a,[wSValueTbl]
  ld d,a
  ld a,[wSValueTbl+1]
  ld e,a
  ld a,[wJoyPadPos]
  add a,e
  ld e,a
  ld a,[wJoypad]
  bit JBitRight,a
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
  jp z,SetSoundValueSet
  cp 1
  jr z,SetSoundValueMode1
  ld a,[wJoyPadPos]
  cp 1
  jp c,SetSoundValueSet

SetSoundValueMode2:
  ld a,[wJoyPadPos]
  cp 2
  jp c,SetSoundValueSet
  jr z,.calcOvtave
.calcNote
  ld a,b
  cp $FF
  jr z,.setNote6
  cp 7
  jr z,.setNote0
  ld [de],a
  jp ViewSoundValue
.setNote0
  xor a
  ld [de],a
  ld a,[wOctave2]
  inc a
  cp 8
  jp z,ViewSoundValue
  ld [wOctave2],a
  jp ViewSoundValue
.setNote6
  ld a,6
  ld [de],a
  ld a,[wOctave2]
  dec a
  cp 1
  jr z,ViewSoundValue
  ld [wOctave2],a
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

SetSoundValueMode1:
  ld a,[wJoyPadPos]
  cp 8
  jr c,SetSoundValueSet
  jr z,.calcOvtave
.calcNote
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

SetSoundValueSet:
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
  cp 1
  jp z,.mode1init
.mode2init
  dec c
.mode2
  ld a,[de]
  ld [wHex],a
  ld a,c
  cp 3
  jr nz,.mode2SetSprite0x
  call z,SetHexSprite00
  jr .mode2Next
.mode2SetSprite0x
  call SetHexSprite0x
.mode2Next
  inc e
  ld a,[wPosY]
  add a,8
  ld [wPosY],a
  dec c
  jr nz,.mode2
  ld a,SValueY+8*3
  ld [wPosY],a
  ld a,SValueX
  ld [wPosX],a
  call SetNoteSprite
  ld a,SValueY
  ld [wPosY],a
  ld a,SValueX+8*10
  ld [wPosX],a
  ld a,[wFF1B]
  ld [wHex],a
  call SetHexSprite00
  ld a,SValueY+8*1
  ld [wPosY],a
  ld a,[wFF1C]
  ld [wHex],a
  call SetHexSprite00
  ld a,SValueY+8*2
  ld [wPosY],a
  ld a,[wFF1D]
  ld [wHex],a
  call SetHexSprite00
  ld a,SValueY+8*3
  ld [wPosY],a
  ld a,[wFF1E]
  ld [wHex],a
  call SetHexSprite00
  ld a,SValueY+8*4
  ld [wPosY],a
  ld a,SValueX+3+8*3
  ld [wPosX],a
  ld a,[wWaveCur]
  ld [wHex],a
  call SetHexSprite00
  ;wave cursor
  ld a,Wave2CurPosY
  ld [hli],a
  ld a,[wWaveCur]
  rlca
  rlca
  add a,Wave2CurPosX
  ld [hli],a
  ld a,168
  ld [hli],a
  xor a
  ld [hli],a
  jp .selected

.mode1init
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
  ld a,SValueY+8*9
  ld [wPosY],a
  ld a,SValueX
  ld [wPosX],a
  call SetNoteSprite
  ld a,SValueY
  ld [wPosY],a
  ld a,SValueX+8*10
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
  ld a,SValueX+8*10
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
  ld a,167
  ld [hli],a
  xor a
  ld [hli],a

  mResetShadowOAM

  ld a,1
  ld [wMainLoopFlg],a
  jp MainLoop

SetMode:
  call StopSound
  xor a
  ld [wJoyPadPos],a
  call WaitVBlank

  ld a,[wMode]
  cp 0
  jp z,.setMode0
  cp 1
  jr z,.setMode1
.setMode2
  ld a,SValueX+8*14
  ldh [rSCX],a
  ld a,3 ; max-1
  ld [wSValueMax],a
  ld a,HIGH(wSValue2Tbl)
  ld [wSValueTbl],a
  ld a,LOW(wSValue2Tbl)
  ld [wSValueTbl+1],a
  ld a,HIGH(SRegCalc2Tbl)
  ld [wSRegCalcTbl],a
  ld a,LOW(SRegCalc2Tbl)
  ld [wSRegCalcTbl+1],a
  xor a
  ldh [rVBK],a
  ldh [rWY],a
  ld a,8*18-1
  ldh [rWX],a
  call ResetWin
  call ResetWWave2Graph
  call SetWaveGraph
  ret

.setMode1
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
  xor a
  ldh [rVBK],a
  ldh [rWY],a
  ld a,8*9-1
  ldh [rWX],a
  call ResetWin
  ld hl,RegAddr
  ld a,0
  ld [hli],a
  ld a,1
  ld [hl],a
  ld hl,RegAddr+32*3
  ld a,0
  ld [hli],a
  ld a,2
  ld [hl],a
  ld hl,RegAddr+32*5
  ld a,0
  ld [hli],a
  ld a,3
  ld [hl],a
  ld hl,RegAddr+32*8
  ld a,0
  ld [hli],a
  ld a,4
  ld [hl],a
  ld hl,RegAddr+32*9
  ld a,0
  ld [hli],a
  ld a,5
  ld [hl],a
  ret

.setMode0
  ld a,SValueX-8*2
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
  xor a
  ldh [rVBK],a
  ldh [rWY],a
  ld a,8*9-1
  ldh [rWX],a
  call ResetWin
  call ResetWaveGraph
  ld hl,RegAddr
  ld a,0
  ld [hli],a
  ld a,10
  ld [hl],a
  ld hl,RegAddr+32
  ld a,0
  ld [hli],a
  ld a,11
  ld [hl],a
  ld hl,RegAddr+32*4
  ld a,0
  ld [hli],a
  ld a,12
  ld [hl],a
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

SetSRegFF1B:
  ld a,[wLengthTimer2]
  ldh [rAUD3LEN],a
  ld [wFF1B],a
  ret
SetSRegFF1C:
  ld a,[wLevel2]
  and %00000011
  rrca
  rrca
  rrca
  ldh [rAUD3LEVEL],a
  ld [wFF1C],a
  ret
SetSRegFF1D1E:
  ld hl,MusicalScalePosTbl
  ld a,[wOctave2]
  sub 2
  add a,l
  ld l,a
  ld a,[hl]
  ld hl,MusicalScaleTbl
  add a,l
  ld l,a
  ld a,[wNote2]
  rlca
  add a,l
  ld l,a
  ld a,[hli]
  ldh [rAUD3LOW],a
  ld [wFF1D],a
  ld a,[hl]
  or %10000000
  ld [wFF1E],a
  ret
SetRegFF303F:
  ld de,wWave2Num
  ld hl,_AUD3WAVERAM
  ld c,Wave2Max
.loop
  ld a,[de]
  inc e
  and %00001111
  swap a
  ld b,a
  ld a,[de]
  inc e
  or b
  ld [hli],a
  dec c
  jr nz,.loop
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

SetWaveNum:
  call WaitVBlank
  xor a
  ldh [rVBK],a
  ld a,[wWaveCur]
  ld b,a
  ld de,wWave2Num
  add a,e
  ld e,a
  ld a,b
  rrca
  and %00001111
  bit 0,b
  jr nz,.lowerNum
.upperNum
  ld hl,$99d0
  add a,l
  ld l,a
  ld a,[de]
  or %10000000
  ld [hl],a
  jr .setGraph
.lowerNum
  ld hl,$99f0
  add a,l
  ld l,a
  ld a,[de]
  or %10010000
  ld [hl],a
.setGraph
  ld a,[wWaveCur]
  rrca
  and %00001111
  ld b,a
  rlca
  ld de,wWave2Num
  add a,e
  ld e,a

  ld a,b
  rlca
  rlca
  rlca
  ld hl,wWave2Graph
  add a,l
  ld l,a
  ld [wWave2GraphAddrL],a
  ld c,8
  xor a
.reset
  ld [hli],a
  dec c
  jr nz,.reset
  ld a,[wWave2GraphAddrL]
  ld l,a

  mSetWaveGraphDot

  ld hl,WaveAddr
  ld a,[wWaveCur]
  rrca
  and %00001111
  ld b,a
  add a,l
  ld l,a
  ld a,b
  rlca
  rlca
  rlca
  ld de,wWave2Graph+7
  add a,e
  ld e,a

  ld c,8
  call WaitVBlank
.loopGraph
  ld a,[de]
  cp 0
  jr z,.resetTile
  or %01000000
  jr .setTile
.resetTile
  ld a,ResetBGTile
.setTile
  ld [hl],a
  push bc
  ld bc,$20
  add hl,bc
  pop bc
  dec e
  dec c
  jr nz,.loopGraph
  ret

SetWaveGraph:
  call WaitVBlank
  xor a
  ldh [rVBK],a
  ld a,LOW(wWave2Graph)
  ld [wWave2GraphAddrL],a
  ld hl,wWave2Graph
  ld de,wWave2Num
  ld c,16
.loop
  mSetWaveGraphDot
  ld a,[wWave2GraphAddrL]
  add a,8
  ld [wWave2GraphAddrL],a
  ld l,a
  inc e
  dec c
  jr nz,.loop

  call WaitVBlank
  ld de,wWave2Num
  ld hl,$99d0
  ld c,16
.loopNum1
  ld a,[de]
  or %10000000
  ld [hli],a
  inc e
  inc e
  dec c
  jr nz,.loopNum1

  ld de,wWave2Num+1
  ld hl,$99f0
  ld c,16
.loopNum2
  ld a,[de]
  or %10010000
  ld [hli],a
  inc e
  inc e
  dec c
  jr nz,.loopNum2

  ld d,HIGH(wWave2Graph)
  ld e,LOW(wWave2Graph+8*16)
  ld hl,WaveAddr-1
  ld b,8
.nextLoop
  call WaitVBlank
  ld c,16
  ld a,e
  sub 8*16+1
  ld e,a
.loopGraph
  ld a,e
  add a,8
  ld e,a
  inc l
  ld a,[de]
  cp 0
  jr z,.skipGraph
  or %01000000
  ld [hl],a
.skipGraph
  dec c
  jr nz,.loopGraph
  push bc
  ld bc,$10
  add hl,bc
  pop bc
  dec b
  jr nz,.nextLoop
  ret

InitWaveData:
  ld de,WaveInitData
  ld hl,wWave2Num
  ld c,Wave2NumMax
.loop
  ld a,[de]
  ld b,a
  and %11110000
  swap a
  ld [hli],a
  ld a,b
  and %00001111
  ld [hli],a
  inc de
  dec c
  jr nz,.loop
  ret

ResetWaveGraph:
  ld hl,ResetWaveAddr
  ld de,$20
  ld c,10
  ld a,ResetBGTile
.loop
  ld [hl],a
  add hl,de
  dec c
  jr nz,.loop
  ret
ResetAllWaveGraph:
  xor a
  ldh [rVBK],a
  ld hl,WaveAddr
  ld bc,$10
  ld d,8
.nextLoop
  call WaitVBlank
  ld e,16
  ld a,ResetBGTile
.loop
  ld [hli],a
  dec e
  jr nz,.loop
  add hl,bc
  dec d
  jr nz,.nextLoop
  ret

ResetWWave2Graph:
  xor a
  ld c,Wave2GraphMax
  ld hl,wWave2Graph
.loop
  ld [hli],a
  dec c
  jr nz,.loop
  ret
ResetWWave2Num:
  xor a
  ld c,Wave2NumMax
  ld hl,wWave2Num
.loop
  ld [hli],a
  dec c
  jr nz,.loop
  ret
ResetWin:
  ld a,ResetBGTile
  ld de,31
  ld c,10
  ld hl,RegAddr
.loop
  ld [hli],a
  ld [hl],a
  add hl,de
  dec c
  jr nz,.loop
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
  ld [hli],a
  ld a,[wHex]
  and %11110000
  swap a
  or %10000000
  ld [hli],a
  xor a
  ld [hli],a
SetHexSprite0x:
  ;0x
  ld a,[wPosY]
  ld [hli],a
  ld a,[wPosX]
  add a,4
  ld [hli],a
  ld a,[wHex]
  and %00001111
  or %10000000
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
  add a,$A0
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