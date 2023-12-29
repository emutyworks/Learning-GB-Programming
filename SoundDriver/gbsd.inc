;GBSD_VENVELOPE EQU $C0
GBSD_ENVELOPE  EQU $C0
GBSD_OCTAVE    EQU $D0
GBSD_EMPTY     EQU $E0
GBSD_NOTE      EQU $F0
GBSD_ENDDATA   EQU $FF

INCLUDE "gbsd_macro.inc"

InitSoundDriver:
  ld a,HIGH(SQ1SoundDataTbl)
  ld [wSQ1SoundData],a
  ld a,LOW(SQ1SoundDataTbl)
  ld [wSQ1SoundData+1],a
  ld a,HIGH(SQ2SoundDataTbl)
  ld [wSQ2SoundData],a
  ld a,LOW(SQ2SoundDataTbl)
  ld [wSQ2SoundData+1],a

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
  ldh [rAUD2LEN],a
  xor a
  ldh [rAUD1SWEEP],a ; Sweep register
  ldh [rAUD1ENV],a   ; Envelope
  ldh [rAUD2ENV],a
  ret

PlaySound:
  mSetSoundData 1
  mSetSoundData 2
  ret

INCLUDE "gbsd_musical_scale_tbl.inc"
INCLUDE "gbsd_sound_data_tbl.inc"

MusicalScalePosTbl:
  db 0,12,24,36,48,60