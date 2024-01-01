; - Generating "sound_data_tbl.inc".
; php tools/convDMF2Hex.php tools/test.dmf
;
; - Data format
; $C0,$xx: Set Envelope
; $D0-$D5: Set Octave (2-7)
; $E0-$Ef: Set Empty (1-16)
; $xx: Set Volume/Note
;  |+ $0-$f Volume (0-15)
;  +- $0-$b Note (C,C#,D,D#,E,F,F#,G,G#,A,A#,B)
; $F0-$Fb: Set Note
; $FF: End of data
;
; *Total 78 bytes of data.
SQ1SoundDataTbl:
  db $Ef ; Set Empty
  db $Ef ; Set Empty
  db $Ef ; Set Empty
  db $FF

SQ2SoundDataTbl:
  db $Ef ; Set Empty
  db $Ef ; Set Empty
  db $Ef ; Set Empty
  db $FF

; - Data format
; $D0-$D5: Set Octave (2-7)
; $E0-$Ef: Set Empty (1-16)
; $F0-$Fb: Set Note (C,C#,D,D#,E,F,F#,G,G#,A,A#,B)
; $FF: End of data
WavSoundDataTbl:
  db $D3 ; Set Octave
  db $F4
  db $F3
  db $F4
  db $F3
  db $F4
  db $D2 ; Set Octave
  db $Fb
  db $D3 ; Set Octave
  db $F2
  db $F0
  db $D2 ; Set Octave
  db $F9
  db $E1 ; Set Empty
  db $F0
  db $F4
  db $F9
  db $Fb
  db $E1 ; Set Empty
  db $F4
  db $F8
  db $Fb
  db $D3 ; Set Octave
  db $F0
  db $D2 ; Set Octave
  db $E1 ; Set Empty
  db $F4
  db $D3 ; Set Octave
  db $F4
  db $F3
  db $F4
  db $F3
  db $F4
  db $D2 ; Set Octave
  db $Fb
  db $D3 ; Set Octave
  db $F2
  db $F0
  db $D2 ; Set Octave
  db $F9
  db $E1 ; Set Empty
  db $F0
  db $F4
  db $F9
  db $Fb
  db $E1 ; Set Empty
  db $F4
  db $D3 ; Set Octave
  db $F0
  db $D2 ; Set Octave
  db $Fb
  db $F9
  db $E2 ; Set Empty
  db $FF

WaveData:
  db $7d,$b8,$bd,$a7,$bf,$d8,$ab,$73,$7c,$73,$46,$20,$37,$41,$36,$31
WaveDataEnd: