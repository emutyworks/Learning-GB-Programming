;GBSD_VENVELOPE EQU $C0
GBSD_ENVELOPE  EQU $C0
GBSD_OCTAVE    EQU $D0
GBSD_EMPTY     EQU $E0
GBSD_NOTE      EQU $F0
GBSD_ENDDATA   EQU $FF

InitSoundDriver:
  ;Create wMusicalScaleTbl
  ld bc,MusicalScaleTbl
  ld hl,wMusicalScaleTbl
  ld d,$ff
.next
  inc d
  ld a,[bc]
  ld e,a
  inc bc
.loop
  ld a,[bc] ;wavelength low
  ld [hli],a
  ld [hl],d ;wavelength high
  inc hl
  inc bc
  dec e
  jr nz,.loop
  ld a,d
  cp 7
  jr nz,.next

  ;Init registers
  ld a,%01110111
  ldh [rAUDVOL],a    ; -LLL-RRR Output level
  ld a,%11111111
  ldh [rAUDTERM],a   ; Sound output terminal
  ld a,%10000000
  ldh [rAUDENA],a    ; All sound on/off
  ld a,%00111111
  ldh [rAUD1LEN],a   ; Sound length/Wave pattern duty
  xor a
  ldh [rAUD1SWEEP],a ; Sweep register
  ldh [rAUD1ENV],a   ; Envelope
  ret

PlaySound:
.next
  ldh a,[hEmptyCnt]
  cp 0
  jr nz,.decEmpty
  ld a,[bc]
  cp GBSD_ENDDATA
  jr z,.endData
  inc bc
  cp GBSD_ENVELOPE
  jr z,.setEnvelope
  ld d,a
  and %00001111
  ld e,a ;low
  xor d
  ld d,a ;hi
  cp GBSD_NOTE
  jr z,.setNote
  cp GBSD_EMPTY
  jr z,.setEmpty
  cp GBSD_OCTAVE
  jr z,.setMusicalScalePos
  ; Set Note/Volume
  ldh a,[rAUD1ENV]
  and %00001111
  swap e
  or e
  ldh [rAUD1ENV],a
  swap d
  ld e,d
.setNote
  ld a,[hMusicalScalePos]
  add a,e
  ld h,HIGH(wMusicalScaleTbl)
  rlca
  ld l,a
  ld a,[hli]
  ldh [rAUD1LOW],a ; Frequency low byte
  ld a,[hli]
  or %10000000 ; Initial (when set, sound restarts)
  ldh [rAUD1HIGH],a ; Frequency high byte
  ret
.setMusicalScalePos
  ld d,HIGH(MusicalScalePosTbl)
  ld a,LOW(MusicalScalePosTbl)
  add a,e
  ld e,a
  ld a,[de]
  ldh [hMusicalScalePos],a
  jr .next
.setEnvelope
  ld a,[bc]
  inc bc
  ldh [rAUD1ENV],a
  ;ldh a,[rAUD1LEN]
  ;and %11000000
  ;ld d,a
  ;ld a,[bc]
  ;inc bc
  ;or d
  ;ldh [rAUD1LEN],a
  jr .next
.decEmpty
  dec a
  ldh [hEmptyCnt],a
  ret
.setEmpty
  ld a,e
  cp 0
  ret z
  ldh [hEmptyCnt],a
  ret
.endData
  ;xor a
  ;ldh [rAUD1ENV],a
  ret

MusicalScalePosTbl:
  db 0,12,24,36,48,60
