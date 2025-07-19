MACRO mCheckJoypad
  ;wJoypad
  ;%76543210
  ; |||||||+ Right
  ; ||||||+- Left
  ; |||||+-- Up
  ; ||||+--- Down
  ; |||+---- A
  ; ||+----- B
  ; |+------ Select
  ; +------- Start
  ld a,P1F_4
  ldh [rP1],a ; Select P14
  ldh a,[rP1]
  ldh a,[rP1] ; Wait a few cycles
  cpl ; Complement A
  and %00001111 ; Get only first 4 bits
  swap a
  ld b,a
  ld a,P1F_5
  ldh [rP1],a ; Select P15
  ldh a,[rP1]
  ldh a,[rP1]
  ldh a,[rP1]
  ldh a,[rP1]
  ldh a,[rP1]
  ldh a,[rP1] ; Wait a few MORE cycles
  cpl
  and %00001111
  or a,b ; Put A and B together
  ld [wJoypad],a
  ld a,P1F_4|P1F_5 ; Deselect P14 and P15.
  ldh [rP1],a
ENDM

MACRO mWaitVBlank
.loop\@
  ldh a,[rLY]
  cp SCRN_Y ; 144 ; Check if the LCD is past VBlank
  jr nz,.loop\@
ENDM

MACRO mSetOAM
  ; Call the DMA subroutine we copied to HRAM
  ; Which then copies the bytes to the OAM and sprites begin to draw
  ld a,HIGH(wShadowOAM)
  call hOAMDMA
ENDM

MACRO mInitwShadowOAM
  ld hl,wShadowOAM
  ld c,4*40
  xor a
.loop\@
  ld [hli],a
  dec c
  jr nz,.loop\@
ENDM

MACRO mCopyDMARoutine
  ld hl,DMARoutine
  ld b,DMARoutineEnd - DMARoutine
  ld c,LOW(hOAMDMA)
.loop\@
  ld a,[hli]
  ldh [c],a
  inc c
  dec b
  jr nz,.loop\@
ENDM

MACRO mSetWRam
.loop\@
  ld [hli],a
  dec c
  jr nz,.loop\@
ENDM

MACRO mSetPalette
.loop\@
  ld a,[hli]
  ld [de],a
  ld a,[hli]
  ld [de],a
  dec c
  jr nz,.loop\@
ENDM

MACRO mCopyDecompressionData
  ;ld hl,<write address>
  ;ld de,<data address>
  ;ld bc,<data end address>
.start\@
  ld a,[de]
  inc de
  ld [hli],a
  push bc
.loop\@
  ld b,a
  ld a,[de]
  cp b
  jr z,.next\@
  inc de
  ld [hli],a
  jr .loop\@
.next\@
  inc de
  ld [hli],a
  ld a,[de]
  inc de
  sub 2
  cp 0
  jr z,.skip\@
  ld c,a
  ld a,b
.copy\@
  ld [hli],a
  dec c
  jr nz,.copy\@
.skip\@
  pop bc
  ld a,b
  cp d
  jr nz,.start\@
  ld a,c
  cp e
  jr nc,.start\@
ENDM

MACRO mCopyData
.loop\@
  ld a,[de]
  ld [hli],a
  inc de
  dec bc
  ld a,b
  or c
  jr nz,.loop\@
ENDM

MACRO mCopyHlToDe
REPT \1
  ld a,[hli]
  ld [de],a
  inc e
ENDR
  ld a,[hl]
  ld [de],a
ENDM

MACRO mFillHl
REPT \1
  ld [hli],a
ENDR
ENDM