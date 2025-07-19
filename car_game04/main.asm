;
; I used this Website/Document as a reference to create it.
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
; Run-length encoding
; https://en.wikipedia.org/wiki/Run-length_encoding
;

INCLUDE "hardware.inc"
INCLUDE "equ.inc"
INCLUDE "macro.inc"
INCLUDE "car_macro.inc"

SECTION "VBlank Handler",ROM0[$40]
  push af
  ld a,1
  ld [wVBlankDone],a
  pop af
  reti

SECTION  "HBlank Handler",ROM0[$48]
HBlankHandler:
  push af
  push hl
  ld h,HIGH(wSCY)
  ldh a,[rLY]
  ld l,a
  ld a,[hl]
  ldh [rSCY],a
  inc h ;wSCX
  ld a,[hl]
  ldh [rSCX],a

  ; Set Palette
  ld a,%10000000+2
  ldh [rBCPS],a

  inc h ;wSCP
  ld a,[hl]
  cp 1
  jr nz,.roadPalette

.linePalette
  ld hl,rBCPD
  ld [hl],$ff
  ld [hl],$03
  jr .reset

.roadPalette
  ld hl,rBCPD
  ld [hl],$8c
  ld [hl],$31

.reset
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
  mCopyDMARoutine ; Move DMA subroutine to HRAM
  mWaitVBlank

  ; Set Palette
  ld a,%10000000
  ldh [rBCPS],a
  ld c,4*4
  ld hl,BGPalette
  ld de,rBCPD
  call SetPalette
  ld a,%10000000
  ldh [rOCPS],a
  ld c,4*5
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
  ; Init Work RAM
  ld hl,State
  ld c,StateEnd - State
  call SetWRam
  ld hl,wSCY
  ld c,$ff
  call SetWRam
  ld hl,wSCX
  ld c,$ff
  call SetWRam
  ld hl,wSCP
  ld c,$ff
  call SetWRam

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

  ld a,LCDCF_ON|LCDCF_OBJON|LCDCF_BGON|LCDCF_OBJ16
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

  ; Init Road data
  ld a,HIGH(RoadYPosTbl)
  ld [wRoadHi],a
  ld hl,wRoadY
  ld de,RoadYPosTbl
  ld bc,ScrollRoadSize
  call CopyData

  ; Init Car data
  ld a,CarPosCenter
  ld [wCarPos],a
  ld a,CarPosWait
  ld [wCarPosWait],a

  ; Set Joypad
  ld a,JoypadWait
  ld [wJoypadWait],a
  ld a,8  ; L 1-7|8|9-15 R
  ld [wJoyPadPos],a

  ; test
  ;ld a,0
  ;ld a,2
  ;ld a,6
  ;ld a,9
  ;ld a,13
  ;ld a,18
  ;ld a,23
  ;ld [wRCarYPosTbl],a
  ;ld a,1
  ;ld [wJoyPadPos],a
  ld a,8
  ld [wRCarXPos],a
  ;ld a,2
  ;ld [wCarPos],a

MainLoop:
  ld a,[wMainLoopFlg]
  cp 1
  jp z,SetOAM

  ; Set Tire reflection
  ld a,[wCarTireCnt]
  inc a
  and %00011111
  ld [wCarTireCnt],a
  and %00000010
  ld [wCarTireRef],a

  ;test: Set Rival Car Y Position
  ld a,[wRCarTblWait]
  inc a
  and %00000011
  ld [wRCarTblWait],a
  cp 0
  jp nz,SetFinishLine
  ld a,[wRCarYPosTbl]
  inc a
  and %00111111
  ld [wRCarYPosTbl],a

SetFinishLine: ;test
  ld a,[wFinishLineCnt]
  cp 0
  jp nz,.decCnt

  ld a,[wFinishLineWait]
  inc a
  and %00000011
  ld [wFinishLineWait],a
  cp 0
  jp nz,Joypad
  ld a,[wFinishLinePos]
  inc a
  cp 13
  jr c,.setPos1
  inc a
  and %00111111
  ld [wFinishLinePos],a
  cp 0
  jr z,.resetCnt

  ld hl,wRoadP
  add a,l
  ld l,a
  xor a
  ld [hli],a
  ld [hli],a
  ld a,1
  ld [hli],a
  ld [hli],a
  jr Joypad

.setPos1
  and %00111111
  ld [wFinishLinePos],a
  cp 63
  jr z,.resetCnt

  ld hl,wRoadP
  add a,l
  ld l,a
  xor a
  ld [hli],a
  ld [hli],a
  ld a,1
  ld [hli],a
  jr Joypad

.resetCnt
  ld a,FinishLineCnt
  ld [wFinishLineCnt],a
  jr Joypad

.decCnt
  dec a
  ld [wFinishLineCnt],a

Joypad:
  mCheckJoypad
  ld a,[wJoypad]
  bit JBitRight,a
  jp nz,SetCarRight
  bit JBitLeft,a
  jp nz,SetCarLeft

  ; Set Car Pos
  ld a,[wCarPosWait]
  cp 0
  jr nz,.decWait
  ld a,[wCarPos]
  cp CarPosCenter
  jr z,.reset
  jr c,.incPos
.decPos
  dec a
  jr .setPos
.incPos
  inc a
.setPos
  ld [wCarPos],a
.reset
  ld a,CarPosWait
  ld [wCarPosWait],a
  jr .next
.decWait
  dec a
  ld [wCarPosWait],a
.next
  ld a,[wJoyPadPos]
  jp SetWJoyPadXLR

SetCarRight:
  ld a,[wCarPosWait]
  cp 0
  jr nz,.decWait
  ld a,[wCarPos]
  cp CarPosRightMin
  jr z,.resetWait
  dec a
  ld [wCarPos],a
.resetWait
  ld a,CarPosWait
  ld [wCarPosWait],a
  jr .skip
.decWait
  dec a
  ld [wCarPosWait],a
.skip
  mJoypadWait
  ld a,[wJoyPadPos]
  cp JoypadRightMax
  jp z,SetWJoyPadXLR
  inc a
  ld [wJoyPadPos],a
  ld d,a
  ; Scroll BG
  ld hl,wBgX
  ld a,[hl]
  inc a
  mFillHl 8
  ld a,[hl]
  add a,2
  mFillHl 8
  ld a,[hl]
  add a,4
  mFillHl 8
  ld a,d
  jr SetWJoyPadXLR

SetCarLeft:
  ld a,[wCarPosWait]
  cp 0
  jr nz,.decWait
  ld a,[wCarPos]
  cp CarPosLeftMax
  jr z,.resetWait
  inc a
  ld [wCarPos],a
.resetWait
  ld a,CarPosWait
  ld [wCarPosWait],a
  jr .skip
.decWait
  dec a
  ld [wCarPosWait],a
.skip
  mJoypadWait
  ld a,[wJoyPadPos]
  cp JoypadLeftMin
  jr z,SetWJoyPadXLR
  dec a
  ld [wJoyPadPos],a
  ld d,a
  ; Scroll BG
  ld hl,wBgX
  ld a,[hl]
  dec a
  mFillHl 8
  ld a,[hl]
  sub 2
  mFillHl 8
  ld a,[hl]
  sub 4
  mFillHl 8
  ld a,d

SetWJoyPadXLR:
  ld d,a
  and %00001100
  ld e,a
  xor d
  rrca
  rrca
  ld l,a
  ld a,e
  rrca
  rrca
  or %01000000
  ld h,a
  ld de,wRoadX
  mCopyHlToDe ScrollRoadSize-1

SetRoadScroll:
  ld a,[wRoadCnt]
  inc a
  and %00000000 ; Scroll Speed
  ld [wRoadCnt],a
  cp 0
  jp nz,SetCarSprite
  ld a,[wRoadLo]
  ;add a,$40
  add a,$80
  ld [wRoadLo],a
  cp 0
  jr nz,.setRoad
  ld a,[wRoadHi]
  inc a
  and %11110001
  ld [wRoadHi],a
.setRoad
  ld a,[wRoadHi]
  ld h,a
  ld a,[wRoadLo]
  ld l,a
  ld de,wRoadY
  mCopyHlToDe ScrollRoadSize-1

SetCarSprite:
  ld b,HIGH(CarSpriteTbl)
  ld e,3 ; Draw OAM cnt
  ld a,[wCarPos]
  cp CarPosCenter
  jr z,.setCenter
  rlca
  rlca
  rlca
  rlca
  ld c,a
  ld a,[wCarTireRef]
  cp 0
  jr z,.setCar
  ld a,3
  add a,c
  ld c,a
  dec e
  jr .setCar

.setCenter
  dec e
  rlca
  rlca
  rlca
  rlca
  ld c,a

.setCar
  mSetCar
  mSetRCar 0

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

SetPalette:
  mSetPalette
  ret

SetWRam:
  mSetWRam
  ret

CopyData:
  mCopyData
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
  mCopyDecompressionData
  ret

INCLUDE "data.inc"
INCLUDE "wram.inc"