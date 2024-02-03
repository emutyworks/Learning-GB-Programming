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

MACRO mSetOAM
  ; call the DMA subroutine we copied to HRAM
  ; which then copies the bytes to the OAM and sprites begin to draw
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
  ld b,DMARoutineEnd - DMARoutine ; Number of bytes to copy
  ld c,LOW(hOAMDMA) ; Low byte of the destination address
.loop\@
  ld a,[hli]
  ldh [c],a
  inc c
  dec b
  jr nz,.loop\@
ENDM

MACRO mResetShadowOAM
  ld a,l
  rrca
  rrca
  ld c,a
  ld a,UseMaxOAM
  sub c
  cp 0
  jr z,.skip\@
  ld c,a
  xor a
.loop\@
  ld [hli],a
  ld [hli],a
  inc l
  inc l
  dec c
  jr nz,.loop\@
.skip\@
ENDM

MACRO mSetWaveGraphDot
  ;left dot
  ld a,[de]
  bit 0,a
  jr nz,.upperLDot\@
  ld b,%00000100
  jr .setLdot\@
.upperLDot\@
  ld b,%00001000
.setLdot\@
  and %00001110
  rrca
  add a,l
  ld l,a
  ld [hl],b
  ;right dot
  inc e
  ld a,[wWave2GraphAddrL]
  ld l,a
  ld a,[de]
  bit 0,a
  jr nz,.upperRDot\@
  ld b,%00000001
  jr .setRdot\@
.upperRDot\@
  ld b,%00000010
.setRdot\@
  and %00001110
  rrca
  add a,l
  ld l,a
  ld a,[hl]
  or b
  ld [hl],a
ENDM
