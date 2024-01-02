; - Generating "sound_data_tbl.inc".
; php tools/convDMF2Hex.php tools/test.dmf
;
; - Data format
; $C0,$xx: Set Envelope
; $CF: End of data
; $D0-$D5: Set Octave (2-7)
; $E0-$Ef: Set Empty (1-16)
; $xx: Set Volume/Note
;  |+ $0-$f Volume (0-15)
;  +- $0-$b Note (C,C#,D,D#,E,F,F#,G,G#,A,A#,B)
; $F0-$Fb: Set Note
;
; *Total 142 bytes of data.
SQ1SoundDataTbl:
  db $Ef
  db $Ef
  db $Ef
  db $Ef
  db $E7
  db $CF

SQ2SoundDataTbl:
  db $Ef
  db $Ef
  db $Ef
  db $Ef
  db $E7
  db $CF

; - Data format
; $CF: End of data
; $D0-$D5: Set Octave (2-7)
; $E0-$Ef: Set Empty (1-16)
; $F0-$Fb: Set Note (C,C#,D,D#,E,F,F#,G,G#,A,A#,B)
WavSoundDataTbl:
  db $Ef
  db $Ef
  db $Ef
  db $Ef
  db $E7
  db $CF

WaveData:
  db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00

; - Data format
; $C0,$xx: Set Envelope
; $CF: End of data
; $D0-$Df: Set LFSR width + Clock divider (0-15)
; $E0-$Ef: Set Empty (1-16)
; $F0-$Ff: Set Clock shift (0-15)
NoiSoundDataTbl:
  db $C0,$91
  db $D4
  db $F0
  db $E0
  db $F0
  db $E0
  db $F0
  db $E0
  db $F0
  db $E0
  db $F0
  db $F0
  db $D8
  db $F0
  db $D4
  db $F0
  db $F0
  db $F0
  db $D8
  db $F0
  db $D4
  db $F0
  db $F0
  db $F0
  db $D8
  db $F0
  db $D4
  db $F0
  db $F0
  db $F0
  db $D8
  db $F0
  db $D4
  db $F0
  db $F0
  db $F0
  db $D8
  db $F0
  db $D4
  db $F0
  db $F0
  db $F0
  db $D8
  db $F0
  db $D4
  db $F0
  db $F0
  db $F0
  db $D8
  db $F0
  db $D4
  db $F0
  db $F0
  db $F0
  db $D8
  db $F0
  db $D4
  db $F0
  db $F0
  db $F0
  db $D8
  db $F0
  db $D4
  db $F0
  db $F0
  db $F0
  db $D8
  db $F0
  db $D4
  db $F0
  db $F0
  db $F0
  db $D8
  db $F0
  db $D4
  db $F0
  db $F0
  db $F0
  db $D8
  db $F0
  db $D4
  db $F0
  db $F0
  db $F0
  db $D8
  db $F0
  db $D4
  db $F0
  db $F0
  db $F0
  db $D8
  db $F0
  db $D4
  db $F0
  db $F0
  db $F0
  db $D8
  db $F0
  db $D4
  db $F0
  db $F0
  db $F0
  db $D8
  db $F0
  db $D4
  db $F0
  db $CF
