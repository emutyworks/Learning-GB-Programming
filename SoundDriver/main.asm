;
; I used this Website/Document as a reference to create it.
;
; Z80 1バイトデータの分解 (Z80 1-byte data decomposition)
; https://codeknowledge.livedoor.blog/archives/25232135.html
;
; Lesson P21 - Sound on the Gameboy and GBC
; https://www.chibiakumas.com/z80/platform3.php#LessonP21
; https://www.youtube.com/watch?v=LCPLGkYJk5M
;
; Pan Docs
; https://gbdev.io/pandocs/
;

INCLUDE "hardware.inc"

SoundWait EQU 20

SECTION "VBlank Handler",ROM0[$40]
  push af
  ld a,1
  ld [wVBlankDone],a
  pop af
  reti

SECTION "Header",ROM0[$100]

EntryPoint:
  di
  jp Start

REPT $150 - $104
  db 0
ENDR

SECTION "Start",ROM0[$150]

Start:
  xor a
  ldh [rLCDC],a
  ldh [rIE],a
  ldh [rIF],a
  ldh [rSCY],a
  ldh [rSCX],a
  ldh [hMusicalScalePos1],a
  ldh [hMusicalScalePos2],a
  ldh [hMusicalScalePos3],a
  ldh [hEmptyCnt1],a
  ldh [hEmptyCnt2],a
  ldh [hEmptyCnt3],a
  ld [wVBlankDone],a
  ld [wSoundWait],a

  ld a,LCDCF_ON
  ldh [rLCDC],a

  ld a,IEF_VBLANK
  ldh [rIE],a
  xor a
  ei
  ldh [rIF],a

  ; Set Sound driver
  call InitSoundDriver
  ld a,SoundWait
  ld [wSoundWait],a

MainLoop:
  ld a,[wVBlankDone]
  cp 1
  jp nz,MainLoop
  xor a
  ld [wVBlankDone],a

  ld a,[wSoundWait]
  cp 0
  jr z,.playSound
  dec a
  ld [wSoundWait],a
  jp MainLoop

.playSound
  call PlaySound
  ld a,SoundWait
  ld [wSoundWait],a

  jp MainLoop

INCLUDE "gbsd.inc"

SECTION "State",WRAM0
wMusicalScaleTbl: ds 144
wSoundWait: ds 1
wVBlankDone: ds 1
wSQ1SoundData: ds 2
wSQ2SoundData: ds 2
wWavSoundData: ds 2

SECTION "HRAM Variables",HRAM
hMusicalScalePos1: ds 1
hMusicalScalePos2: ds 1
hMusicalScalePos3: ds 1
hEmptyCnt1: ds 1
hEmptyCnt2: ds 1
hEmptyCnt3: ds 1
