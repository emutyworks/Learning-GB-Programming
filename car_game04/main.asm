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
INCLUDE "road_pattern_macro.inc"

SECTION "VBlank Handler",ROM0[$40]
  push af
  ; Call the DMA subroutine we copied to HRAM
  ; Which then copies the bytes to the OAM and sprites begin to draw
  ld a,HIGH(wShadowOAM)
  call hOAMDMA
  pop af
  reti

SECTION  "HBlank Handler",ROM0[$48]
  push af
  push hl
  ld h,HIGH(wSCY)
  ldh a,[rLY]
  ld l,a
  ld a,[hl]
  ldh [rSCY],a
  inc h ; wSCX
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
  mCopyDMARoutine ; Move DMA subroutine to HRAM
  mWaitVBlank

  ; Init Palette
  ld a,%10000000
  ldh [rBCPS],a
  ld c,4*4
  ld hl,BGPalette
  ld de,rBCPD
  call SetPalette
  ld a,%10000000
  ldh [rOCPS],a
  ld c,4*3
  ld hl,ObjPalette
  ld de,rOCPD
  call SetPalette

  xor a
  ldh [rLCDC],a
  ldh [rIE],a
  ldh [rIF],a
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

  ;mSetRomBank 2

  ; Init Sprites/Tiles data
  ld hl,_VRAM ;$8000
  ld de,Sprites
  ld bc,SpritesEnd-1
  call CopyDecompressionData
  ld hl,_VRAM+$1000 ;$9000
  ld de,Tiles
  ld bc,TilesEnd-1
  call CopyDecompressionData

  ; Init Map data
  ld a,1
  ldh [rVBK],a ; BG Map Attr
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

  ;mSetRomBank 1

  ld a,LCDCF_ON|LCDCF_OBJON|LCDCF_BGON|LCDCF_OBJ16
  ldh [rLCDC],a
  mInitwShadowOAM

  ; Init up the lcdc int
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
  ld a,ScrollWait
  ld [wScrollWait],a
  ld [wRoadCnt],a
  ld a,TurnPosCenter
  ld [wTurnPos],a

  ; Init Car data
  call SetCarSpriteTbl
  ld a,CarPosCenter
  ld [wCarPos],a
  ld a,CarPosWait
  ld [wCarPosWait],a

  ; Init Joypad
  ld a,JoypadWait
  ld [wJoypadWait],a
  ld a,8 ; L 1-7|8|9-15 R
  ld [wJoyPadPos],a

MainLoop:
  mRoadPCnt

SetRoadPTbl:
  mSetRoadPTbl

NextLoop:
  mTireReflection

Joypad:
  mCheckJoypad
  ld a,[wJoypad]
  bit JBitRight,a
  jp nz,SetCarRight
  bit JBitLeft,a
  jp nz,SetCarLeft

SetCarPos:
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
  ld [wCarPos],a ;test
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
  jp z,WaitScrollBG
  inc a ;test
  ld [wJoyPadPos],a
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
  jp z,WaitScrollBG
  dec a ;test
  ld [wJoyPadPos],a
  ; Scroll BG ;248
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

SetWJoyPadXLR: ;1236
  ld a,[wJoyPadPos]
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
  or %01111100
  ld h,a
  ld de,wJoyPadXLR
  mCopyHlToDe ScrollRoadSize
  jr SetRoadScroll

WaitScrollBG:
  ld a,119 ; 12*119+60=1488
  call AdjustWaitA

SetRoadScroll:
  ld a,[wRoadCnt]
  dec a
  ld [wRoadCnt],a
  cp 0
  jp nz,SetCarSprite
  ld a,[wScrollWait]
  ld [wRoadCnt],a
  ld a,[wRoadLo]
  add a,$40
  ld [wRoadLo],a
  cp 0
  jr nz,.setRoad
  ld a,[wRoadHi]
  inc a
  and %01111001 ; $78-$79
  ld [wRoadHi],a
.setRoad
  ld a,[wRoadHi]
  ld h,a
  ld a,[wRoadLo]
  ld l,a
  ld de,wRoadY
  mCopyHlToDe ScrollRoadSize ;test

SetCarSprite:
  ld b,HIGH(wCarSpriteTbl)
  ld a,[wCarPos]
  rrca
  rrca
  rrca
  ld c,a
  mSetCar
  mCalcWSCX

  jp MainLoop

SetCarSpriteTbl:
  mSetCarSpriteTbl
  ret

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

  ;ld a,5 ;8
  ;call AdjustWaitA ;24
AdjustWaitA:
  dec a ;4
  jr nz,AdjustWaitA ;12/8 ; 1 loop = 4+8
  ret ;16 ; 8+24+12+16 = 60

INCLUDE "road_pattern.inc"
INCLUDE "data.inc"
INCLUDE "wram.inc"