;
; I used this Website/Document as a reference to create it.
;
; Run-length encoding
; https://en.wikipedia.org/wiki/Run-length_encoding
;
; Z80 1バイトデータの分解 (Z80 1-byte data decomposition)
; https://codeknowledge.livedoor.blog/archives/25232135.html
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

SECTION	"HBlank Handler",ROM0[$48]
HBlankHandler:
  push af
  push hl
  ldh a,[rLY]
  ld l,a
  ld h,HIGH(wSCY)
  ld a,[hl]
  ldh [rSCY],a
  inc h ;wSCX
  ld a,[hl]
  ldh [rSCX],a
  pop hl
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
  mWaitVBlank

  ; Set BG Palette
  ld a,%10000000
  ldh [rBCPS],a
  ld c,4*2
  ld hl,BGPaletteTbl1
  ld de,rBCPD
  call SetPalette
  ld a,%10010000
  ldh [rBCPS],a
  ld c,4*6
  ld hl,BGPalette
  call SetPalette

  ; Set Object Palette
  ld a,%10000000
  ldh [rOCPS],a
  ld c,4*2
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
  ldh [rWY],a
  ldh [rWX],a

  ; Set Sprites/Tiles data
  ld hl,_VRAM ;$8000
  ld de,Sprites
  ld bc,SpritesEnd-1
  call CopyDecompressionData
  ld hl,_VRAM+$1000 ;$9000
  ld de,Tiles
  ld bc,TilesEnd-1
  call CopyDecompressionData

  ; Set Map data
  ld a,1
  ldh [rVBK],a ; BG Map Attributes
  ld hl,_SCRN0
  ld de,BgTileMap1
  ld bc,BgTileMap1End-1
  call CopyDecompressionData
  xor a
  ldh [rVBK],a ; Tile Indexes
  ld hl,_SCRN0
  ld de,BgTileMap0
  ld bc,BgTileMap0End-1
  call CopyDecompressionData

  mSetLCDC
  ldh [rLCDC],a

  mInitwShadowOAM

  ; Set up the lcdc int
  ld a,STATF_LYC|STATF_MODE00
  ldh [rSTAT],a

  ; Enable the interrupts
  ld a,IEF_VBLANK|IEF_STAT
  ldh [rIE],a
  xor a
  ei
  ldh [rIF],a

  ; Init Work RAM
  xor a
  ld hl,State
  ld c,StateEnd - State 
  call SetWRam
  ld hl,wSCY
  ld c,ScrollMaxSize
  call SetWRam
  ld hl,wSCX
  ld c,ScrollMaxSize
  call SetWRam
  ld hl,wRoadYUD
  ld c,ScrollRoadSize
  call SetWRam
  ld hl,wRoadXLR
  ld c,ScrollRoadSize
  call SetWRam
  ld hl,wJoyPadXLR
  ld c,ScrollRoadSize
  call SetWRam
  ld hl,wRivalTblZ
  ld c,4*3
  call SetWRam

  ; Set Work RAM
  ld a,StartBgScrollY
  ld c,ScrollBgSize
  ld hl,wBgY
  call SetWRam

  ; Set Joypad
  ld a,JoypadWait
  ld [wJoypadWait],a
  ld a,JoyPadPos
  ld [wJoyPadPos],a
  xor a
  ld hl,wJoyPadXLR
  ld c,ScrollRoadSize
  call SetWRam

  ; Set Sound
  ld a,%00010001 ; -LLL-RRR Output level
  ldh [rAUDVOL],a
  ld a,%11111111 ; Sound output terminal
  ldh [rAUDTERM],a
  ld a,%10000000 ; All sound on/off
  ldh [rAUDENA],a

  ; Set Wave Data
  ld hl,$FF30
  ld de,WaveData
  ld bc,WaveDataEnd - WaveData
  call CopyData

  ld a,%10000000 ; Wave sound on/off
  ldh [rAUD3ENA],a
  ld a,$FF ; Sound Length
  ldh [rAUD3LEN],a

  ld a,GearHiY
  ld [wCarGearY],a
  ld a,GearHi
  ld [wCarGear],a

  ;debug
  ;ld a,1
  ;ld [wCarShift],a

MainLoop:
  ld a,[wMainLoopFlg]
  cp 1
  jp z,SetOAM

  mCheckJoypad

  ld a,[wCarSmoke]
  inc a
  and %00000011
  ld [wCarSmoke],a

LapTime:
  ld a,[wLapTimeMS]
  inc a
  daa
  ld [wLapTimeMS],a
  cp $60
  jr nz,SetRivalCar
  xor a
  ld [wLapTimeMS],a
  ld a,[wLapTimeS]
  inc a
  daa
  ld [wLapTimeS],a
  cp $60
  jr nz,SetRivalCar
  xor a
  ld [wLapTimeS],a
  ld a,[wLapTimeM]
  inc a
  daa
  ld [wLapTimeM],a

SetRivalCar:
  ld a,[wRivalWait]
  cp 0
  jr z,.set
  dec a
  ld [wRivalWait],a
  jp SetSpeed
.set
  ld a,[wRivalWaitDef]
  ld [wRivalWait],a
  ld a,[wCarShift]
  cp 5
  ld hl,wRivalTblZ
  jr z,.incPosZ
REPT 3
  ld a,[hl]
  cp 0
  jr z,.next\@
  dec a
  ld [hl],a
.next\@
  inc l
ENDR
  ld a,[hl]
  cp 0
  jr z,SetSpeed
  dec a
  ld [hl],a
  jr SetSpeed
.incPosZ
REPT 3
  ld a,[hl]
  cp 0
  jr z,.next\@
  inc a
  and %00011111
  ld [hl],a
  cp 0
  jr nz,.next\@
  ld a,[wRivalCnt]
  inc a
  daa
  ld [wRivalCnt],a
.next\@
  inc l
ENDR
  ld a,[hl]
  cp 0
  jr z,SetSpeed
  inc a
  and %00011111
  ld [hl],a
  cp 0
  jr nz,SetSpeed
  ld a,[wRivalCnt]
  inc a
  daa
  ld [wRivalCnt],a
SetSpeed:
  ld a,[wCarSpeedWait]
  cp 0
  jr z,.setSpeed
  dec a
  ld [wCarSpeedWait],a
  jp SetRoadPos

.setSpeed
  ld a,[wCarSpeed]
  ld [wCarSpeedWait],a
  ld a,[wCarScroll]
  ld [wAddScroll],a
  cp 0
  jp z,SetRoadPos

  ;RoadPatternTbl
  ld a,[wRoadPWait]
  cp 0
  jr z,.decRoadPCnt
  dec a
  ld [wRoadPWait],a
  jp SetRoadPos

.decRoadPCnt
  ld a,[wRoadPCnt]
  cp 0
  jp z,SetScenarioTbl
  dec a
  ld [wRoadPCnt],a

  xor a
  ld [wCarCForce],a

  mInitWRoadXLR
  mJpScenario

SetSPRivalCar:
  ld a,[wRivalTbl]
  inc a
  and %00000011
  ld [wRivalTbl],a
  ld l,a
  ld h,HIGH(wRivalTblZ)
  ld a,[hl]
  cp 0
  jp nz,SetRoadPos
  ld a,1
  ld [hl],a
  ld a,l
  add a,4
  ld l,a
  ld a,[wSParam]
  ld d,a
  and %00001111
  ld [hl],a ;x
  ld a,l
  add a,4
  ld l,a
  ld a,d
  swap a
  and %00001111
  ld [hl],a ;pal
  jp SetRoadPos

SetSPPalChange2:
  ld b,2
  jr SetSPPalChange23
SetSPPalChange3:
  ld b,3
SetSPPalChange23:
  ld a,[wRoadPCnt]
  cp 0
  jr z,.exit
  ld a,[wRoadPWork]
  ld c,a
  ld hl,wRoadYUD
  add a,l
  ld l,a
  ld a,b
  cp 2
  jr z,.set2
  xor a
  ld [hl],a
  dec c
  jr .next
.set2
  ld a,-1
  sub c
  ld [hl],a
  inc c
.next
  ld a,c
  ld [wRoadPWork],a
  jp SetRoadPWait
.exit
  ld a,b
  cp 2
  jr z,.exit2
  ld a,SPP14Cnt-2
  jr .setWork
.exit2
  ld a,SPP14Cnt-2
  ld [wRoadPPalL],a
  ld a,SPP23Cnt-2
.setWork
  ld [wRoadPWork],a
  jp SetRoadPWait

SetSPPalette:
  ld b,0
  ld a,[wSParam]
  add a,HIGH(BGPaletteTbl1)
  ld [wRoadPPalH],a
  jr SetSPSetPalette
SetSPPalChange1:
  ld b,1
  jr SetSPPalChange14
SetSPPalChange4:
  ld b,4
SetSPPalChange14:
  ld a,[wRoadPCnt]
  cp 0
  jr z,ResetWRoadPWork
SetSPSetPalette:
  ld a,[wRoadPPalH]
  ld h,a
  ld a,[wRoadPPalL]
  ld c,a
  rlca
  rlca
  rlca
  rlca
  ld l,a
  ld a,%10000000
  ldh [rBCPS],a
  ld de,rBCPD
REPT 8
  mSetPalette
ENDR
  ld a,b
  cp 0
  jp z,SetRoadPos
  cp 1
  jr z,.inc
  dec c
  jr .next
.inc
  inc c
.next
  ld a,c
  ld [wRoadPPalL],a
  jr SetRoadPWait

ResetWRoadPWork:
  xor a
  ld [wRoadPWork],a
  ld [wRoadPPalL],a
SetRoadPWait:
  ld a,[wSParam]
  ld [wRoadPWait],a
  jp SetRoadPos

SetRoadPLeft:
  mSetCarCForceL
  ld a,[wBgX]
  dec a
  ld hl,wBgX
  mSetWBG
  ld de,wRoadXLR
  ld h,HIGH(ScrollLeftTbl)
  ld a,[wRoadPLRCnt]
  ld l,a
  cp $E0
  jr z,.skip
  add a,$20
  ld [wRoadPLRCnt],a
.skip
  mCopyScrollRoad
  jp SetRoadPWait

SetRoadPLeftSt:
  mSetCarCForceL
  ld a,[wBgX]
  dec a
  ld hl,wBgX
  mSetWBG
  ld de,wRoadXLR
  ld h,HIGH(ScrollLeftTbl)
  ld a,[wRoadPLRCnt]
  ld l,a
  cp 0
  jr z,.skip
  sub a,$20
  ld [wRoadPLRCnt],a
.skip
  mCopyScrollRoad
  jp SetRoadPWait

SetRoadPRight:
  mSetCarCForceR
  ld a,[wBgX]
  inc a
  ld hl,wBgX
  mSetWBG
  ld de,wRoadXLR
  ld h,HIGH(ScrollRightTbl)
  ld a,[wRoadPLRCnt]
  ld l,a
  cp $E0
  jr z,.skip
  add a,$20
  ld [wRoadPLRCnt],a
.skip
  mCopyScrollRoad
  jp SetRoadPWait

SetRoadPRightSt:
  mSetCarCForceR
  ld a,[wBgX]
  inc a
  ld hl,wBgX
  mSetWBG
  ld de,wRoadXLR
  ld h,HIGH(ScrollRightTbl)
  ld a,[wRoadPLRCnt]
  ld l,a
  cp 0
  jr z,.skip
  sub a,$20
  ld [wRoadPLRCnt],a
.skip
  mCopyScrollRoad
  jp SetRoadPWait

SetRoadPBgUp:
  ld a,[wBgY]
  inc a
  ld hl,wBgY
  mSetWBG
  jp SetRoadPWait

SetRoadPBgDown:
  ld a,[wBgY]
  dec a
  ld hl,wBgY
  mSetWBG
  jp SetRoadPWait

SetScenarioTbl:
  ld a,[wRoadPTbl]
  inc a
  and %00111111 ;debug
  ld [wRoadPTbl],a
  rlca
  rlca
  ld l,a
  ld h,HIGH(ScenarioTbl)
  ld a,[hli]
  ld [wSPoint],a
  ld a,[hli]
  ld [wSPoint+1],a
  ld a,[hli]
  ld [wRoadPCnt],a
  ld a,[hl]
  ld [wSParam],a

SetRoadPos:
  ld a,[wAddScroll]
  ld d,a
  ld a,[wRoadPos]
  add a,d
  ld [wRoadPos],a
  ld h,HIGH(ScrollPosTbl)
  ld l,a
  ld de,wRoadY
  mCopyScrollRoad
  mCalcWRoadY

  xor a
  ld [wAddScroll],a

  ld a,[wJoypad]
  bit JBitUp,a
  jp nz,.jGearHi
  bit JBitDown,a
  jp nz,.jGearLow
  bit JBitRight,a
  jp nz,.jRight
  bit JBitLeft,a
  jp nz,.jLeft
  jp SetWJoyPadXLR

.jGearHi
  ld a,[wCarGear]
  cp 1
  jp z,SetWJoyPadXLR
  ld a,GearHiY
  ld [wCarGearY],a
  ld a,1
  ld [wCarGear],a
  ld a,[wCarShift]
  cp 0
  jr z,SetWJoyPadXLR
  ld a,GearHiShift
  ld [wCarShift],a
  jr SetWJoyPadXLR
.jGearLow
  ld a,GearLowY
  ld [wCarGearY],a
  xor a
  ld [wCarGear],a
  jr SetWJoyPadXLR

.jRight
  ld a,4
  ld [wCarSprite],a
  ld a,[wCarCForce]
  cp CarCForceRight
  jr z,SetWJoyPadXLR
  mJoypadWait
  ld a,[wJoyPadPos]
  cp 15
  jr z,SetWJoyPadXLR
  inc a
  ld [wJoyPadPos],a
  jr SetWJoyPadXLR
.jLeft
  ld a,2
  ld [wCarSprite],a
  ld a,[wCarCForce]
  cp CarCForceLeft
  jr z,SetWJoyPadXLR
  mJoypadWait
  ld a,[wJoyPadPos]
  cp 1
  jr z,SetWJoyPadXLR
  dec a
  ld [wJoyPadPos],a

SetWJoyPadXLR:
  ld a,[wJoyPadPos]
  ld d,a
  and %00000111
  ld e,a
  xor d
  rrca
  rrca
  rrca
  add a,HIGH(ScrollLRTbl)
  ld h,a
  ld a,e
  rrca
  rrca
  rrca
  ld l,a
  ld de,wJoyPadXLR
  mCopyScrollRoad
  ld hl,CarSmokeTbl
  ld a,[wJoyPadPos]
  add a,l
  ld l,a
  ld a,[hl]
  ld [wSmokeTbl],a

CheckButton:
  ld a,[wJoypad]
  bit JBitButtonA,a
  jr nz,.jButtonA

  ld a,[wCarShiftWait]
  cp 0
  jr nz,DecWCarShiftWait
  ld a,[wCarShift]
  cp 0
  jr z,.setShift
  dec a ;debug
  ld [wCarShift],a
  jr .setShift

.jButtonA
  ld a,[wCarGear]
  cp GearLow
  jr z,.setLowShift

  ld a,[wCarShiftWait]
  cp 0
  jr nz,DecWCarShiftWait
  ld a,[wCarShift]
  cp CarShiftMax
  jr z,.setShift
  inc a
  jr .setWCarShift

.setLowShift
  ld a,GearLowShift
.setWCarShift
  ld [wCarShift],a

.setShift
  mCarShift
  mSetEngineSound
  jr SetSprite

DecWCarShiftWait:
  dec a
  ld [wCarShiftWait],a

SetSprite:
  ld a,[wCarSprite]
  ld c,a
  ld a,[wCarShift]
  cp 0
  jr z,.draw
  ld a,[wCarSmoke]
  ld d,a
  cp 0
  jr z,.draw
  inc c
.draw
  ld a,c
  rlca
  rlca
  ld bc,CarSpriteTbl
  add a,c
  ld c,a
  ld hl,wShadowOAM
  ;smoke
  ld a,d
  cp 0
  jr nz,.drawCar
  ld a,[wSmokeTbl]
  sub 1
  jr c,.drawCForceSmoke ; (255) 0 skip
  jr z,.setSmokeRight ; (0) 1 right
  ld d,a
  ld a,CarPosY
  ld [hli],a ; Y Position
  ld a,CarPosX-3
  ld [hli],a ; X Position
  ld a,20
  ld [hli],a ; Tile Index
  ld a,0
  ld [hli],a ; Attributes/Flags
  ld a,d
  cp 2 ; (3) left/right
  jr nz,.drawCForceSmoke
.setSmokeRight
  ld a,CarPosY
  ld [hli],a
  ld a,CarPosX+8+3
  ld [hli],a
  ld a,20
  ld [hli],a
  ld a,0|OAMF_XFLIP
  ld [hli],a
.drawCForceSmoke
  ld a,[wCarCForce]
  cp 0
  jr z,.drawCar
  ld a,CarPosY
  ld [hli],a
  ld a,CarPosX-1
  ld [hli],a
  ld a,22
  ld [hli],a
  ld a,0
  ld [hli],a
  ld a,CarPosY
  ld [hli],a
  ld a,CarPosX+8+1
  ld [hli],a
  ld a,22
  ld [hli],a
  ld a,0|OAMF_XFLIP
  ld [hli],a
.drawCar
  ;gear
  ld a,[wCarGearY]
  ld [hli],a
  ld a,8*14
  ld [hli],a
  ld a,24
  ld [hli],a
  ld a,0
  ld [hli],a
  ;speed
  ld a,[wCarShift]
  rlca
  ld d,a
  ld a,150
  sub d
  ld [hli],a
  ld a,8*13
  ld [hli],a
  ld a,24
  ld [hli],a
  ld a,0
  ld [hli],a
  ;car
  ld a,CarPosY
  ld [hli],a
  ld a,CarPosX
  ld [hli],a
  ld a,[bc]
  ld [hli],a
  inc c
  ld a,[bc]
  ld [hli],a
  inc c
  ld a,CarPosY
  ld [hli],a
  ld a,CarPosX+8
  ld [hli],a
  ld a,[bc]
  ld [hli],a
  inc c
  ld a,[bc]
  ld [hli],a

  mSetRivalCarSprite 0
  mSetRivalCarSprite 1
  mSetRivalCarSprite 2
  mSetRivalCarSprite 3

  mResetShadowOAM
  mCalcWSCX

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
  ld [wCarSprite],a

  mSetOAM

SetDashboardBG:
DBG1  EQU $99C0 ;Y14
DBG2  EQU $99E0 ; 15
DBG3  EQU $9A00 ; 16
DBG4  EQU $9A20 ; 17
BGNUM EQU 86

  xor a
  ldh [rVBK],a
  ; Lap time
  ;m
  ld a,[wLapTimeM]
  add a,BGNUM
  ld [DBG3+1],a
  ;s
  ld a,[wLapTimeS]
  ld d,a
  and %11110000
  ld e,a
  xor d
  add a,BGNUM
  ld [DBG3+4],a ;x0
  ld a,e
  swap a
  add a,BGNUM
  ld [DBG3+3],a ;1x
  ;ms
  ld a,[wLapTimeMS]
  ld d,a
  and %11110000
  ld e,a
  xor d
  add a,BGNUM
  ld [DBG3+6],a ;x0
  ld a,e
  swap a
  add a,BGNUM
  ld [DBG3+5],a ;1x

  ; Set Rival Car count
  ld a,[wRivalCnt]
  ld d,a
  and %11110000
  ld e,a
  xor d
  ld h,HIGH(CounterDBGTbl)
  rlca
  ld l,a
  ld a,[hli]
  ld [DBG2+10],a
  ld a,[hl]
  ld [DBG3+10],a
  ld a,e
  swap a
  ld h,HIGH(CounterDBGTbl)
  rlca
  ld l,a
  ld a,[hli]
  ld [DBG2+9],a
  ld a,[hl]
  ld [DBG3+9],a
  jp MainLoop

SetRivalCarSprite:
  ld a,[wRivalPosZ]
  ld c,a
  push hl
  ld h,HIGH(wRoadYUD)
  ld l,a
  ld a,[hl]
  ld [wRivalY],a
  ld a,[wRivalPosX]
  ld d,a
  and %00000111
  ld e,a
  xor d
  rrca
  rrca
  rrca
  add a,HIGH(ScrollLRTbl)
  ld h,a
  ld a,e
  rrca
  rrca
  rrca
  add a,c
  ld l,a
  ld a,[hl]
  pop hl
  ld e,a
  ld b,HIGH(wJoyPadXLR)
  ld a,[bc]
  add a,e
  ld e,a
  ld b,HIGH(wRoadXLR)
  ld a,[bc]
  add a,e
  ld e,a
  ;
  ld a,c
  rlca
  rlca
  ld bc,RivalCarTbl
  add a,c
  ld c,a

  ;ld a,[wRivalY]
  ;ld a,-10
  ;ld d,a
  ld a,[bc]
  ;sub d
  ld [wRivalY],a
  inc c
  ld a,[bc]
  sub e
  ld [wRivalX],a
  inc c
  ld a,[bc]
  ld d,a ;Tile Index
  ld a,[wCarSmoke]
  cp 0
  jr z,.nonSmoke
  ld a,2
  add a,d
  ld d,a
.nonSmoke
  inc c
  ld a,[bc]
  cp 0
  jr z,.skip
  ld a,[wRivalY]
  ld [hli],a
  ld a,[wRivalX]
  add a,8
  ld [hli],a
  ld [hl],d
  inc l
  ld a,[wRivalPal]
  or OAMF_XFLIP
  ld [hli],a
.skip
  ld a,[wRivalY]
  ld [hli],a
  ld a,[wRivalX]
  ld [hli],a
  ld [hl],d
  inc l
  ld a,[wRivalPal]
  ld [hli],a
  ret

SetWRam:
.loop
  ld [hli],a
  dec c
  jr nz,.loop
  ret

SetPalette:
.loop
  mSetPalette
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

DMARoutine:
  ldh [rDMA],a
  ld a,40
.loop
  dec a
  jr nz,.loop
  ret
DMARoutineEnd:

CopyDecompressionData:
  ;ld hl,<write address>
  ;ld de,<data address>
  ;ld bc,<data end address>
.start
  ld a,[de]
  inc de
  ld [hli],a
  push bc
.loop
  ld b,a
  ld a,[de]
  cp b
  jr z,.next
  inc de
  ld [hli],a
  jr .loop
.next
  inc de
  ld [hli],a
  ld a,[de]
  inc de
  sub 2
  cp 0
  jr z,.skip
  ld c,a
  ld a,b
.copy
  ld [hli],a
  dec c
  jr nz,.copy
.skip
  pop bc
  ld a,b
  cp d
  jr nz,.start
  ld a,c
  cp e
  jr nc,.start
  ret

INCLUDE "data.inc"
INCLUDE "wram.inc"