MusicalScaleTbl:
	db %00101100,%000 ; C2
	db %10011101,%000 ; C#2
	db %00000111,%001 ; D2
	db %01101011,%001 ; D#2
	db %11001010,%001 ; E2
	db %00100011,%010 ; F2
	db %01110111,%010 ; F#2
	db %11000111,%010 ; G2
	db %00010010,%011 ; G#2
	db %01011001,%011 ; A2
	db %10011011,%011 ; A#2
	db %11011011,%011 ; B2
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
	db %00001011,%110 ; C4
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
	db %00000101,%111 ; C5
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
	db %11000101,%111 ; C#7
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

Sound01Tbl:
	db SF    ; Sound Off
	db SW,NW ; Sound Wait,Note
	         ; Note - NS: Sixteenth note
	         ;        N8: Eighth note
	         ;        N4: Quarter note
	         ;        N2: Half note
	         ;        NW: Whole note
	db SW,NW
	db SN    ; Sound On
	db E12,3 ; Set Duty cycle
	db N2,C5 ; Note,Scale
	         ; Scale - CxDxExFxGxAxBx: Musical scale
	         ;         x=2-5: Octave
	db N4,C5
	db N4,C5
	db N4,C5
	db N2,E5
	db N4,E5
	db N4,E5
	db N4,E5
	db NW,F5
	db SW,NW
	db SW,N2
	;
	db E12,2
	db JF    ; Jump function
	dw SetLightPalette
	db NW,C5
	db SW,NW
	db JF
	dw SetLightPalette
	db NW,C5
	db SW,NW
	db JF
	dw SetLightPalette
	db NW,F5
	db SW,NW
	db JF
	dw SetLightPalette
	db SS    ; Sound Stop
