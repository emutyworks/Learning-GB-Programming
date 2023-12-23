;GBSD_VENVELOPE EQU $C0
GBSD_ENVELOPE EQU $C0
GBSD_OCTAVE    EQU $D0
GBSD_EMPTY     EQU $E0
GBSD_NOTE      EQU $F0
GBSD_ENDDATA   EQU $FF

InitSoundData:
  ld bc,SoundDataTbl
  ld hl,wSoundDataTbl
.next
  ld a,[bc]
  inc bc
  cp GBSD_ENDDATA
  jr z,.setEndData
  cp GBSD_ENVELOPE
  jr z,.setEnvelope
  ld d,a
  and %00001111
  ld e,a ;low
  xor d
  ld d,a ;hi
  cp GBSD_OCTAVE
  jr z,.setMusicalScalePos
  cp GBSD_NOTE
  jr z,.setNote
  cp GBSD_EMPTY
  jr z,.setEmpty
  ; Set Note/Volume
  ld a,[wMusicalScalePos]
  swap d
  add a,d
  ld [hli],a
  ld a,e
  swap a
  ld [hli],a
  jr .next
.setNote
  ld a,[wMusicalScalePos]
  add a,e
  or %10000000
  ld [hli],a
  jr .next
.setMusicalScalePos
  ld d,HIGH(MusicalScalePosTbl)
  ld a,LOW(MusicalScalePosTbl)
  add a,e
  ld e,a
  ld a,[de]
  ld [wMusicalScalePos],a
  jr .next
.setEnvelope
  ld [hli],a
  ld a,[bc]
  inc bc
  ld [hli],a
  ;ld a,[bc]
  ;inc bc
  ;ld [hli],a
  jr .next
.setEmpty
  or e
  ld [hli],a
  jr .next
.setEndData
  ld [hl],GBSD_ENDDATA
  ret

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
  ; - Data format
  ; $C0,$xx: Set Envelope
  ; $E0-$Ef: Set Empty (1-16)
  ; %7xxxxxxx or 0-71: Set Musical scale
  ; 0-71,$00-$f0: Set Note/Volume
  ; $FF: End of data
.next
  ldh a,[hEmptyCnt]
  cp 0
  jr nz,.decEmpty
  ld a,[bc]
  cp GBSD_ENDDATA
  jr z,.endData
  cp GBSD_ENVELOPE
  jr z,.setEnvelope
  ld d,a
  and %00001111
  ld e,a ;low
  xor d
  ld d,a ;hi
  cp GBSD_EMPTY
  jr z,.setEmpty
  bit 7,a
  jr nz,.setMScale
  ; Set Note/Volume
  inc bc
  and %0111000
  or e
  ld h,HIGH(wMusicalScaleTbl)
  rlca
  ld l,a
  ld a,[hli]
  ldh [rAUD1LOW],a ; Frequency low byte
  ld a,[hli]
  or %10000000 ; Initial (when set, sound restarts)
  ldh [rAUD1HIGH],a ; Frequency high byte
  ld a,[bc]
  inc bc
  ld d,a
  ldh a,[rAUD1ENV]
  or d
  ldh [rAUD1ENV],a
  ret
.setMScale
  inc bc
  and %0111000
  or e
  ld h,HIGH(wMusicalScaleTbl)
  rlca
  ld l,a
  ld a,[hli]
  ldh [rAUD1LOW],a ; Frequency low byte
  ld a,[hli]
  or %10000000 ; Initial (when set, sound restarts)
  ldh [rAUD1HIGH],a ; Frequency high byte
  ret
.setEmpty
  inc bc
  ld a,e
  cp 0
  ret z
  ldh [hEmptyCnt],a
  ret
.decEmpty
  dec a
  ldh [hEmptyCnt],a
  ret
.setEnvelope
  inc bc
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
.endData
  xor a
  ;ldh [rAUD1ENV],a
  ret

MusicalScalePosTbl:
  db 0,12,24,36,48,60
