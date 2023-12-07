;
; I used this Website/Document as a reference to create it.
;
; Lesson P21 - Sound on the Gameboy and GBC
; https://www.chibiakumas.com/z80/platform3.php#LessonP21
; https://www.youtube.com/watch?v=LCPLGkYJk5M
;
; Pan Docs
; https://gbdev.io/pandocs/
;

INCLUDE "hardware.inc"

SoundWait EQU 30 ; 120 bpm

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
	ld [wVBlankDone],a
	ld [wSoundWait],a
	ld [wTestLoop],a

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
	ld a,[wTestLoop]
	cp 72
	jr z,MainLoop

	ld a,SoundWait
	ld [wSoundWait],a
	call PlaySound

	ld a,[wTestLoop]
	inc a
	ld [wTestLoop],a

	jp MainLoop

INCLUDE "gb_sound_driver.inc"

SECTION "State",WRAM0
wVBlankDone: ds 1
wSoundWait: ds 1
wTestLoop: ds 1