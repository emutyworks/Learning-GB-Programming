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
  ld c,ScrollMaxSize
  call SetWRam
  ld hl,wSCX
  ld c,ScrollMaxSize
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
  ;ld a,22
  ;ld [wRCarYPosTbl],a
  ;ld a,8*9
  ;ld [wRCarXPos],a
  ;ld a,13
  ;ld [wJoyPadPos],a

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
  ld a,[wRCarTblCnt]
  inc a
  and %00000011
  ld [wRCarTblCnt],a
  cp 0
  jp nz,Joypad
  ld a,[wRCarYPosTbl]
  inc a
  and %00011111
  ld [wRCarYPosTbl],a

Joypad:
  mCheckJoypad
  ld a,[wJoypad]
  bit JBitRight,a
  jp nz,SetCarRight
  bit JBitLeft,a
  jp nz,SetCarLeft

  ; set Car Pos
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
  jr z,SetWJoyPadXLR
  inc a
  ld [wJoyPadPos],a
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
  mCopyScrollRoad

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
  mCopyScrollRoad

SetCarSprite:
  ld b,HIGH(CarSpriteTbl)
  ld e,3 ; draw OAM cnt
  ld a,[wCarPos]
  cp CarPosCenter
  jr z,.setCar0
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

.setCar0
  dec e
  rlca
  rlca
  rlca
  rlca
  ld c,a

.setCar
  mSetCar

  ; Calc Rcar X Pos
  ld a,[wRCarYPosTbl]
  ld c,a
  ld a,[wJoyPadPos]
  ld d,a
  and %00001000
  ld e,a
  xor d
  swap a
  rlca
  add a,c
  ld c,a
  ld a,e
  swap a
  rlca
  or %00100000
  ld b,a
  ld a,[bc]
  ld [wRCarXPos],a

  ld b,HIGH(RCarYPosTbl)
  ld a,[wRCarYPosTbl]
  rlca
  ld c,a
  ld a,[bc]
  ld [wRCarYPos],a
  inc c
  ld a,[bc]
  rlca
  rlca
  rlca
  rlca
  inc b
  ld c,a
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