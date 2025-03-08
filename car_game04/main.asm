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
;  inc h ;wSCX
;  ld a,[hl]
;  ldh [rSCX],a
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
  ld c,4*4
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
  ld a,HIGH(RoadPosTbl)
  ld [wRoadHi],a
  ld hl,wRoadY
  ld de,RoadPosTbl
  ld bc,ScrollRoadSize
  call CopyData

  ; Init Scroll Position
  ld a,ScrollBaseX
  ldh [rSCX],a

  ; Init Car Data
  ld a,CarPosY
  ld [wPosY],a
  ld a,CarPosX
  ld d,a
  ld hl,wShadowOAM
  ld bc,CarSpriteTbl
  call InitSetCar

  ; Init Rival Car Data
  ld a,2
  ld [wRCarTbl],a
  ld a,SBX+8*10
  ld [wRCarTbl+1],a ; Rcar X Pos

MainLoop:
  ld a,[wMainLoopFlg]
  cp 1
  jp z,SetOAM

  ; Set Tire reflection
  ld a,[wCarTireCnt]
  inc a
  and %00000011
  ld [wCarTireCnt],a
  and %00000010
  ld [wCarTireRef],a

SetRoadScroll:
  ld a,[wRoadCnt]
  inc a
  and %00000000 ; Scroll Speed
  ld [wRoadCnt],a
  cp 0
  jp nz,SetCarSprite
  ld a,[wRoadLo]
  add a,$40
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
  mSetCarTire

  ld a,[wRCarTbl]
  rlca
  rlca
  rlca
  ld b,HIGH(RCarTireTbl)
  ld c,a
  ld a,[wRCarTbl+1] ; Rcar X Pos
  ld d,a
  call SetRCarTire

  ld a,[wRCarTbl]
  rlca
  rlca
  rlca
  ld b,HIGH(RCarSpriteTbl)
  ld c,a
  call SetRCar

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

SetRCarTire:
  mSetRCarTire
  ret

SetRCar:
  mSetRCar
  ret

InitSetCar:
  mInitSetCar
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

INCLUDE "data.inc"
INCLUDE "wram.inc"