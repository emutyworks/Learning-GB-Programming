GBSD_ENVELOPE  EQU $C0
GBSD_OCTAVE    EQU $D0
GBSD_DIVIDER   EQU $D0
GBSD_EMPTY     EQU $E0
GBSD_NOTE      EQU $F0
GBSD_SHIFT     EQU $F0
GBSD_ENDDATA   EQU $CF

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
  ld a,HIGH(WavSoundDataTbl)
  ld [wWavSoundData],a
  ld a,LOW(WavSoundDataTbl)
  ld [wWavSoundData+1],a
  ld a,HIGH(NoiSoundDataTbl)
  ld [wNoiSoundData],a
  ld a,LOW(NoiSoundDataTbl)
  ld [wNoiSoundData+1],a

  call SetWaveData

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
  ld a,%10000000
  ldh [rAUDENA],a    ; All sound on/off
  ldh [rAUD3ENA],a   ; Sound on/off
  ld a,%01110111
  ldh [rAUDVOL],a    ; -LLL-RRR Output level
  ld a,%11111111
  ldh [rAUDTERM],a   ; Sound output terminal
  ld a,%00100000
  ldh [rAUD3LEVEL],a ; Select output level
  ld a,%00111111
  ldh [rAUD1LEN],a   ; Sound length/Wave pattern duty
  ldh [rAUD2LEN],a
  ldh [rAUD4LEN],a   ;Sound length
  ld a,%11111111
  ldh [rAUD3LEN],a
  xor a
  ldh [rAUD1SWEEP],a ; Sweep register
  ldh [rAUD1ENV],a   ; Envelope
  ldh [rAUD2ENV],a
  ldh [rAUD4ENV],a
  ret

PlaySound:
  mSetSQxSoundData 1
  mSetSQxSoundData 2
  mSetWavSoundData
  mSetNoiSoundData
  ret

SetWaveData:
  ld hl,_AUD3WAVERAM
  ld de,WaveData
  ld c,16
.loop
  ld a,[de]
  ld [hli],a
  inc de
  dec c
  jr nz,.loop
  ret

INCLUDE "gbsd_musical_scale_tbl.inc"
INCLUDE "gbsd_sound_data_tbl.inc"

MusicalScalePosTbl:
  db 0,12,24,36,48,60