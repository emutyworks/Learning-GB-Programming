InitSoundDriver:
	ld a,%01110111     ; -LLL-RRR Master volume & VIN panning
	ldh [rAUDVOL],a
	ld a,%11111111     ; LLLLRRRR Sound panning
	ldh [rAUDTERM],a
	ld a,%10000000     ; x------- Sound on/off
	ldh [rAUDENA],a
	ld a,%00000000     ; Channel 1 sweep
	ldh [rAUD1SWEEP],a ; Bit 6-4 - Sweep pace
	                   ; Bit 3   - Sweep increase/decrease
	                   ;            0: Addition    (wavelength increases)
	                   ;            1: Subtraction (wavelength decreases)
	                   ; Bit 2-0 - Sweep slope control (n: 0-7)
	ld a,%00000000     ; Channel 1 length timer & duty cycle
	ldh [rAUD1LEN],a   ; Bit 7-6 - Wave duty            (Read/Write)
	                   ; Bit 5-0 - Initial length timer (Write Only)
	ld a,%00000000     ; Channel 1 volume & envelope
	ldh [rAUD1ENV],a   ; Bit 7-4 - Initial volume of envelope (0-F) (0=No Sound)
	                   ; Bit 3   - Envelope direction (0=Decrease, 1=Increase)
	                   ; Bit 2-0 - Sweep pace (0=No Sweep)
	ret

PlaySound:
	ld a,%10000011
	ldh [rAUD1ENV],a
	
	ld h,HIGH(MusicalScaleTbl)
	ld a,[wTestLoop]
	rlca
	ld l,a

	ld a,[hli]
	ldh [rAUD1LOW],a ; Channel 1 wavelength low
	ld a,[hli]
	or %10000000
	ldh [rAUD1HIGH],a ; Channel 1 wavelength high & control
	ret

SECTION "Musical Scale Table",ROM0[$2000]
MusicalScaleTbl:
	db %00101100,%000 ; C2
	db %10011100,%000 ; C#2
	db %00000110,%001 ; D2
	db %01101011,%001 ; D#2
	db %11001001,%001 ; E2
	db %00100011,%010 ; F2
	db %01110111,%010 ; F#2
	db %11000110,%010 ; G2
	db %00010010,%011 ; G#2
	db %01010110,%011 ; A2
	db %10011011,%011 ; A#2
	db %11011010,%011 ; B2
	db %00010110,%100 ; C3
	db %01001110,%100 ; C#3
	db %10000011,%100 ; D3
	db %10110101,%100 ; D#3
	db %11100101,%100 ; E3
	db %00010001,%101 ; F3
	db %00111011,%101 ; F#3
	db %01100011,%101 ; G3
	db %10001001,%101 ; G#3
	db %10101100,%101 ; A3
	db %11001110,%101 ; A#3
	db %11101101,%101 ; B3
	db %00001010,%110 ; C4
	db %00100111,%110 ; C#4
	db %01000010,%110 ; D4
	db %01011011,%110 ; D#4
	db %01110010,%110 ; E4
	db %10001001,%110 ; F4
	db %10011110,%110 ; F#4
	db %10110010,%110 ; G4
	db %11000100,%110 ; G#4
	db %11010110,%110 ; A4
	db %11100111,%110 ; A#4
	db %11110111,%110 ; B4
	db %00000110,%111 ; C5
	db %00010100,%111 ; C#5
	db %00100001,%111 ; D5
	db %00101101,%111 ; D#5
	db %00111001,%111 ; E5
	db %01000100,%111 ; F5
	db %01001111,%111 ; F#5
	db %01011001,%111 ; G5
	db %01100010,%111 ; G#5
	db %01101011,%111 ; A5
	db %01110011,%111 ; A#5
	db %01111011,%111 ; B5
	db %10000011,%111 ; C6
	db %10001010,%111 ; C#6
	db %10010000,%111 ; D6
	db %10010111,%111 ; D#6
	db %10011101,%111 ; E6
	db %10100010,%111 ; F6
	db %10100111,%111 ; F#6
	db %10101100,%111 ; G6
	db %10110001,%111 ; G#6
	db %10110110,%111 ; A6
	db %10111010,%111 ; A#6
	db %10111110,%111 ; B6
	db %11000001,%111 ; C7
	db %11000100,%111 ; C#7
	db %11001000,%111 ; D7
	db %11001011,%111 ; D#7
	db %11001110,%111 ; E7
	db %11010001,%111 ; F7
	db %11010100,%111 ; F#7
	db %11010110,%111 ; G7
	db %11011001,%111 ; G#7
	db %11011011,%111 ; A7
	db %11011101,%111 ; A#7
	db %11011111,%111 ; B7